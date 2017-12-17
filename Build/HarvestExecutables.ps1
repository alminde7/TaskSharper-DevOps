param(
    [switch]$IsNuget = $false
)

function CopyTo 
{
    param(
        [string]$TargetPath,
        [string]$Directory,
        [string]$Source
    )

    $targetCombined = [System.IO.Path]::Combine($TargetPath, $Directory)

    Write-Host "Copying from $Source to $targetCombined"

    if(Test-Path -Path $targetCombined)
    {
        Write-Host "$targetCombined already exist. Removing it and re-creating."
        Remove-Item -Path $targetCombined -Force -Recurse -ErrorAction Stop
    }

    Write-Host "Creating $targetCombined"

    New-Item -Path $targetCombined -ItemType Directory -ErrorAction Stop


    Write-Host "Copying item from $Source to $targetCombined"
    Copy-Item -Path $($Source + "\*") -Destination $targetCombined -Recurse -Force -ErrorAction Stop

    Write-Host "Directory: $Directory"
}

function SetupTarget
{
    param(
        [string]$base,
        [string]$dir,
        [string]$filter,
        [string]$subPath
    )

    $path = [System.IO.Path]::Combine($base, $dir)

    if(!(Test-Path -Path $path))
    {
        New-Item -Path $path -ItemType Directory -ErrorAction Stop
    }

    $returnValue = New-Object psobject | 
                Add-Member NoteProperty -Name "Path" -Value $path -PassThru |
                Add-Member NoteProperty -Name "SubPath" -Value $subPath -PassThru |
                Add-Member NoteProperty -Name "Filter" -Value $filter -PassThru
    
    return $returnValue
}

$target = ".\Artifacts\"
#$subPath = "bin\Release"
$subPath = "bin\BuildAllExceptUITests"
$source = Get-Location

$harvestItems = @()

$harvestItems += (SetupTarget -base $target -dir "Service" -filter "*.Service" -subPath $subPath)
$harvestItems += (SetupTarget -base $target -dir "Rest" -filter "*.API.Rest" -subPath $subPath)
$harvestItems += (SetupTarget -base $target -dir "SOAP" -filter "*.API.SOAP" -subPath $subPath)
$harvestItems += (SetupTarget -base $target -dir "Web" -filter "*.Web" -subPath $subPath)
$harvestItems += (SetupTarget -base $target -dir "WPF" -filter "*.WPF" -subPath $subPath)
$harvestItems += (SetupTarget -base $target -dir "NugetPackageSource" -filter "ONLY_A_DUMMY_FOR_NOW" -subPath $subPath)
$harvestItems += (SetupTarget -base $target -dir "Test/Unit" -filter "*Test.Unit" -subPath $subPath)
$harvestItems += (SetupTarget -base $target -dir "Test/Integration" -filter "*Test.Integration" -subPath $subPath)
$harvestItems += (SetupTarget -base $target -dir "Test/Acceptance" -filter "*Test.Acceptance" -subPath $subPath)
## OBS missing guidance about nuget packages

$folders = Get-ChildItem $source -Attributes D #for Directory

$foundItem = $false

foreach($folder in $folders)
{
    foreach($item in $harvestItems)
    {
        [string]$filter = $item.Filter
        
        switch -Wildcard ($folder.Name.ToLower())
        {
            $filter
            {
                $foundItem = $true

                $sourceFolder = [System.IO.Path]::Combine($folder.FullName, $item.SubPath)
                
                CopyTo -TargetPath $item.Path -Directory $folder.Name -Source $sourceFolder
            }
        }
    }
}

## Temporary longterm fix
if($IsNuget)
{
    $path = [System.IO.Path]::Combine($source, $env:GO_PIPELINE_NAME)

    $sourceFolder = [System.IO.Path]::Combine($path, $subPath)
    
    if(!(Test-Path -Path $sourceFolder))
    {
        New-Item -Path $sourceFolder -ItemType Directory -ErrorAction Stop
    }

    $targetPath = [System.IO.Path]::Combine($target, "NugetPackageSource")

    CopyTo -TargetPath $targetPath -Directory $path.Name -Source $sourceFolder

    $foundItem = $true
}

if(!$foundItem){
    throw "Found no items to harvest"
}
