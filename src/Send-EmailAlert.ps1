<#
.SYNOPSIS
    Sends email alerts when system metrics exceed thresholds
.DESCRIPTION
    Sends formatted email notifications via SMTP
.PARAMETER AlertType
    Type of alert (CPU, Memory, Disk, Network)
.PARAMETER AlertMessage
    Message to include in alert
.PARAMETER EmailFrom
    Sender email address
.PARAMETER EmailTo
    Recipient email address
.PARAMETER SmtpServer
    SMTP server address
.PARAMETER SmtpPort
    SMTP port (usually 587 for TLS)
.PARAMETER EmailPassword
    SMTP password (use app-specific password for Gmail)
.PARAMETER Severity
    Severity level (Warning, Critical)
#>

function Send-EmailAlert {
    param(
        [Parameter(Mandatory=$true)]
        [string]$AlertType,
        
        [Parameter(Mandatory=$true)]
        [string]$AlertMessage,
        
        [Parameter(Mandatory=$true)]
        [string]$EmailFrom,
        
        [Parameter(Mandatory=$true)]
        [string]$EmailTo,
        
        [Parameter(Mandatory=$true)]
        [string]$SmtpServer,
        
        [Parameter(Mandatory=$true)]
        [int]$SmtpPort,
        
        [Parameter(Mandatory=$true)]
        [securestring]$EmailPassword,
        
        [ValidateSet("Warning", "Critical")]
        [string]$Severity = "Warning"
    )

    try {
        # Create SMTP client
        $smtpClient = New-Object System.Net.Mail.SmtpClient($SmtpServer, $SmtpPort)
        $smtpClient.EnableSsl = $true
        
        # Create credentials
        $credentials = New-Object System.Management.Automation.PSCredential($EmailFrom, $EmailPassword)
        $smtpClient.Credentials = $credentials

        # Create email message
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $subject = "[$Severity] Network Monitoring Alert - $AlertType"
        $body = @"
Alert Type: $AlertType
Severity: $Severity
Time: $timestamp
Computer: $env:COMPUTERNAME

Details:
$AlertMessage

---
Network Monitoring Dashboard
Automated System Alerts
"@

        $mailMessage = New-Object System.Net.Mail.MailMessage($EmailFrom, $EmailTo)
        $mailMessage.Subject = $subject
        $mailMessage.Body = $body
        $mailMessage.IsBodyHtml = $false

        # Send email
        $smtpClient.Send($mailMessage)
        
        Write-Host "[EMAIL SENT] $subject" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to send email alert: $_"
        return $false
    }
    finally {
        if ($mailMessage) { $mailMessage.Dispose() }
        if ($smtpClient) { $smtpClient.Dispose() }
    }
}
