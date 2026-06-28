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
    SeatScout  |  seatscout.dev  |  read-only, runs in your tenant.
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
$script:Version = '1.0.1'
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
    # signInActivity requires Entra ID P1; on non-premium tenants Graph 403s the whole query,
    # so try with it, then fall back to a query without it (disabled + unassigned-seat analysis only).
    $baseProps = 'id,displayName,userPrincipalName,accountEnabled,assignedLicenses,createdDateTime'
    $signInRetrievable = $true
    try {
        $users = Get-MgUser -All -Property ($baseProps + ',signInActivity') -ErrorAction Stop
    } catch {
        Write-Warn "Sign-in activity needs Microsoft Entra ID P1 - retrying without it (disabled + unassigned-seat analysis only)."
        $signInRetrievable = $false
        $users = Get-MgUser -All -Property $baseProps -ErrorAction Stop
    }

    # Normalize Graph objects into the same shape as the mock JSON
    $data = [pscustomobject]@{
        organization      = [pscustomobject]@{ displayName = $org.DisplayName; id = $org.Id }
        signInRetrievable = $signInRetrievable
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

# ---------------------------------------------------------------------------------------------
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
        $isUnlimited = $purchased -gt 100000   # Microsoft sentinel for free / unlimited self-service SKUs
        $unassigned = if ($isUnlimited) { 0 } else { [math]::Max(0, $purchased - $consumed) }
        $info = [pscustomobject]@{
            SkuId=$s.skuId; PartNumber=$s.skuPartNumber; Friendly=$friendly; Price=$price
            Purchased=$purchased; Consumed=$consumed; Unassigned=$unassigned; IsUnlimited=$isUnlimited
            UnassignedWasteMonthly = if ($price -and -not $isUnlimited) { $unassigned * $price } else { $null }
        }
        $skuById[$s.skuId] = $info
        $skuMeta += $info
    }

    $cutoff = $nowUtc.AddDays(-$InactiveDays)
    $signInRetrievable = if ($null -ne $Data.signInRetrievable) { [bool]$Data.signInRetrievable } else { $true }

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
        elseif ($signInRetrievable) {
            if (-not $lastSignIn) {
                # never signed in - only flag if the account is old enough to be meaningful
                if (-not $created -or $created -lt $cutoff) { $never += $row }
            }
            elseif ($lastSignIn -lt $cutoff) {
                $inactive += $row
            }
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
        SignInDataAvailable=$signInRetrievable
        UnpricedSkus=$unpriced
        TotalUsersLicensed = ($Disabled.Count + $never.Count + $inactive.Count) # placeholder recalculated below
    }
}

# ----------------------------------------------------------------------------------------------
# Reporting
# ----------------------------------------------------------------------------------------------
function Format-Money { param($n) [string]::Format([cultureinfo]::GetCultureInfo('en-US'), '{0}{1:N0}', $script:CurSym, [double]$n) }

function New-HtmlReport {
    param($R, [string]$Path, [string]$CompanyName)

    $script:CurSym = $CurrencySymbol
    $brand = if ($CompanyName) { $CompanyName } else { 'SeatScout' }
    $orgName = if ($R.Org.displayName) { $R.Org.