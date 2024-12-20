# The purpose of this script is to get the bandwidth for an Azure Load Balancer using the REST API
# See readme for more information on how to install and run

# Function to run script to get Az LB Bandwidth
function Get-AzLbBandwidth { 
    # Defining the required parameters for the function
    param (
        [Parameter(Mandatory = $true)] 
        [ValidateNotNullOrEmpty()]  
        [string]$ResourceURI,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$StartDateTime,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$EndDateTime,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$UserProvidedFilePath
    )

    # Ensures user connects to the right Azure account, tenant, and subscription
    Connect-AzAccount

    # Get the most current API version using the Get-MostCurrentApiVersion object
    $APIVersion = ((Get-AzResourceProvider -ProviderNamespace Microsoft.Insights).ResourceTypes | Where-Object ResourceTypeName -eq metrics).ApiVersions[0]

    # Captures API Version and prints to terminal for debugging - uncomment below command if debugging is needed
    # Write-Host "API Version: $APIVersion"

    # Get the Auth Token to be passed as a header for the REST API call
    $AuthToken = (Get-AzAccessToken -ResourceUrl https://management.azure.com/).token

    # Defines the filters to properly split the inbound and outbound bandwidth in the JSON output created by the REST API call
    $Filter = "FrontendIPAddress eq '*' and Direction eq '*'"
    $EncodedFilter = [System.Web.HttpUtility]::UrlEncode($Filter)

    # Defines the time-span for the REST API call using user-provided time values
    $Timespan = "$StartDateTime/$EndDateTime"

    # Constructing the URI for the REST API call
    $MetricNamespace = "Microsoft.Network/loadBalancers"
    $URI = "https://management.azure.com/$ResourceURI/providers/Microsoft.Insights/metrics?api-version=$APIVersion&metricnames=ByteCount&timespan=$Timespan&`$filter=$EncodedFilter&metricnamespace=$MetricNamespace"

    # Captures URI and prints to terminal for debugging - uncomment below command if debugging is needed
    # Write-Host "Constructed URI: $URI"

    # Defines the headers for the REST API call
    $headers = @{ #defining any required headers, such as the bearer token
        Authorization = "Bearer $AuthToken"
    }

    # Defining the parameters for the REST API call
    $Params = @{
        Method = 'GET'
        URI = $URI
        Headers = $headers
    }

    # The following builds the name for $OutputFileName based on the LB name and the start and end dates
    $SplitResourceURI = $ResourceURI.Split("/")
    $ReplaceStartDate = $StartDateTime.Replace(":","").Replace("Z","")
    $ReplaceEndDate = $EndDateTime.Replace(":","").Replace("Z","")
    $OutputFileName = "$UserProvidedFilePath\$($SplitResourceURI[-1])_$($ReplaceStartDate)_$($ReplaceEndDate).json"

    # Captures OutputFileName and prints to terminal for debugging - uncomment below command if debugging is needed
    # Write-Host "Output File Name: $OutputFileName"

    # Makes the REST API call and captures the output - testing copilot's solve for outputting 
    $response = Invoke-RestMethod @Params

    # Convert the response to JSON and output to both a json file and terminal - currently output file is to same directory as installed script
    $response | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFileName
}

# Function to validate date and time format
function Validate-DateTimeFormat {
    param (
        [string]$DateTime
    )
    $regex = '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$'
    if ($DateTime -match $regex) {
        return $true
    } else {
        return $false
    }
}

# Prompt user to input Resource URI, Start and End date/time and validates all inputs
do {
    $ResourceURI = Read-Host "Please enter the Resource URI for the LB you want to check"
} while ([string]::IsNullOrWhiteSpace($ResourceURI))

do {
    $StartDateTime = Read-Host "Please enter the start date/time (UTC) for your query in the following format: YYYY-MM-DDTHH:MM:SSZ"
} while (-not (Validate-DateTimeFormat -DateTime $StartDateTime))

do {
    $EndDateTime = Read-Host "Please enter the end date/time (UTC) for your query in the following format: YYYY-MM-DDTHH:MM:SSZ"
} while (-not (Validate-DateTimeFormat -DateTime $EndDateTime))

do {
    $UserProvidedFilePath = Read-Host "Please enter a valid path you want to use to save the output file to (for example, C:\Test; do not include a \ at the end)"
} while (-not (Test-Path $UserProvidedFilePath))

# Call the function with validated inputs
Get-AzLbBandwidth -ResourceURI $ResourceURI -StartDateTime $StartDateTime -EndDateTime $EndDateTime -UserProvidedFilePath $UserProvidedFilePath