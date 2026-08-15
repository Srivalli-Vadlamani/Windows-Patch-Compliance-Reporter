# 🛡️ Enterprise Windows Patch Compliance & Reporting Suite

A modular PowerShell automation tool designed for enterprise Level 3 Windows Server Operations. It automates patch auditing, pending reboot detection, critical service health validation, and generates executive HTML compliance reports.

## 🚀 Key Features
* **Automated Audit:** Collects OS architecture, uptime, and last boot timestamps via WMI/CIM.
* **Pending Reboot Detection:** Scans both `Component Based Servicing (CBS)` and `WindowsUpdate` registry hives to detect unapplied patches.
* **Service Health Validation:** Checks status and startup configurations for Windows Update Agent (`wuauserv`) and `BITS`.
* **Hotfix Verification:** Queries and tabulates the most recently applied security hotfixes (`Get-HotFix`).
* **HTML Executive Reporting:** Dynamically renders a styled, color-coded HTML report displaying compliance status (Compliant vs. Non-Compliant).

## 📋 Prerequisites
* Windows 10/11 or Windows Server 2012 R2–2022
* PowerShell 5.1 or PowerShell 7+
* Administrator Privileges

## 💻 How to Run
1. Open PowerShell as Administrator.
2. Run the script:
   ```powershell
   .\Get-PatchCompliance.ps1
