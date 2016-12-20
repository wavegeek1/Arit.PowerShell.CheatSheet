
 
Begin { 
 
 $array0 = @()
 $array1 = @()
 
 # Sets location of APPCMD.exe
 Set-Location "c:\windows\system32\inetsrv\"
 } 
 
 Process{ 
 
 if((Get-ItemProperty -ErrorAction SilentlyContinue "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v2.0.50727").Version -like "2.*") {
 $array0 += "2.0"
 }
 if((Get-ItemProperty -ErrorAction SilentlyContinue "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v3.0\Setup").Version -like "3.0*") {
 $array0 += "3.0"
 }
 if((Get-ItemProperty -ErrorAction SilentlyContinue "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v3.5").Version -like "3.5*") {
 $array0 += "3.5"
 }
 if((Get-ItemProperty -ErrorAction SilentlyContinue "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full").Version -like "4.0*") {
 $array0 += "4.0"
 }
 if((Get-ItemProperty -ErrorAction SilentlyContinue "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full").Version -like "4.5*") {
 $array0 += "4.5"
 } 
 
[String]$dotNet = $array0
 
 $compInfo = gwmi win32_computersystem | Select DNSHostName,Domain, SystemType, TotalPhysicalMemory, NumberOfProcessors
 $osInfo = gwmi win32_operatingsystem | Select Caption, ServicePackMajorVersion
 
 $tmpObj = New-Object Object
 $tmpObj | add-member -membertype noteproperty -name "DNS HostName" -Value $compInfo.DNSHostName
 $tmpObj | add-member -membertype noteproperty -name "Operating System" -value $osInfo.Caption
 $tmpObj | add-member -membertype noteproperty -name "Service Pack Level" -value $osInfo.ServicePackMajorVersion
 $tmpObj | add-member -membertype noteproperty -name "Architecture" -value $compInfo.SystemType
 $tmpObj | add-member -membertype noteproperty -name "Total Physical Memory (GB)" -value ("{0:N2}" -f($compInfo.TotalPhysicalMemory/1GB))
 $tmpObj | add-member -membertype noteproperty -name "Number Of Processors" -value $compInfo.NumberOfProcessors
 $tmpObj | add-member -membertype noteproperty -name "Installed versions .NET" -value $dotNet
 $tmpObj | add-member -membertype noteproperty -name "Domain" -value $compInfo.Domain
 
 #Populate Array with Object properties
 $array1 += $tmpObj | Format-List | Out-String
 $array1
 
[XML]$sites = .\appcmd list Site /config:* /XML
$site1 = $sites.SelectNodes("//SITE")
$sitesOutput = $site1 | Format-Table -AutoSize | Out-String
$sitesOutput
 
[XML]$app = .\appcmd list app /config:* /XML
$app1 = $app.appcmd.APP | Select-Object -Property path, APP.NAME, APPPOOL.NAME, SITE.NAME
$appOutput = $app1 | Format-Table -AutoSize | Out-String
$appOutput
 
[XML]$vDir = .\appcmd list VDIR /config:* /XML
$vDir1 = $vDir.SelectNodes("//VDIR") | Select-Object -Property VDIR.NAME, APP.NAME,physicalPath
$vDirOutput = $vDir1 | Format-Table -AutoSize | Out-String
$vDirOutput
 
#Retrieve app pool summary config
[XML]$poolNames = .\appcmd list apppool /config:* /XML
$poolNames1 = $poolNames.appcmd.APPPOOL | Select-Object -Property APPPOOL.NAME,PipelineMode,RuntimeVersion,State
$poolOutput = $poolNames1 | Format-Table -AutoSize | Out-String
$poolOutput
 
#Retrieve detailed app pool config
$poolAdv = $poolNames.SelectNodes("//add")
$poolAdv1 = $PoolAdv | Select-Object -Property Name, QueueLength, AutoStart, Enable32BitAppOnWin64, ManagedRuntimeVersion, ManagedRuntimeLoader, EnableConfigurationOverride, ManagedPipelineMode, PassAnonymousToken, StartMode
$poolAdvOutput = $poolAdv1 | Format-Table -AutoSize | Out-String
$poolAdvOutput
$poolidentities = Get-WmiObject -Namespace "root\MicrosoftIISV2" -Class "IIsApplicationPoolSetting" | Select WAMUserName, WAMUserPass
$poolidentitiesout = $poolidentities | Format-Table -AutoSize | Out-String
$poolidentitiesout

 
}#End process 
 
 End{
 #Display results
 $log = "C:\" + $env:ComputerName + "_IIS7_Config.txt"
 Out-File -FilePath $log -Encoding UTF8
 Add-Content -Path $log -Value "Script executed by: $env:username"
 Add-Content -Path $log -Value $array1
 Add-Content -Path $log -Value $sitesOutput
 Add-Content -Path $log -Value $appOutput
 Add-Content -Path $log -Value $$vDirOutput
 Add-Content -Path $log -Value $poolOutput
 Add-Content -Path $log -Value $poolAdvOutput
 Add-Content -Path $log -Value $poolidentitiesout
 } 