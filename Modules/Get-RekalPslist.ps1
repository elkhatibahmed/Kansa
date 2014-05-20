﻿# OUTPUT txt
# BINDEP rekall.zip
<#
.SYNOPSIS
Get-RekalPslist.ps1
When run via Kansa.ps1 with -Pushbin flag, this module will install the WinPMem driver on remote
systems, then run Rekall to collect the process listing from memory.
#>

# Expand-Zip does what the name implies, here for reference, used by Get-FlsBodyfile.ps1
Function Expand-Zip ($zipfile, $destination) {
    $shell = New-Object -ComObject shell.application
    $zip = $shell.Namespace($zipfile)
    foreach($item in $zip.items()) {
        $shell.Namespace($destination).copyhere($item)
    }
}    

$rkpath = ($env:SystemRoot + "\rekall.zip")

if (Test-Path ($rkpath)) {
    $suppress = New-Item -Name rekall -ItemType Directory -Path $env:Temp -Force
    $rkdest = ($env:Temp + "\rekall\")
    Expand-Zip $rkpath $env:Temp
    if (Test-Path($rkdest + "\rekal.exe")) {
        $suppress = & $rkdest\winpmem_1.5.5.exe -l
        & $rkdest\rekal.exe -f \\.\pmem pslist
        $suppress = & $rkdest\winpmem_1.5.5.exe -u
        $suppress = Remove-Item $rkdest -Force -Recurse
    } else {
        "rekall.zip found, but not unzipped."
    }
} else {
    "rekall.zip not found on $env:COMPUTERNAME"
}