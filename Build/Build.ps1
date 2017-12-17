# param(
#     [string] $project = $(throw "$project is required"),
#     [string] $command = "Build",
#     [string] $buildConfig = "Release",
#     [string] $runtimeVersion = "v4.0",
#     [System.IO.Path] $outputDirectory = ""
# )

Import-Module -Name "$PSScriptRoot\..\Modules\External\Invoke-MsBuild\2.6.0\Invoke-MsBuild.psm1"
Import-Module -Name "$PSScriptRoot\..\Modules\Homemade\Github.psm1"


# OBS!! Convention here... pipelineName has to be the same name as the directory where the executable is residing.
# can be changed to be taking in as a parameter. 
[string] $command = "Build"
#[string] $buildConfig = "Release"
[string] $buildConfig = "BuildAllExceptUITests"
[string] $runtimeVersion = "v4.0"
[string] $visualStudioVersion = "15.0"

$currentLocation = Get-Location

#Find solution
$solution = Get-ChildItem -Path $currentLocation -Filter "*.sln" -Recurse

if (!$solution) 
{
    throw "Could not find a solution"
}

# Build
$buildResult = Invoke-MsBuild -Path $solution.FullName -Params "/t:$command /p:Configuration=$buildConfig;TargetFramework=$runtimeVersion;VisualStudioVersion=$visualStudioVersion" -ShowBuildOutputInCurrentWindow

if ($buildResult.BuildSucceeded -eq $true) 
{
    Write-Output ("Build completed successfully in {0:N1} seconds." -f $buildResult.BuildDuration.TotalSeconds)
    
}
elseif ($buildResult.BuildSucceeded -eq $false) 
{
    Write-Output ("Build failed after {0:N1} seconds. Check the build log file '$($buildResult.BuildLogFilePath)' for errors." -f $buildResult.BuildDuration.TotalSeconds)
    throw "Build did not succeed"
}
elseif ($buildResult.BuildSucceeded -eq $null) 
{
    throw "Unsure if build passed or failed: $($buildResult.Message)"
}