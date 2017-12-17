param(
    [switch] $allowNoTest = $false
)

$pipelineName = $env:GO_PIPELINE_NAME
$scriptRoot = (get-item $PSScriptRoot).parent.FullName

# Find Binaries 
$nunit = [System.IO.Path]::Combine($scriptRoot, "Binaries\Nunit3")
if (!(Test-Path $nunit)) {throw "Could not find Nunit3 path"}
$nunitExe = Get-ChildItem -Path $nunit -Filter "nunit3-console.exe"
if (!$nunitExe) {throw "Could not locate 'nunit3-console.exe'"}
Write-Host "nunit3-console has been located on location: $($nunitExe.FullName)"
#

$currenLocation = Get-Location
$source = [System.IO.Path]::Combine($currenLocation, "Test")

$folders = Get-ChildItem -Path $source -Directory -ErrorAction Stop

$foundTests = $false

foreach($folder in $folders)
{
    $testFile = Get-ChildItem -Path $folder.FullName -Filter "*.Test.*.dll" -Recurse

    foreach($test in $testFile)
    {
        $foundTests = $true

        Write-Host "Found test file: $($test.Name)"
        
        $testFileName = $test.Name.TrimEnd(".dll")
        $testResultName = "$testFileName.Result.xml"

        # Note on "format=nunit2"
        ## Go can only interpret the nunit2 format, that is why nunit3 test results tests will be saved as nunit2
        & $nunitExe.FullName $test.FullName --result:"$testResultName;format=nunit2"
    
        Copy-Item $testResultName .\TestResults
    
        # Note on $LASTEXITCODE: https://stackoverflow.com/questions/25275960/find-exit-code-for-executing-a-cmd-command-through-powershell
        if($LASTEXITCODE -eq 0)
        {
            Write-Host "Tests passed"
        }
        elseif($LASTEXITCODE -gt 0)
        {
            throw "One or more tests failed"
        }
        elseif($LASTEXITCODE -lt 0)
        {
            throw "Something horrible went wrong!"
        }
    }
}

if(!$allowNoTest -and !$foundTests)
{
    throw "Did not find any tests"
}

