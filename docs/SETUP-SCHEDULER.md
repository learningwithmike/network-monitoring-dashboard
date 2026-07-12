# Setting Up Windows Task Scheduler for Automation

This guide explains how to automatically run the Network Monitoring Dashboard at system startup using Windows Task Scheduler.

## Prerequisites

- Windows 10/11 or Windows Server 2016+
- **Administrator privileges** (required to create scheduled tasks)
- PowerShell 5.0+
- Project directory: `C:\Users\egg\Documents\network-monitoring-dashboard`

---

## Step 1: Prepare Your Environment

### 1.1 Set PowerShell Execution Policy

Run PowerShell **as Administrator**:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

This allows PowerShell scripts to run on your system.

### 1.2 Verify Script Paths

Make sure the monitoring script exists:

```powershell
Test-Path "C:\Users\egg\Documents\network-monitoring-dashboard\src\Monitor-Network.ps1"
```

**Expected output:** `True`

---

## Step 2: Create the Scheduled Task

### Option A: Using PowerShell (Recommended)

Run PowerShell **as Administrator** and navigate to your project:

```powershell
cd C:\Users\egg\Documents\network-monitoring-dashboard
```

Load the scheduler setup function:

```powershell
. .\src\Setup-Scheduler.ps1
```

Create the scheduled task:

```powershell
Setup-ScheduledMonitoring
```

**Expected output:**
```
✓ Scheduled task 'NetworkMonitoringDashboard' created successfully!
  - Runs at system startup
  - Runs with SYSTEM privileges
  - Script: C:\Users\egg\Documents\network-monitoring-dashboard\src\Monitor-Network.ps1
```

✅ **Done!** The task is now scheduled and will run automatically at next startup.

---

### Option B: Using Windows Task Scheduler GUI

If you prefer the graphical interface:

1. Press **Windows Key + R**
2. Type `taskschd.msc` and press Enter
3. Click **Create Basic Task** on the right panel
4. Name: `NetworkMonitoringDashboard`
5. Description: `Network Monitoring Dashboard - Automated System Alerts`
6. Click **Next**

**Trigger Tab:**
- Select **At system startup**
- Click **Next**

**Action Tab:**
- **Program/script:** `powershell.exe`
- **Add arguments:** `-NoProfile -ExecutionPolicy Bypass -File "C:\Users\egg\Documents\network-monitoring-dashboard\src\Monitor-Network.ps1" -Continuous`
- **Start in:** `C:\Users\egg\Documents\network-monitoring-dashboard`
- Click **Next**

**Conditions Tab:**
- ☑️ **Wake the computer to run this task**
- Click **Next**

**Settings Tab:**
- ☑️ **Allow task to be run on demand**
- ☑️ **Run task as soon as possible after a scheduled start is missed**
- ☑️ **If the task fails, restart every:** 5 minutes
- Click **Finish**

---

## Step 3: Verify the Task

### Check Task Status

Run PowerShell **as Administrator**:

```powershell
cd C:\Users\egg\Documents\network-monitoring-dashboard
. .\src\Setup-Scheduler.ps1

Get-ScheduledMonitoringStatus
```

**Expected output:**
```
Task: NetworkMonitoringDashboard
  Status: Ready
  Last Run: (none - hasn't run yet)
  Last Result: 0
  Next Run: At system startup
```

### Using Task Scheduler GUI

1. Press **Windows Key + R**
2. Type `taskschd.msc`
3. Navigate to **Task Scheduler Library**
4. Look for **NetworkMonitoringDashboard**
5. View the details and status

---

## Step 4: Test the Task

### Option A: Automatic Restart

Restart your computer and the monitoring will start automatically:

```powershell
Restart-Computer
```

The script will run in the background as the **SYSTEM** account.

### Option B: Run Manually

Right-click the task in Task Scheduler and select **Run**

Or in PowerShell:

```powershell
Start-ScheduledTask -TaskName "NetworkMonitoringDashboard"
```

### Check if it's Running

```powershell
Get-ScheduledTaskInfo -TaskName "NetworkMonitoringDashboard"
```

Look for:
- **Last Run Time** - Should show a recent timestamp
- **Last Task Result** - Should show `0` (success)

---

## Step 5: Verify Monitoring is Active

Check if the monitoring is working:

1. **Check logs directory exists:**
   ```powershell
   Test-Path "C:\Users\egg\Documents\network-monitoring-dashboard\logs"
   ```

2. **View alerts log:**
   ```powershell
   Get-Content "C:\Users\egg\Documents\network-monitoring-dashboard\logs\alerts.log" -Tail 10
   ```

3. **View Windows Event Viewer:**
   - Press **Windows Key + R**
   - Type `eventvwr.msc`
   - Navigate to **Windows Logs → Application**
   - Look for events from **PowerShell**

---

## Managing the Scheduled Task

### View Task Details

```powershell
. .\src\Setup-Scheduler.ps1
Get-ScheduledMonitoringStatus
```

### Edit the Task

**In PowerShell:**
```powershell
$task = Get-ScheduledTask -TaskName "NetworkMonitoringDashboard"
Set-ScheduledTask -InputObject $task -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries)
```

**In GUI:**
1. Right-click the task
2. Select **Properties**
3. Edit as needed
4. Click **OK**

### Disable the Task (Keep Configuration)

```powershell
Disable-ScheduledTask -TaskName "NetworkMonitoringDashboard"
```

### Remove the Task

```powershell
. .\src\Setup-Scheduler.ps1
Remove-ScheduledMonitoring
```

Or manually:
```powershell
Unregister-ScheduledTask -TaskName "NetworkMonitoringDashboard" -Confirm:$false
```

---

## Troubleshooting

### Task doesn't run at startup

**Problem:** The task is configured but doesn't run
- **Solution:** Check if SYSTEM account has permissions to the script
- **Solution:** Verify the script path is absolute (not relative)
- **Solution:** Check Windows Event Viewer for errors

### Script stops after a while

**Problem:** Monitoring stops running after a few minutes
- **Solution:** Check Task Scheduler Settings → **Stop the task if it runs longer than** (should be unlimited)
- **Solution:** Verify there are no script errors in `logs/alerts.log`

### "Access Denied" error

**Problem:** PowerShell execution policy blocks the script
- **Solution:** Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force`
- **Solution:** Run PowerShell as Administrator

### Task shows "Last Result: 1" (Failed)

**Problem:** Task ran but encountered an error
- **Solution:** Check `logs/alerts.log` for error messages
- **Solution:** Verify file paths exist
- **Solution:** Check Windows Event Viewer → Application Logs

### Can't create task (Permission Denied)

**Problem:** You don't have admin privileges
- **Solution:** Right-click PowerShell and select **Run as Administrator**
- **Solution:** Ask your IT department for admin rights

---

## Advanced Configuration

### Change Run Interval

Edit `config/config.json`:

```json
{
  "scheduler": {
    "taskName": "NetworkMonitoringDashboard",
    "runInterval": 5,
    "runElevated": true
  }
}
```

Then recreate the task:
```powershell
. .\src\Setup-Scheduler.ps1
Remove-ScheduledMonitoring
Setup-ScheduledMonitoring
```

### Run as Different User

Edit the scheduled task in Task Scheduler GUI:
1. Right-click task → **Properties**
2. Click **Change User or Group**
3. Enter the username (e.g., `Administrator`, `\YourUsername`)
4. Click **OK**

### Monitor Output

Create a scheduled task output log:

```powershell
$taskName = "NetworkMonitoringDashboard"
$action = Get-ScheduledTask -TaskName $taskName | Get-ScheduledTaskInfo
```

---

## Next Steps

- Set up email alerts with [SETUP-EMAIL.md](SETUP-EMAIL.md)
- Adjust alert thresholds in `config/config.json`
- Monitor system performance in `logs/alerts.log`

---

## Security Considerations

🔒 **Best Practices:**
- Task runs as **SYSTEM** account (highest privileges)
- Script paths are hardcoded (no injection risk)
- Sensitive data stored in `config.json` (not committed to Git)
- Regular audit of scheduled tasks

❌ **Things to Avoid:**
- Don't store passwords in plain text
- Don't run with unnecessary privileges
- Don't expose script paths in URLs or logs
- Don't share scheduler configuration files

Questions? Check the main [README.md](../README.md)
