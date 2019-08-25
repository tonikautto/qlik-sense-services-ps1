#Requires -RunAsAdministrator

param (
    [string] $ComputerName  = $null        # Hostname for remote control
)

if(-Not "$ComputerName") {
    $ComputerName = $env:computername   
}

$QlikLoggingService  = Get-Service "QlikLoggingService" -ComputerName "$ComputerName"
$QlikSenseRepository = Get-Service "QlikSenseRepositoryDatabase" -ComputerName "$ComputerName"
$QlikSenseDispatcher = Get-Service "QlikSenseServiceDispatcher" -ComputerName "$ComputerName"
$QlikSenseServices   = Get-Service "QlikSense*" -ComputerName "$ComputerName"  | `
                       Where-Object {($_.Name -notlike "QlikSenseRepositoryDatabase" -and $_.Name -notlike "QlikSenseServiceDispatcher")}

# Start all services it required order
$QlikSenseRepository | Set-Service -Status Running -Force
$QlikLoggingService | Set-Service -Status Running -Force
$QlikSenseDispatcher | Set-Service -Status Running -Force
$QlikSenseServices | Set-Service -Status Running -Force
