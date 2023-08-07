<#
    .SYNOPSIS
    This script enumerates Azure resources in specified subscriptions.

    .DESCRIPTION
    The script first sets the Azure subscription context to the specified subscriptions. It then lists all the resources in those subscriptions, counts the number of each resource type and outputs these stats into a CSV file. It also exports details of all resources into another CSV file. If -AllSubscriptions switch is used, it will enumerate all the subscriptions available in the account.

    .PARAMETER AllSubscriptions
    Enumerates all subscriptions available in the account.

    .PARAMETER Subscriptions
    Specifies subscriptions to enumerate. Accepts an array of subscription ids. Comma-seperated.

    .PARAMETER TenantID
    Specifiy Tenant Id to target specific tenant.

    .EXAMPLE
    .\List-Resources.ps1-AllSubscriptions

    .EXAMPLE
    .\List-Resources.ps1-Subscriptions "subscription-id-1,subscription-id-2"

    .EXAMPLE
    .\List-Resources.ps1-AllSubscriptions -TenantId "x-x-x-x"
#>

param(
    [switch]$AllSubscriptions,
    [string[]]$Subscriptions,
    [string]$TenantId
)

# Check input
if ($PSBoundParameters.Count -eq 0) {
    Write-Error "No parameters provided. Please specify either -AllSubscriptions, -Subscriptions, with or without -TenantId."
    exit
}

# Auth point
if ((az account list --output json).length -le 2) {
    if ($TenantId) {
        az login --tenant $TenantId
    }
    az login
} else {
    # nothing
}

# If the -AllSubscriptions switch is set, get all subscriptions using the az CLI
if ($AllSubscriptions) {
    $Subscriptions = az account list --query "[].id" --output tsv
}

# CSV file to save the stats
$statsFile = "azure_resources_stats.csv"
$resourcesFile = "azure_resources.csv"
$tempFile = "temp.csv"

# Clean the files
"ResourceType,Count" | Out-File $statsFile
"SubscriptionID,ResourceGroup,ResourceName,ResourceType" | Out-File $resourcesFile
if (Test-Path $tempFile -ErrorAction Ignore) {
    Remove-Item $tempFile -ErrorAction Continue
}

# Iterate over each subscription
foreach ($subscriptionId in $Subscriptions) {
    # Set the subscription context
    az account set --subscription $subscriptionId

    # Get all resources
    $resources = az resource list --query "[].{type:type}" --output tsv

    # Iterate over each resource and count
    foreach ($type in ($resources -split ' ' | Sort-Object -Unique)) {
        $count = ($resources -split ' ' | Where-Object { $_ -eq $type } | Measure-Object).Count
        "$type,$count" | Out-File -Append $statsFile
    }

    # Get all resources detail
    $resourcesJson = az resource list --query "[].{id:id, resourceGroup:resourceGroup, name:name, type:type}" --output json
    $resourcesJson | ConvertFrom-Json | Select-Object @{Name='SubscriptionID';Expression={$_.id -replace "(?m)^\/subscriptions\/([^\/]*).*$",'$1'}},resourceGroup,name,type | Export-Csv -Path $tempFile -Delimiter "," -NoTypeInformation

    Get-Content $tempFile | Select-Object -Skip 1 | Out-File -Append $resourcesFile
}

# Add total number of resources to stats file
$totalResources = (Import-Csv $resourcesFile).Count
"Total Resources,$totalResources" | Out-File -Append $statsFile

# Remove the temporary file
Remove-Item $tempFile
Write-Host "Script execution completed. The stats and resources details are saved in $statsFile and $resourcesFile respectively."
