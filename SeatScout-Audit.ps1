<#
.SYNOPSIS
    SeatScout - Microsoft 365 license waste audit. Finds unused/inactive/over-provisioned
    licenses and quantifies how much money you can recover.

.DESCRIPTION
    Runs entirely inside YOUR tenant using the Microsoft Graph PowerShell SDK (read-only).
    No data ever leaves your environment - SeatScout has no servers and collects nothing.

    Produces:
      * A CFO-ready HTML savings report
      * CSV exports for each finding (for remediation)
      * A console summary

    Findings:
      * Unassigned purchased seats   (paying for seats nobody has)
      * Disabled-but-licensed users  (blocked accounts still consuming licenses)
      * Never-signed-in licensed users
      * Inactive licensed users      (no sign-in in N days)
      * Overlapping base plans       (e.g. E3 + E5 on the same user) [advisory]
      * Downgrade candidates         (e.g. E5 -> E3) [advisory]

.PARAMETER InactiveDays
    A licensed, enabled user with no sign-in in this many days is flagged inactive. Default 30.

.PARAMETER OutputPath
    Folder for the report + CSVs. Default: .\SeatScout-Report-<timestamp>

.PARAMETER PriceTablePath
    CSV mapping skuPartNumber -> friendly name + monthly price. Default: .\config\PriceTable.csv

.PARAMETER CompanyName
    [Pro] White-label the report header with this name.

.PARAMETER Currency
    Currency symbol/label shown in the report. Default 'USD' / '$'.

.PARAMETER Lite
    Free mode: exports the inactive/unused-license CSV + a summary only (no $ totals, no HTML report).

.PARAMETER MockDataPath
    Internal/testing: load tenant data from a JSON file instead of calling Microsoft Graph.

.EXAMPLE
    .\SeatScout-Audit.ps1 -InactiveDays 60 -CompanyName "Contoso IT"

.NOTES
    SeatScout  |  seatscout.com  |  read-only, runs in your tenant.
#>

[CmdletBinding()]
param(
    [int]    $InactiveDays   = 30,
    [string] $OutputPath,
    [string] $PriceTablePath = (Join-Path (Join-Path $PSScriptRoot 'config') 'PriceTable.csv'),
    [string] $CompanyName,
    [string] $CurrencySymbol = '$',
    [string] $CurrencyLabel  = 'USD',
    [switch] $Lite,
    [string] $MockDataPath
)

$ErrorActionPreference = 'Stop'
$script:Version = '1.0.0'
$script:Edition = 'Pro'   # build edition (set per package): Lite | Solo | Pro
$nowUtc = (Get-Date).ToUniversalTime()

# ----------------------------------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------------------------------
function Write-Step { param($Msg) Write-Host "[SeatScout] $Msg" -ForegroundColor Cyan }
function Write-Warn { param($Msg) Write-Host "[SeatScout] $Msg" -ForegroundColor Yellow }

function Get-PriceTable {
    param([string]$Path)
    if (-not (Test-Path $Path)) { throw "Price table not found: $Path" }
    $rows = Import-Csv -Path $Path | Where-Object { $_.SkuPartNumber -and -not $_.SkuPartNumber.StartsWith('#') }
    $map = @{}
    foreach ($r in $rows) {
        $price = $null
        if ($r.MonthlyPriceUSD -and ($r.MonthlyPriceUSD -as [double]) -ne $null) { $price = [double]$r.MonthlyPriceUSD }
        $map[$r.SkuPartNumber] = [pscustomobject]@{
            PartNumber   = $r.SkuPartNumber
            FriendlyName = if ($r.FriendlyName) { $r.FriendlyName } else { $r.SkuPartNumber }
            Price        = $price
        }
    }
    return $map
}

# Base productivity plans used for overlap / downgrade detection
$script:BasePlans = @('SPE_E5','SPE_E3','ENTERPRISEPREMIUM','ENTERPRISEPACK','STANDARDPACK',
                      'SPB','O365_BUSINESS_PREMIUM','O365_BUSINESS_ESSENTIALS','DESKLESSPACK','SPE_F1')

# ----------------------------------------------------------------------------------------------
# Data acquisition (Graph OR mock)
# ----------------------------------------------------------------------------------------------
function Get-TenantData {
    param([string]$MockPath)

    if ($MockPath) {
        Write-Step "Loading MOCK data from $MockPath"
        $raw = Get-Content -Path $MockPath -Raw | ConvertFrom-Json
        return $raw
    }

    Write-Step "Connecting to Microsoft Graph (read-only)..."
    $scopes = @('Organization.Read.All','User.Read.All','Directory.Read.All','AuditLog.Read.All')
    try {
        Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
        Import-Module Microsoft.Graph.Identity.DirectoryManagement -ErrorAction SilentlyContinue
        Import-Module Microsoft.Graph.Users -ErrorAction SilentlyContinue
    } catch {
        throw "Microsoft Graph PowerShell SDK not installed. Run:  Install-Module Microsoft.Graph -Scope CurrentUser"
    }
    Connect-MgGraph -Scopes $scopes -NoWelcome

    Write-Step "Reading organization + subscribed SKUs..."
    $org  = Get-MgOrganization
    $skus = Get-MgSubscribedSku -All

    Write-Step "Reading users (license + sign-in activity)..."
    $select = 'id,displayName,userPrincipalName,accountEnabled,assignedLicenses,createdDateTime,signInActivity'
    $users  = Get-MgUser -All -Property $select -ConsistencyLevel eventual

    # Normalize Graph objects into the same shape as the mock JSON
    $data = [pscustomobject]@{
        organization   = [pscustomobject]@{ displayName = $org.DisplayName; id = $org.Id }
        subscribedSkus = $skus | ForEach-Object {
            [pscustomobject]@{
                skuId         = $_.SkuId
                skuPartNumber = $_.SkuPartNumber
                prepaidUnits  = [pscustomobject]@{ enabled = $_.PrepaidUnits.Enabled }
                consumedUnits = $_.ConsumedUnits
            }
        }
        users = $users | ForEach-Object {
            $sia = $_.SignInActivity
            [pscustomobject]@{
                id                = $_.Id
                displayName       = $_.DisplayName
                userPrincipalName = $_.UserPrincipalName
                accountEnabled    = $_.AccountEnabled
                createdDateTime   = $_.CreatedDateTime
                assignedLicenses  = @($_.AssignedLicenses | ForEach-Object { [pscustomobject]@{ skuId = $_.SkuId } })
                signInActivity    = if ($sia) { [pscustomobject]@{ lastSignInDateTime = $sia.LastSignInDateTime } } else { $null }
            }
        }
    }
    return $data
}

# ----------------------------------------------------------------------------------------------
# Analysis
# ----------------------------------------------------------------------------------------------
function Invoke-Analysis {
    param($Data, $PriceMap, [int]$InactiveDays)

    # skuId -> details (partNumber, friendly, price)
    $skuById = @{}
    $skuMeta = @()
    $signInDataAvailable = $false

    foreach ($s in $Data.subscribedSkus) {
        $meta = $PriceMap[$s.skuPartNumber]
        $friendly = if ($meta) { $meta.FriendlyName } else { $s.skuPartNumber }
        $price    = if ($meta) { $meta.Price } else { $null }
        $purchased = [int]$s.prepaidUnits.enabled
        $consumed  = [int]$s.consumedUnits
        $unassigned = [math]::Max(0, $purchased - $consumed)
        $info = [pscustomobject]@{
            SkuId=$s.skuId; PartNumber=$s.skuPartNumber; Friendly=$friendly; Price=$price
            Purchased=$purchased; Consumed=$consumed; Unassigned=$unassigned
            UnassignedWasteMonthly = if ($price) { $unassigned * $price } else { $null }
        }
        $skuById[$s.skuId] = $info
        $skuMeta += $info
    }

    $cutoff = $nowUtc.AddDays(-$InactiveDays)

    $disabled=@(); $never=@(); $inactive=@(); $overlap=@(); $downgrade=@()

    foreach ($u in $Data.users) {
        $lic = @($u.assignedLicenses | ForEach-Object { $skuById[$_.skuId] } | Where-Object { $_ })
        if ($lic.Count -eq 0) { continue }   # unlicensed users are irrelevant to license waste

        $userMonthly = ($lic | Where-Object { $_.Price } | Measure-Object -Property Price -Sum).Sum
        if (-not $userMonthly) { $userMonthly = 0 }
        $licNames = ($lic | ForEach-Object { $_.Friendly }) -join '; '

        $lastSignIn = $null
        if ($u.signInActivity -and $u.signInActivity.lastSignInDateTime) {
            $signInDataAvailable = $true
            try { $lastSignIn = [datetime]$u.signInActivity.lastSignInDateTime } catch { $lastSignIn = $null }
        }
        $created = $null
        if ($u.createdDateTime) { try { $created = [datetime]$u.createdDateTime } catch {} }

        $row = [pscustomobject]@{
            DisplayName=$u.displayName; UserPrincipalName=$u.userPrincipalName
            AccountEnabled=$u.accountEnabled; Licenses=$licNames
            LastSignIn = if ($lastSignIn) { $lastSignIn.ToString('yyyy-MM-dd') } else { 'never' }
            MonthlyCost=[math]::Round($userMonthly,2)
        }

        if (-not $u.accountEnabled) {
            $disabled += $row
        }
        elseif (-not $lastSignIn) {
            # never signed in - only flag if the account is old enough to be meaningful
            if (-not $created -or $created -lt $cutoff) { $never += $row }
        }
        elseif ($lastSignIn -lt $cutoff) {
            $inactive += $row
        }

        # overlap (advisory): more than one base productivity plan
        $base = @($lic | Where-Object { $script:BasePlans -contains $_.PartNumber })
        if ($base.Count -gt 1) {
            $overlap += [pscustomobject]@{
                DisplayName=$u.displayName; UserPrincipalName=$u.userPrincipalName
                OverlappingPlans=($base | ForEach-Object { $_.Friendly }) -join ' + '
                MonthlyCost=[math]::Round($userMonthly,2)
            }
        }

        # downgrade candidate (advisory): E5 -> E3 delta, only if both priced
        $hasE5 = $base | Where-Object { $_.PartNumber -eq 'SPE_E5' } | Select-Object -First 1
        if ($hasE5 -and $u.accountEnabled) {
            $e3 = $PriceMap['SPE_E3']
            if ($hasE5.Price -and $e3 -and $e3.Price) {
                $downgrade += [pscustomobject]@{
                    DisplayName=$u.displayName; UserPrincipalName=$u.userPrincipalName
                    From='Microsoft 365 E5'; To='Microsoft 365 E3'
                    MonthlySaving=[math]::Round(($hasE5.Price - $e3.Price),2)
                }
            }
        }
    }

    # Sum recoverable (conservative: disabled + never + inactive + unassigned seats; overlap/downgrade are advisory)
    $sum = { param($arr) ($arr | Measure-Object -Property MonthlyCost -Sum).Sum }
    $disabledM = (& $sum $disabled); if (-not $disabledM){$disabledM=0}
    $neverM    = (& $sum $never);    if (-not $neverM){$neverM=0}
    $inactiveM = (& $sum $inactive); if (-not $inactiveM){$inactiveM=0}
    $unassignedM = ($skuMeta | Where-Object { $_.UnassignedWasteMonthly } | Measure-Object -Property UnassignedWasteMonthly -Sum).Sum
    if (-not $unassignedM) { $unassignedM = 0 }

    $recoverableMonthly = $disabledM + $neverM + $inactiveM + $unassignedM

    # SKUs with seats but no configured price (excluded from totals) - for honesty note
    $unpriced = @($skuMeta | Where-Object { -not $_.Price -and $_.Purchased -gt 0 })

    return [pscustomobject]@{
        Org=$Data.organization
        Skus=$skuMeta
        Disabled=$disabled; Never=$never; Inactive=$inactive; Overlap=$overlap; Downgrade=$downgrade
        DisabledMonthly=$disabledM; NeverMonthly=$neverM; InactiveMonthly=$inactiveM; UnassignedMonthly=$unassignedM
        RecoverableMonthly=$recoverableMonthly; RecoverableAnnual=($recoverableMonthly*12)
        SignInDataAvailable=$signInDataAvailable
        UnpricedSkus=$unpriced
        TotalUsersLicensed = ($Disabled.Count + $never.Count + $inactive.Count) # placeholder recalculated below
    }
}

# ----------------------------------------------------------------------------------------------
# Reporting
# ----------------------------------------------------------------------------------------------
function Format-Money { param($n) "{0}{1:N0}" -f $script:CurSym, [double]$n }

function New-HtmlReport {
    param($R, [string]$Path, [string]$CompanyName)

    $script:CurSym = $CurrencySymbol
    $brand = if ($CompanyName) { $CompanyName } else { 'SeatScout' }
    $orgName = if ($R.Org.displayName) { $R.Org.displayName } else { 'Your tenant' }
    $generated = $nowUtc.ToString('yyyy-MM-dd HH:mm') + ' UTC'

    $rowsToHtml = {
        param($arr, $cols)
        if (-not $arr -or $arr.Count -eq 0) { return "<tr><td colspan='$($cols.Count)' class='muted'>None found - nice.</td></tr>" }
        ($arr | Select-Object -First 100 | ForEach-Object {
            $u=$_
            '<tr>' + (($cols | ForEach-Object { "<td>$([System.Net.WebUtility]::HtmlEncode([string]$u.$_))</td>" }) -join '') + '</tr>'
        }) -join "`n"
    }

    $annual = Format-Money $R.RecoverableAnnual
    $monthly = Format-Money $R.RecoverableMonthly

    $signinNote = if ($R.SignInDataAvailable) { '' } else {
        "<div class='callout warn'>Sign-in activity was not available for this tenant (requires Microsoft Entra ID P1 + AuditLog.Read.All). Inactivity figures fall back to <b>disabled</b> and <b>never-signed-in</b> accounts only, so real waste is likely <b>higher</b> than shown.</div>"
    }
    $unpricedNote = if ($R.UnpricedSkus.Count -gt 0) {
        $names = ($R.UnpricedSkus | ForEach-Object { $_.Friendly }) -join ', '
        "<div class='callout'>$($R.UnpricedSkus.Count) purchased SKU(s) have no price set and are <b>excluded</b> from the totals above: $names. Add their prices in config\PriceTable.csv to capture the full figure.</div>"
    } else { '' }

    $disabledRows  = & $rowsToHtml $R.Disabled  @('DisplayName','UserPrincipalName','Licenses','MonthlyCost')
    $neverRows     = & $rowsToHtml $R.Never     @('DisplayName','UserPrincipalName','Licenses','MonthlyCost')
    $inactiveRows  = & $rowsToHtml $R.Inactive  @('DisplayName','UserPrincipalName','Licenses','LastSignIn','MonthlyCost')
    $overlapRows   = & $rowsToHtml $R.Overlap   @('DisplayName','UserPrincipalName','OverlappingPlans','MonthlyCost')
    $downgradeRows = & $rowsToHtml $R.Downgrade @('DisplayName','UserPrincipalName','From','To','MonthlySaving')

    $skuRows = ($R.Skus | Sort-Object PartNumber | ForEach-Object {
        $p = if ($_.Price) { Format-Money $_.Price } else { "<span class='muted'>not set</span>" }
        $w = if ($_.UnassignedWasteMonthly) { Format-Money $_.UnassignedWasteMonthly } else { '-' }
        "<tr><td>$($_.Friendly)</td><td class='mono'>$($_.PartNumber)</td><td>$($_.Purchased)</td><td>$($_.Consumed)</td><td>$($_.Unassigned)</td><td>$p</td><td>$w</td></tr>"
    }) -join "`n"

    # simple CSS bar chart of the four buckets
    $vals = @(
        @{l='Unassigned seats'; v=$R.UnassignedMonthly},
        @{l='Disabled + licensed'; v=$R.DisabledMonthly},
        @{l='Never signed in'; v=$R.NeverMonthly},
        @{l='Inactive users'; v=$R.InactiveMonthly}
    )
    $maxV = ($vals | ForEach-Object { $_.v } | Measure-Object -Maximum).Maximum
    if (-not $maxV -or $maxV -le 0) { $maxV = 1 }
    $bars = ($vals | ForEach-Object {
        $pct = [math]::Round(($_.v / $maxV) * 100,1)
        "<div class='bar-row'><div class='bar-label'>$($_.l)</div><div class='bar-track'><div class='bar-fill' style='width:$pct%'></div></div><div class='bar-val'>$(Format-Money $_.v)/mo</div></div>"
    }) -join "`n"

$html = @"
<!DOCTYPE html>
<html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width, initial-scale=1'>
<title>$brand - Microsoft 365 License Savings Report</title>
<style>
:root{--ink:#0f172a;--muted:#64748b;--line:#e2e8f0;--accent:#2563eb;--good:#059669;--warn:#b45309;--bg:#f8fafc}
*{box-sizing:border-box}body{font-family:-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;margin:0;color:var(--ink);background:var(--bg)}
.wrap{max-width:960px;margin:0 auto;padding:32px 24px 64px}
header{display:flex;justify-content:space-between;align-items:baseline;border-bottom:2px solid var(--ink);padding-bottom:16px;margin-bottom:24px}
h1{font-size:20px;margin:0}h2{font-size:16px;margin:32px 0 12px;border-bottom:1px solid var(--line);padding-bottom:6px}
.sub{color:var(--muted);font-size:13px}
.hero{background:#fff;border:1px solid var(--line);border-radius:14px;padding:28px;margin-bottom:8px;text-align:center;box-shadow:0 1px 2px rgba(0,0,0,.04)}
.hero .big{font-size:46px;font-weight:800;color:var(--good);line-height:1.1}
.hero .cap{color:var(--muted);font-size:13px;text-transform:uppercase;letter-spacing:.08em}
.hero .mo{color:var(--muted);font-size:14px;margin-top:6px}
.cards{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin:18px 0}
.card{background:#fff;border:1px solid var(--line);border-radius:10px;padding:14px}
.card .n{font-size:22px;font-weight:700}.card .l{color:var(--muted);font-size:12px}
table{width:100%;border-collapse:collapse;background:#fff;border:1px solid var(--line);border-radius:8px;overflow:hidden;font-size:13px}
th,td{text-align:left;padding:8px 10px;border-bottom:1px solid var(--line)}th{background:#f1f5f9;font-size:11px;text-transform:uppercase;letter-spacing:.04em;color:var(--muted)}
.mono{font-family:ui-monospace,Consolas,monospace;font-size:12px;color:var(--muted)}.muted{color:var(--muted)}
.callout{background:#fffbeb;border:1px solid #fde68a;color:#92400e;padding:10px 12px;border-radius:8px;font-size:13px;margin:10px 0}
.callout.warn{background:#fef2f2;border-color:#fecaca;color:#991b1b}
.bar-row{display:flex;align-items:center;gap:10px;margin:6px 0}.bar-label{width:150px;font-size:12px;color:var(--muted)}
.bar-track{flex:1;background:#eef2f7;border-radius:6px;height:18px;overflow:hidden}.bar-fill{height:100%;background:var(--accent)}
.bar-val{width:120px;text-align:right;font-size:12px;font-weight:600}
.checklist{background:#fff;border:1px solid var(--line);border-radius:8px;padding:14px 18px}
.checklist li{margin:6px 0}
footer{margin-top:40px;color:var(--muted);font-size:12px;border-top:1px solid var(--line);padding-top:14px}
.badge{display:inline-block;background:#ecfdf5;color:var(--good);border:1px solid #a7f3d0;border-radius:999px;padding:2px 10px;font-size:11px;font-weight:600}
</style></head><body><div class='wrap'>
<header><div><h1>$brand</h1><div class='sub'>Microsoft 365 License Savings Report</div></div>
<div class='sub'>$orgName &middot; $generated</div></header>

<div class='hero'>
  <div class='cap'>Estimated recoverable spend</div>
  <div class='big'>$annual<span style='font-size:18px;color:var(--muted)'> / year</span></div>
  <div class='mo'>$monthly per month &middot; <span class='badge'>read-only audit &middot; nothing left your tenant</span></div>
</div>
$signinNote
$unpricedNote

<div class='cards'>
  <div class='card'><div class='n'>$($R.Skus | Measure-Object | Select-Object -ExpandProperty Count)</div><div class='l'>License SKUs</div></div>
  <div class='card'><div class='n'>$($R.Disabled.Count)</div><div class='l'>Disabled but licensed</div></div>
  <div class='card'><div class='n'>$($R.Never.Count + $R.Inactive.Count)</div><div class='l'>Inactive / never used</div></div>
  <div class='card'><div class='n'>$(($R.Skus | Measure-Object -Property Unassigned -Sum).Sum)</div><div class='l'>Unassigned seats</div></div>
</div>

<h2>Where the money is</h2>
$bars

<h2>Unassigned purchased seats</h2>
<p class='sub'>Seats you pay for that are not assigned to anyone. The cleanest, fastest win.</p>
<table><tr><th>License</th><th>Part #</th><th>Purchased</th><th>Assigned</th><th>Unassigned</th><th>Unit/mo</th><th>Waste/mo</th></tr>
$skuRows</table>

<h2>Disabled accounts still holding licenses ($($R.Disabled.Count))</h2>
<table><tr><th>Name</th><th>UPN</th><th>Licenses</th><th>Cost/mo</th></tr>$disabledRows</table>

<h2>Never signed in ($($R.Never.Count))</h2>
<table><tr><th>Name</th><th>UPN</th><th>Licenses</th><th>Cost/mo</th></tr>$neverRows</table>

<h2>Inactive &gt; $InactiveDays days ($($R.Inactive.Count))</h2>
<table><tr><th>Name</th><th>UPN</th><th>Licenses</th><th>Last sign-in</th><th>Cost/mo</th></tr>$inactiveRows</table>

<h2>Advisory: overlapping base plans ($($R.Overlap.Count))</h2>
<p class='sub'>Users with more than one productivity plan (e.g. E3 + E5). Review for consolidation. Not included in the headline total.</p>
<table><tr><th>Name</th><th>UPN</th><th>Overlapping plans</th><th>Cost/mo</th></tr>$overlapRows</table>

<h2>Advisory: downgrade candidates ($($R.Downgrade.Count))</h2>
<p class='sub'>E5 users to review for an E3 fit. Validate feature usage (security, analytics, Power BI, voice) before downgrading. Not included in the headline total.</p>
<table><tr><th>Name</th><th>UPN</th><th>From</th><th>To</th><th>Saving/mo</th></tr>$downgradeRows</table>

<h2>Remediation checklist</h2>
<ol class='checklist'>
<li>Reclaim <b>unassigned seats</b> at next renewal (or reduce the subscription quantity now).</li>
<li>Remove licenses from <b>disabled accounts</b> - they are blocked but still billed.</li>
<li>Investigate <b>never-signed-in</b> users: offboard leftovers, reassign the rest.</li>
<li>Contact <b>inactive</b> users or their managers before reclaiming.</li>
<li>Review <b>overlap</b> and <b>downgrade</b> candidates with the business owner.</li>
<li>Re-run SeatScout monthly to keep waste from creeping back.</li>
</ol>

<footer>
<b>Methodology.</b> Read-only data from Microsoft Graph (subscribed SKUs, user license assignments, sign-in activity). Savings = monthly list price of reclaimable licenses x 12. Prices come from config\PriceTable.csv (edit to match your agreement); SKUs without a price are excluded. Advisory sections are not included in the headline figure. Figures are estimates to prioritize action, not a billing statement.<br><br>
Generated by SeatScout v$script:Version &middot; seatscout.com &middot; This report was produced locally; no tenant data was transmitted.
</footer>
</div></body></html>
"@

    $html | Out-File -FilePath $Path -Encoding utf8
}

# ----------------------------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------------------------
Write-Host ""
Write-Host "  SeatScout v$script:Version - Microsoft 365 license waste audit" -ForegroundColor Green
Write-Host "  Read-only. Runs in your tenant. Nothing leaves your environment." -ForegroundColor DarkGray
Write-Host ""

if (-not $OutputPath) { $OutputPath = Join-Path (Get-Location) ("SeatScout-Report-" + $nowUtc.ToString('yyyyMMdd-HHmmss')) }
New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null

$priceMap = Get-PriceTable -Path $PriceTablePath
$data     = Get-TenantData -MockPath $MockDataPath
$R        = Invoke-Analysis -Data $data -PriceMap $priceMap -InactiveDays $InactiveDays

# CSV exports (always)
$R.Disabled  | Export-Csv (Join-Path $OutputPath 'disabled-but-licensed.csv') -NoTypeInformation -Encoding utf8
$R.Never     | Export-Csv (Join-Path $OutputPath 'never-signed-in.csv') -NoTypeInformation -Encoding utf8
$R.Inactive  | Export-Csv (Join-Path $OutputPath 'inactive-users.csv') -NoTypeInformation -Encoding utf8

if ($Lite -or $script:Edition -eq 'Lite') {
    Write-Host ""
    Write-Step "LITE mode - free edition"
    Write-Host ("  Disabled but licensed : {0}" -f $R.Disabled.Count)
    Write-Host ("  Never signed in       : {0}" -f $R.Never.Count)
    Write-Host ("  Inactive > $InactiveDays days     : {0}" -f $R.Inactive.Count)
    Write-Host ("  Unassigned seats      : {0}" -f (($R.Skus | Measure-Object -Property Unassigned -Sum).Sum))
    Write-Host ""
    Write-Host "  Dollar totals, the CFO-ready HTML report, overlap & downgrade analysis," -ForegroundColor Yellow
    Write-Host "  and white-label output are in SeatScout Pro -> seatscout.com" -ForegroundColor Yellow
    Write-Host ""
    Write-Step "CSV saved to: $OutputPath"
    return
}

# Full: extra CSVs + HTML
$R.Overlap   | Export-Csv (Join-Path $OutputPath 'overlap-base-plans.csv') -NoTypeInformation -Encoding utf8
$R.Downgrade | Export-Csv (Join-Path $OutputPath 'downgrade-candidates.csv') -NoTypeInformation -Encoding utf8
$R.Skus      | Export-Csv (Join-Path $OutputPath 'sku-inventory.csv') -NoTypeInformation -Encoding utf8

$reportPath = Join-Path $OutputPath 'SeatScout-Report.html'
$whiteLabel = if ($script:Edition -eq 'Pro') { $CompanyName } else { $null }   # white-label is a Pro feature
New-HtmlReport -R $R -Path $reportPath -CompanyName $whiteLabel

Write-Host ""
Write-Step "RESULTS"
Write-Host ("  Recoverable: {0}{1:N0}/mo  ->  {0}{2:N0}/yr" -f $CurrencySymbol, $R.RecoverableMonthly, $R.RecoverableAnnual) -ForegroundColor Green
Write-Host ("  Disabled+licensed {0} | never {1} | inactive {2} | unassigned seats {3}" -f `
    $R.Disabled.Count, $R.Never.Count, $R.Inactive.Count, (($R.Skus | Measure-Object -Property Unassigned -Sum).Sum))
if (-not $R.SignInDataAvailable) { Write-Warn "Sign-in data unavailable (no Entra P1?) - real waste is likely higher." }
if ($R.UnpricedSkus.Count -gt 0) { Write-Warn "$($R.UnpricedSkus.Count) purchased SKU(s) have no price set - excluded from totals (see PriceTable.csv)." }
Write-Host ""
Write-Step "Report: $reportPath"
Write-Step "CSVs:   $OutputPath"
Write-Host ""
