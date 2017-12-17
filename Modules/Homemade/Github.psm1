

function Set-CommitStatus {
    param(
        [string]$state,
        [string]$targetUrl,
        [string]$description,
        [string]$context,
        [string]$user,
        [string]$repository,
        [string]$sha,
        [string]$apiKey
    )

    $url = "https://api.github.com/repos/$user/$repository/statuses/$sha"

    $body = @{
        state       = $state
        target_url  = $targetUrl
        description = $description
        context     = $context
    }

    # Create basic auth headers
    $pair = "$($user):$($apiKey)"
    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
    $basicAuthValue = "Basic $encodedCreds"

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/vnd.github.v3+json")
    $headers.Add("Content-Type", "application/json")
    $headers.Add("Authorization", $basicAuthValue)

    $json = $body | ConvertTo-Json

    try {
        $result = Invoke-RestMethod -Method Post -Body $json -Headers $headers -Uri $url -ErrorAction Ignore

        Write-Host "Succesfully set state on commit in Github."
        Write-Host "Commit: $sha"
        Write-Host "Status: $state"
        Write-Host "Message: $description"
    }
    catch {
        Write-Host "Could not set commit status"
    }
}