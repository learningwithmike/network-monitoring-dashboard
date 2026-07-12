!\[PowerShell](https://img.shields.io/badge/PowerShell-5.0+-blue?logo=powershell)

!\[License](https://img.shields.io/badge/license-MIT-green)

!\[Status](https://img.shields.io/badge/status-active-success)



\# Network Monitoring Dashboard



A PowerShell-based network and system monitoring solution designed for IT support professionals to track real-time performance metrics and receive alerts when thresholds are exceeded.



\## Features



\- ✅ \*\*Real-Time Monitoring\*\* - Continuous CPU, Memory, and Disk usage tracking

\- ✅ \*\*Configurable Alerts\*\* - Set custom thresholds for different metrics

\- ✅ \*\*Alert Logging\*\* - All alerts are logged to file for compliance and troubleshooting

\- ✅ \*\*Easy Configuration\*\* - JSON-based config file for simple customization

\- ✅ \*\*Performance Metrics\*\* - Network statistics and system health overview

\- ✅ \*\*Error Handling\*\* - Robust error handling and logging



\## Project Structure



```

network-monitoring-dashboard/

├── src/                          # Main PowerShell scripts

│   ├── Monitor-Network.ps1       # Main monitoring script

│   ├── Get-SystemMetrics.ps1     # System metrics collection

│   └── Send-Alert.ps1            # Alert handling

├── config/

│   └── config.json               # Configuration file

├── docs/

│   ├── SETUP.md                  # Setup instructions

│   └── USAGE.md                  # Usage guide

├── logs/                         # Alert logs directory

└── README.md                     # This file

```



\## Quick Start



\### Prerequisites



\- Windows PowerShell 5.0 or higher

\- Administrator privileges

\- Network access to monitored systems



\### Installation



1\. \*\*Clone the repository:\*\*

&#x20;  ```powershell

&#x20;  git clone https://github.com/learningwithmike/network-monitoring-dashboard.git

&#x20;  cd network-monitoring-dashboard

&#x20;  ```



2\. \*\*Configure settings (optional):\*\*

&#x20;  - Edit `config/config.json` to set your preferred thresholds

&#x20;  - Default thresholds: CPU 80%, Memory 85%, Disk 90%



3\. \*\*Run the dashboard:\*\*

&#x20;  ```powershell

&#x20;  # Single check

&#x20;  .\\src\\Monitor-Network.ps1



&#x20;  # Continuous monitoring (Ctrl+C to stop)

&#x20;  .\\src\\Monitor-Network.ps1 -Continuous

&#x20;  ```



\## Configuration



Edit `config/config.json` to customize:



\- \*\*checkInterval\*\* - Time between checks (seconds)

\- \*\*cpuThreshold\*\* - CPU usage alert threshold (%)

\- \*\*memoryThreshold\*\* - Memory usage alert threshold (%)

\- \*\*diskThreshold\*\* - Disk usage alert threshold (%)



\## Usage Examples



\### Single System Check

```powershell

.\\src\\Monitor-Network.ps1

```



\### Continuous Monitoring

```powershell

.\\src\\Monitor-Network.ps1 -Continuous

```



\### Custom Configuration

```powershell

.\\src\\Monitor-Network.ps1 -ConfigPath ".\\config\\config-custom.json" -Continuous

```



\## Alert System



When metrics exceed configured thresholds:

\- Alert is logged to `logs/alerts.log`

\- Console displays alert with timestamp and severity level

\- Critical alerts appear in red, warnings in yellow



Example alert output:

```

\[2024-01-15 14:32:45] \[Critical] \[CPU] CPU usage is at 85% (Threshold: 80%)

```



\## Skills Demonstrated



This project demonstrates proficiency in:

\- PowerShell scripting and automation

\- System administration and monitoring

\- Performance tuning and troubleshooting

\- Configuration management

\- Error handling and logging

\- Git version control



\## Future Enhancements



\- \[ ] Email alert notifications

\- \[ ] Database logging for historical analysis

\- \[ ] Web dashboard for visualization

\- \[ ] Remote system monitoring

\- \[ ] Scheduled task integration



\## License



This project is open source and available under the MIT License.



\## Author



\*\*Learning with Mike\*\*  

Entry-level IT Support Professional



\---



\*This project is part of my professional portfolio demonstrating automation and monitoring expertise.\*

