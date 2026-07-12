\# Setup Instructions



\## Prerequisites



\- Windows PowerShell 5.0 or higher

\- Administrator privileges

\- Git installed



\## Installation Steps



\### Step 1: Clone the Repository



```powershell

git clone https://github.com/learningwithmike/network-monitoring-dashboard.git

cd network-monitoring-dashboard

```



\### Step 2: Verify Directory Structure



```powershell

\# Verify all files are present

Get-ChildItem -Recurse

```



Expected output should show:

\- src/ folder with three .ps1 files

\- config/ folder with config.json

\- docs/ folder with this file

\- logs/ folder (may be empty)



\### Step 3: Allow Script Execution



PowerShell has execution policies that may block scripts. Run as Administrator:



```powershell

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

```



This allows local scripts to run while maintaining security.



\### Step 4: Test the Installation



Run a single check:



```powershell

.\\src\\Monitor-Network.ps1

```



You should see output like:

```

========================================

&#x20;  Network Monitoring Dashboard

========================================



\[Iteration 1] 2024-01-15 14:30:45

CPU Usage:    45%

Memory Usage: 62% (10.5GB / 16GB)

Disk Usage:   55%

```



\### Step 5: Configure Thresholds (Optional)



Edit `config/config.json` to set your preferred alert thresholds:



```json

"monitoring": {

&#x20;   "checkInterval": 300,        # Check every 5 minutes

&#x20;   "cpuThreshold": 80,          # Alert if CPU > 80%

&#x20;   "memoryThreshold": 85,       # Alert if Memory > 85%

&#x20;   "diskThreshold": 90          # Alert if Disk > 90%

}

```



\## Troubleshooting



\### "cannot be loaded because running scripts is disabled"



Solution:

```powershell

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

```



\### "WMI not available" error



Solution: Ensure you're running as Administrator and WMI service is running:

```powershell

Get-Service WmiPrvSE | Start-Service

```



\### Configuration file not found



Make sure you're running from the project root directory:

```powershell

cd network-monitoring-dashboard

.\\src\\Monitor-Network.ps1

```



\## Next Steps



\- See `USAGE.md` for detailed usage instructions

\- Configure custom thresholds in `config/config.json`

\- Review alert logs in `logs/alerts.log`

