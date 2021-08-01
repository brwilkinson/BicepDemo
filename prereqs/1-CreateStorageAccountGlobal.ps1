param (
    [String]$APP = 'HUB'
)

$ArtifactStagingDirectory = "$PSScriptRoot\.."
$PrefixLookup = Get-Content $Artifacts\release\prefix.json | ConvertFrom-Json

$Global = Get-Content -Path $ArtifactStagingDirectory\tenants\$App\Global-Global.json | ConvertFrom-Json -Depth 10 | ForEach-Object Global
$GlobalRGName = $Global.GlobalRGName
$PrimaryLocation = $PrefixLookup | foreach $Global.PrimaryLocation | foreach location
$StorageAccountName = $Global.SAName

Write-Verbose -Message "Global RGName: $GlobalRGName" -Verbose
if (! (Get-AzResourceGroup -Name $GlobalRGName -EA SilentlyContinue))
{
    try
    {
        New-AzResourceGroup -Name $GlobalRGName -Location $PrimaryLocation -ErrorAction stop
    }
    catch
    {
        Write-Warning $_
        break
    }
}

Write-Verbose -Message "Global SAName: $StorageAccountName" -Verbose
if (! (Get-AzStorageAccount -EA SilentlyContinue | where StorageAccountName -eq $StorageAccountName))
{
    try
    {
        # Create the global storage acounts
        ## Used for File and Blob Storage for assets/artifacts
        New-AzStorageAccount -ResourceGroupName $GlobalRGName -Name ($StorageAccountName).tolower() `
            -SkuName Standard_RAGRS -Location $PrimaryLocation -Kind StorageV2 -EnableHttpsTrafficOnly $true -ErrorAction stop
    }
    catch
    {
        Write-Warning $_
        break
    }
}

