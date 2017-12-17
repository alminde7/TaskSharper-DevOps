

### Restore Nuget pakcages
$scriptRoot = (get-item $PSScriptRoot).parent.FullName
$nugetExe = Get-ChildItem -Path $scriptRoot -Filter "nuget.exe" -Recurse
if(!$nugetExe) {throw "Could not locate 'nuget.exe' - Unable to restore packages"}

Write-Host $nugetExe.FullName

$currentLocation = Get-Location
Write-Host $currentLocation

$solution = Get-ChildItem -Path $currentLocation -Filter "*.sln" -Recurse

Write-Host $solution.FullName

if(!$solution){
    throw "Could not find a solution"
}

& $nugetExe.FullName restore $solution.FullName
####