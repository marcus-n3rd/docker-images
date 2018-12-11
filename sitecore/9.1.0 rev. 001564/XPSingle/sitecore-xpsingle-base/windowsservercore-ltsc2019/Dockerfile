# escape=`
FROM microsoft/dotnet-framework:4.7.2-sdk-windowsservercore-ltsc2019

#BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
#
#	Global Definitions
#
#--------------------------------------------------------------------------------------------------------------------------

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV `
	INSTALL_PATH="c:\Install" `
	ACCEPT_EULA="Y" `
	sa_password="HASH-epsom-sunset-cost7!" `
	JAVA_HOME="c:\Java\jre" `
	SOLR_URL="https://solr:8983/solr" `
	SOLR_SERVICE_NAME="Solr-7.2.1" `
	SOLR_ROOT="c:\Solr\solr-7.2.1"

COPY /InternalAssets /ExternalAssets/ ${INSTALL_PATH}/

RUN `
`
`
<####################################################################################################################### `
`
	Install SQL Server `
`
------------------------------------------------------------------------------------------------------------------------#> `
`
	Write-Host "Downloading SQL Server. This will take some time as it is over 1.67GB..."; `
	Invoke-WebRequest -Uri https://go.microsoft.com/fwlink/?linkid=840944 -OutFile SQL.box; `
    Invoke-WebRequest -Uri https://go.microsoft.com/fwlink/?linkid=840945 -OutFile SQL.exe; `
	Write-Host "Installing SQL Server..."; `
    Start-Process -Wait -FilePath .\SQL.exe -ArgumentList /qs, /x:setup; `
    .\setup\setup.exe /q /ACTION=Install /INSTANCENAME=MSSQLSERVER /FEATURES=SQLEngine /UPDATEENABLED=0 /SQLSVCACCOUNT='NT AUTHORITY\System' /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' /TCPENABLED=1 /NPENABLED=0 /IACCEPTSQLSERVERLICENSETERMS; `
    Remove-Item -Recurse -Force SQL.exe, SQL.box, setup `
;

RUN `
`
`
<####################################################################################################################### `
`
	Configure SQL Server `
`
------------------------------------------------------------------------------------------------------------------------#> `
`
	Stop-Service MSSQLSERVER; `
    Set-ItemProperty -Path 'HKLM:\software\microsoft\microsoft sql server\mssql14.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall' -Name tcpdynamicports -Value ''; `
    Set-ItemProperty -Path 'HKLM:\software\microsoft\microsoft sql server\mssql14.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall' -Name tcpport -Value 1433; `
    Set-ItemProperty -Path 'HKLM:\software\microsoft\microsoft sql server\mssql14.MSSQLSERVER\mssqlserver' -Name LoginMode -Value 2; `
    start-service MSSQLSERVER; `
	`
	Write-Host 'Changing SA login credentials' ; `
	$sql = 'ALTER LOGIN sa with password=N'''+ $env:sa_password +'''; ALTER LOGIN sa ENABLE;' ; `
	Invoke-Sqlcmd -Query $sql `
;

RUN `
`
`
<####################################################################################################################### `
`
	Java and Solr `
`
------------------------------------------------------------------------------------------------------------------------#> `
`
	<# Java #> `
	Write-Host 'Start: Downloading Java' ; `
	Invoke-WebRequest -Method Get -Uri http://javadl.oracle.com/webapps/download/AutoDL?BundleId=210185 -OutFile /jreinstaller.exe ; `
	Write-Host 'End: Downloading Java' ; `
	Write-Host 'Start: Installing Java' ; `
    Start-Process -FilePath C:\jreinstaller.exe -PassThru -wait -ArgumentList "/s,INSTALLDIR=c:\Java\jre"; `
	Write-Host 'Deleting Java setup file.' ; `
 	Remove-Item -Recurse -Force C:\jreinstaller.exe ; `
	Write-Host 'End: Installing Java' ; `
	Write-Host 'Start: Updating PATH environment variable' ; `
	$newPath = Join-Path $env:JAVA_HOME 'bin' ; `
	$newPath = '{0};{1}' -f $env:JAVA_HOME, $newPath ; `
	$env:PATH = '{0};{1}' -f $newPath, $env:PATH ; `
	[Environment]::SetEnvironmentVariable('PATH', $env:PATH, 'Machine') ; `
	Write-Host 'End: Updating PATH environment variable' ; `
	`
	<# Solr #> `
	Set-Location -Path (Join-Path $env:INSTALL_PATH 'solr') ; `
	Write-Host 'Start: Installing Solr' ; `
	./install-solr.ps1 -downloadFolder $env:INSTALL_PATH; `
	Write-Host 'End: Installing Solr' ; `
	`
	<# Clean-up #> `
	Set-Location -Path 'C:\' ; `
	Remove-Item (Join-Path $env:INSTALL_PATH 'solr') -Force -Recurse; `
;

RUN `
`
`
<####################################################################################################################### `
`
	Sitecore Installation Framework (SIF) `
`
------------------------------------------------------------------------------------------------------------------------#> `
`
    Install-PackageProvider -Name NuGet -Force | Out-Null ; `
    Register-PSRepository -Name SitecoreGallery -SourceLocation https://sitecore.myget.org/F/sc-powershell/api/v2 ; `
    Install-Module SitecoreInstallFramework -Force ; `
;

RUN `
`
`
<####################################################################################################################### `
`
	Install Sitecore Prerequisites `
`
------------------------------------------------------------------------------------------------------------------------#> `
`
	Install-SitecoreConfiguration -Path (Join-Path $env:INSTALL_PATH 'Prerequisites.json') `
;

RUN `
`
`
<####################################################################################################################### `
`
	Install Service Monitor `
`
------------------------------------------------------------------------------------------------------------------------#> `
`
	Invoke-WebRequest https://dotnetbinaries.blob.core.windows.net/servicemonitor/1342334/ServiceMonitor.exe -OutFile C:\ServiceMonitor.exe `
;

#BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
#
#	Docker Image Metadata
#
#--------------------------------------------------------------------------------------------------------------------------

# TODO: Implement HEALTHCHECK
# SQL
#HEALTHCHECK CMD [ "sqlcmd", "-Q", "select 1" ]
# Solr
#HEALTHCHECK CMD powershell -command `
#    try { `
#        $response = Invoke-WebRequest $env:SOLR_URL -UseBasicParsing ; `
#        if ($response.StatusCode -eq 200) { return 0} else {return 1} ; `
#    } catch { return 1 }


# RELEASE: Use next line for image release (reduce number of layers). See "DEBUG" comments below
ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]

# IIS: 80, 443
# Solr: 8983
# SQL: 1433
EXPOSE 80 443 8983 1433
