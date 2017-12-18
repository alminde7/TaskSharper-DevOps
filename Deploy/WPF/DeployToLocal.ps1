Import-Module -Name "$PSScriptRoot\DeployApplications.psm1"

#$dataPath = "C:\Users\Alminde\Desktop\GoData"
$dataPath = "./"

# BasePath
$localBasePath = "C:\Applications"

# Find applications to deploy
$serviceTypes = Get-ChildItem $dataPath -directory -ErrorAction Stop

## Service/API/WPF/Web
foreach($service in $serviceTypes)
{
    Write-Host "Searching for applications in folder: $($service.Name)"
    $applications = Get-ChildItem $service.Fullname -directory -ErrorAction Stop

    ## each application
    foreach($application in $applications)
    {
        Write-Host "Deploying application $($application.Name)"
        $applicationPath = Copy-Files -basePath $localBasePath -application $application -serviceType $service.Name
        Write-Host "Path to $($application.Name) is: $applicationPath"
    }
}