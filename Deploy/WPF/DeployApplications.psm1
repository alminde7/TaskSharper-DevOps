

function Start-Executable
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Executable,

        [switch]$AutoStart = $true
    )

    if($AutoStart){
        Start-Process $Executable -ErrorAction Stop
    } else {
        Write-Host "Autostart was set to false. Not starting application"
    }
}

function Stop-Executable
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$processName
    )

    $process = Get-Process $processName -ErrorAction SilentlyContinue

    if ($process) {
        Write-Host "Trying to stop $process gracefully"
        # try gracefully first
        $process.CloseMainWindow()
        # kill after five seconds
        Sleep 5
        if (!$process.HasExited) {
            Write-Host "Killing process $process"
            $process | Stop-Process -Force
        }
    } else {
        Write-Host "Process $processName is not running"
    }
}

function Copy-Files
{
    param(
        [string]$basePath,
        [string]$serviceType,
        [System.IO.DirectoryInfo]$application
    )

    $pathToFiles = $application.FullName + "\*"
    
    $pathToApp = "$basePath\$serviceType\$($application.Name)\App"
    $pathToTemp = "$basePath\$serviceType\$($application.Name)\Temp"
    $pathToOld = "$basePath\$serviceType\$($application.Name)\Old"

    ## Delete TEMP folder
    if(Test-Path $pathToTemp){
        Write-Host "Deleting folder: $pathToTemp"
        Remove-Item $pathToTemp -Recurse -ErrorAction Stop
    }

    ## Copy new files to temp folder
    New-Item $pathToTemp -Type directory
    Write-Host "Copying executables from $pathToFiles to $pathToTemp"
    Copy-Item $pathToFiles $pathToTemp -Recurse -ErrorAction Stop
    
    ## Delete OLD folder
    if(Test-Path $pathToOld){
        Write-Host "Deleting folder: $pathToOld"
        Remove-Item $pathToOld -Recurse -ErrorAction Stop
    }

    ## Stop process
    Write-Host "Stopping service: $($application.Name)"
    Stop-Executable -processName $application.Name

    if(Test-Path $pathToApp){
        ## Rename APP to OLD
        Write-Host "Renaming $pathToApp to $pathToOld"
        Rename-Item $pathToApp $pathToOld
    }

    ## Rename TEMP to APP
    Write-Host "Renaming $pathToTemp to $pathToApp"
    Rename-Item $pathToTemp $pathToApp

    return $pathToApp
}
