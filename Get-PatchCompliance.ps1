<#
.SYNOPSIS
    Automated Windows Server Patch Compliance & Health Audit Tool.
.DESCRIPTION
    Checks system uptime, pending reboots, critical Windows services, 
    and recent hotfixes, generating an enterprise-grade HTML report.
.AUTHOR
    Srivalli Vadlamani
#>

function Get-PatchComplianceReport {
    [CmdletBinding()]
    param (
        [string]$ReportPath = "$([Environment]::GetFolderPath('Desktop'))\PatchComplianceReport.html"
    )

    Write-Host ">>> Starting Patch Compliance Audit on $env:COMPUTERNAME..." -ForegroundColor Cyan

    # 1. System Information
    $OS = Get-CimInstance -ClassName Win32_OperatingSystem
    $LastBootTime = $OS.LastBootUpTime
    $UptimeDays = [math]::Round(((Get-Date) - $LastBootTime).TotalDays, 1)

    # 2. Check for Pending Reboots
    $PendingReboot = $false
    $CBSReboot = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
    $WUReboot  = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"

    if ($CBSReboot -or $WUReboot) {
        $PendingReboot = $true
    }

    # 3. Check Critical Windows Services (Windows Update & Background Intelligent Transfer Service)
    $ServicesToCheck = @('wuauserv', 'BITS')
    $ServiceResults = foreach ($svc in $ServicesToCheck) {
        $status = Get-Service -Name $svc -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            ServiceName = $svc
            DisplayName = $status.DisplayName
            Status      = if ($status) { $status.Status.ToString() } else { "Not Found" }
            StartType   = if ($status) { $status.StartType.ToString() } else { "N/A" }
        }
    }

    # 4. Check Recent Hotfixes (Installed Updates)
    $RecentUpdates = Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5

    # 5. Determine Overall Compliance
    $ComplianceStatus = "Compliant"
    $StatusColor = "#28a745" # Green

    if ($PendingReboot -eq $true -or ($ServiceResults | Where-Object { $_.Status -ne "Running" })) {
        $ComplianceStatus = "Non-Compliant (Action Required)"
        $StatusColor = "#dc3545" # Red
    }

    # 6. Build the HTML Report Card
    $HtmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f6f9; margin: 20px; }
        .container { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 900px; margin: auto; }
        h1 { color: #1a3a5f; margin-bottom: 5px; }
        .badge { padding: 8px 14px; border-radius: 4px; color: white; font-weight: bold; display: inline-block; background-color: $StatusColor; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #0056b3; color: white; }
        .section-title { margin-top: 25px; color: #333; border-bottom: 2px solid #0056b3; padding-bottom: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Enterprise Server Patch Compliance Report</h1>
        <p><strong>Host:</strong> $env:COMPUTERNAME | <strong>Generated:</strong> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
        
        <h3 class="section-title">Compliance Summary</h3>
        <p>Status: <span class="badge">$ComplianceStatus</span></p>
        <p><strong>Operating System:</strong> $($OS.Caption) ($($OS.OSArchitecture))</p>
        <p><strong>Uptime:</strong> $UptimeDays Days (Last Boot: $($LastBootTime.ToString('yyyy-MM-dd HH:mm')))</p>
        <p><strong>Pending Reboot Flag:</strong> $(if($PendingReboot){"<span style='color:red;font-weight:bold;'>YES</span>"}else{"<span style='color:green;font-weight:bold;'>NO</span>"})</p>

        <h3 class="section-title">Core Windows Update Services</h3>
        <table>
            <tr><th>Service Name</th><th>Display Name</th><th>Status</th><th>Startup Type</th></tr>
            $($ServiceResults | ForEach-Object { "<tr><td>$($_.ServiceName)</td><td>$($_.DisplayName)</td><td>$($_.Status)</td><td>$($_.StartType)</td></tr>" })
        </table>

        <h3 class="section-title">Last 5 Installed Hotfixes</h3>
        <table>
            <tr><th>Hotfix ID</th><th>Description</th><th>Installed On</th></tr>
            $($RecentUpdates | ForEach-Object { "<tr><td>$($_.HotFixID)</td><td>$($_.Description)</td><td>$($_.InstalledOn)</td></tr>" })
        </table>
    </div>
</body>
</html>
"@

    # Save to file
    $HtmlReport | Out-File -FilePath $ReportPath -Encoding UTF8
    Write-Host ">>> Audit Complete! Report saved to: $ReportPath" -ForegroundColor Green
}

# Run the function
Get-PatchComplianceReport
