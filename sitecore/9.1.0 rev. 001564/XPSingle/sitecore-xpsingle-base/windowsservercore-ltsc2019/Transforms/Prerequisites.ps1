param(
    [Parameter(Mandatory = $true)]
    [ValidateScript( {Test-Path $_ -PathType  'Leaf'})] 
    [string]$SourcePath,
    [Parameter(Mandatory = $true)]
    [ValidateScript( {Test-Path $_ -IsValid})] 
    [string]$TargetPath
)

$config = Get-Content $SourcePath | Where-Object { $_ -notmatch '^\s*\/\/'} | Out-String | ConvertFrom-Json;

$config.Tasks.WindowsFeatures.Params.FeatureName = $config.Tasks.WindowsFeatures.Params.FeatureName | Where-Object { $_ -ne "IIS-ASPNET" -And $_ -ne "WAS-NetFxEnvironment" }

ConvertTo-Json $config -Depth 50 | Set-Content -Path $TargetPath ;
