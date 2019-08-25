#Requires -RunAsAdministrator

# MIT License
#
# Copyright (c) 2019 Toni Kautto
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

<#
.SYNOPSIS
    Stop Qlik Sense related services on a specific Qlik Sense node. 
.DESCRIPTION
    Stop Qlik Sense related services on a specific Qlik Sense node. 
    By default services on local server are addressed, by the script 
    can also remotely conenct to Qlik Sense nodes.
    Remote access requires that the execuring user is allowed to access 
    remote server and also allowed to alter Services.  
.PARAMETER ComputerName
    Hostname of Qlik Sense node to stop services on. 
    By default local Windows hostname is used. 
.PARAMETER IncludeRepository
    Switch to also stop Qlik Sense Repositiry Database (QRD). 
    By default QRD is not stopped. 
.EXAMPLE
    ./Stop-Qlik-Sense-Services.ps1 
    Calling script without parameters stops all Qlik Sense services on the local server. 
    Qlik Sense Repository Service is excluded, and left running. 
.EXAMPLE
    ./Stop-Qlik-Sense-Services.ps1 -ComputerName "qlikserver1.domain.local"
    Stops all Qlik Sense services on remote computer "qlikserver1.domain.local". 
    Qlik Sense Repository Service is excluded, and left running. 
.EXAMPLE
    ./Stop-Qlik-Sense-Services.ps1 -ComputerName "qlikserver1.domain.local" -IncludeRepository
    Stops all Qlik Sense services on remote computer "qlikserver1.domain.local". 
    Also stops Qlik Sense Repository Database service. 
.NOTES
    Must be run As Adminstrator
#>

param (
    [string] $ComputerName  = $null,        # Hostname for remote control
    [switch] $IncludeRepository = $false    # Flag if QRD also should be stopped
)

if(-Not "$ComputerName") {
    $ComputerName = $env:computername   
}

if($IncludeRepository) {

    $QlikServices = Get-Service "Qlik*" -ComputerName "$ComputerName" | `
                    Where-Object { ( ($_.Name -like "QlikSense*" -or $_.Name -like "QlikLogging*") )}    

} else {

    $QlikServices = Get-Service "Qlik*" -ComputerName "$ComputerName" | `
                    Where-Object { ( ($_.Name -like "QlikSense*" -or $_.Name -like "QlikLogging*") `
                                     -and $_.Name -notlike "QlikSenseRepositoryDatabase" )}    

}

# Stop all found services 
$QlikServices | Set-Service -Status Stopped -Force