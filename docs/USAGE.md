\# Usage Guide



\## Running the Dashboard



\### Basic Single Check



Performs one monitoring cycle and displays results:



```powershell

.\\src\\Monitor-Network.ps1

```



\*\*Output:\*\*

```

========================================

&#x20;  Network Monitoring Dashboard

========================================



\[Iteration 1] 2024-01-15 14:30:45

CPU Usage:    45%

Memory Usage: 62% (10.5GB / 16GB)

Disk Usage:   55%

```



\### Continuous Monitoring



Runs continuous monitoring with alerts (Ctrl+C to stop):



```powershell

.\\src\\Monitor-Network.ps1 -Continuous

```



The script will:

1\. Check metrics

2\. Compare against thresholds

3\. Log any alerts to `logs/alerts.log`

4\. Wait for the configured interval (default: 300 seconds)

5\. Repeat



\### Using Custom Configuration



```powershell

.\\src\\Monitor-Network.ps1 -ConfigPath ".\\config\\config-custom.json" -Continuous

```



\## Understanding the Output



\### Healthy System



```

\[Iteration 1] 2024-01-15 14:30:45

CPU Usage:    35%

Memory Usage: 50% (8.0GB / 16GB)

Disk Usage:   65%

```



All metrics are below thresholds - no action needed.



\### Alert Generated



```

\[2024-01-15 14:30:45] \[Critical] \[CPU] CPU usage is at 85% (Threshold: 80%)

```



Alert appears in console and is logged to `logs/alerts.log`.



\## Configuration Options



\### Monitoring Intervals



Adjust how frequently checks run:



```json

"monitoring": {

&#x20;   "checkInterval": 300  // Check every 5 minutes (300 seconds)

}

```



Common values:

\- `30` - Every 30 seconds (frequent)

\- `300` - Every 5 minutes (recommended)

\- `900` - Every 15 minutes (less frequent)



\### Alert Thresholds



Customize when alerts are triggered:



```json

"monitoring": {

&#x20;   "cpuThreshold": 80,          // 80% CPU usage

&#x20;   "memoryThreshold": 85,       // 85% RAM usage

&#x20;   "diskThreshold": 90          // 90% disk usage

}

```



\### Monitoring Targets



Configure which systems to monitor:



```json

"monitoring\_targets": {

&#x20;   "localComputer": "localhost",

&#x20;   "remoteServers": \[

&#x20;       "192.168.1.1",

&#x20;       "192.168.1.2"

&#x20;   ],

&#x20;   "monitoredProcesses": \[

&#x20;       "svchost",

&#x20;       "explorer"

&#x20;   ]

}

```



\## Viewing Alerts



All alerts are logged to `logs/alerts.log`:



```powershell

\# View recent alerts

Get-Content .\\logs\\alerts.log -Tail 20



\# Search for critical alerts

Select-String "Critical" .\\logs\\alerts.log

```



Example alert log:

```

\[2024-01-15 14:30:45] \[Critical] \[CPU] CPU usage is at 85% (Threshold: 80%)

\[2024-01-15 14:31:00] \[Warning] \[Disk] Disk usage is at 92% (Threshold: 90%)

\[2024-01-15 14:32:15] \[Critical] \[Memory] Memory usage is at 88% (Threshold: 85%)

```



\## Real-World Scenarios



\### Scenario 1: Monitoring a Development Server



```json

{

&#x20; "monitoring": {

&#x20;   "checkInterval": 900,           // Check every 15 minutes

&#x20;   "cpuThreshold": 85,             // More lenient for dev

&#x20;   "memoryThreshold": 90,

&#x20;   "diskThreshold": 95

&#x20; }

}

```



Run with:

```powershell

.\\src\\Monitor-Network.ps1 -ConfigPath ".\\config\\config-dev.json" -Continuous

```



\### Scenario 2: Monitoring a Production Server



```json

{

&#x20; "monitoring": {

&#x20;   "checkInterval": 60,            // Check every minute

&#x20;   "cpuThreshold": 70,             // Stricter thresholds

&#x20;   "memoryThreshold": 75,

&#x20;   "diskThreshold": 80

&#x20; }

}

```



\### Scenario 3: Automated Monitoring with Task Scheduler



Schedule the script to run automatically:



```powershell

\# Create a task that runs every 5 minutes

$trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 5) -Once -At (Get-Date)

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File 'C:\\path\\to\\Monitor-Network.ps1' -Continuous"

Register-ScheduledTask -TaskName "SystemMonitoring" -Trigger $trigger -Action $action -RunLevel Highest

```



\## Tips \& Best Practices



1\. \*\*Run with Administrator Privileges\*\* - Required for WMI queries

2\. \*\*Review Logs Regularly\*\* - Check `logs/alerts.log` for patterns

3\. \*\*Adjust Thresholds to Your Environment\*\* - One size doesn't fit all

4\. \*\*Use Continuous Mode for Production\*\* - Better catch issues

5\. \*\*Set Up Task Scheduler\*\* - Automate ongoing monitoring



\## Troubleshooting



\### No output after running



\- Ensure you're in the project root directory

\- Check that PowerShell execution policy allows scripts

\- Run as Administrator



\### Alerts not logging



\- Check `logs/` directory exists (created automatically)

\- Verify write permissions to the logs directory

\- Check for errors in console output



\### High false-positive alerts



\- Increase threshold values in config.json

\- Run longer to establish baseline metrics

\- Identify and exclude resource-heavy applications



\## Support



For issues or questions, review the README.md or check the setup instructions in SETUP.md.

