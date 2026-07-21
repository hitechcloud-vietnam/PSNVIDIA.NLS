<#
    .SYNOPSIS
    Retrieves software download URLs from the NVIDIA License System API.

    .DESCRIPTION
    Retrieves software download URLs from the NVIDIA License System API.

    .PARAMETER ApiKey
    Specifies the API key with Software Downloads access type entitlement.

    .PARAMETER ProductName 
    Optionally specifies the product name. If this parameter is not specified, all software is returned.
    Valid values are Jetson, NVAIE, Omniverse Enterprise Private Offer, Pipelines or vGPU.

    .PARAMETER PlatformName
    Optionally specifies the platform name.
    Valid values include most hypervisors, e.g. Microsoft Azure Local and VMware vSphere.

    .PARAMETER DownloadVersion
    Optionally specifies the software version to download (e.g. 18.2).

    .PARAMETER PlatformVersion
    Optionally specifies the platform version (e.g. 8.0 for VMware vSphere).

    .PARAMETER Type
    Optionally specifies the software type. Valid values are Guest or Host.

    .PARAMETER LinkType
    Optionally specifies the download type. Valid values are Current, Preferred or Archived. Default value is Preferred.    

    .NOTES
    Tested on the NVIDIA License System API in mid June 2025.

    TODO:
        - Use Enums instead of ValidateSet?

    .EXAMPLE
    $apiKey = Read-Host -AsSecureString -Prompt 'NVIDIA License System API Key'
    $software = Find-NVLSDownload -ApiKey $apikey -ProductName 'vGPU' -PlatformName 'Microsoft Azure Local'
    $software.downloads | Sort-Object -Property releaseDate | Select-Object -Last 1

    description     : Complete vGPU 18.2 package for Microsoft Azure Local including supported guest drivers
    downloadType    : Image
    linkType        : Preferred
    name            : vGPU Driver
    platformName    : Microsoft Azure Local
    platformVersion : All Supported
    releaseDate     : 2025-05-27
    url             : 
    version         : 18.2
    productName     : vGPU    
    checksumUrl     : 
    checksumFormat  : SHA256

    .EXAMPLE
    $apiKey = Read-Host -AsSecureString -Prompt 'NVIDIA License System API Key'
    $latest = Get-NVLSCompatibleDownload -ApiKey $apikey -Product vGPU -DriverType Host -Latest
    $software = Find-NVLSDownload -ApiKey $apikey -ProductName 'vGPU' -PlatformName 'VMware vSphere' -DownloadVersion $latest.compatibleDownloads.releaseVersion
    $software.downloads

    description     : Complete vGPU 18.2 package for VMware vSphere 8.0 including supported guest drivers
    downloadType    : Image
    linkType        : Preferred
    name            : vGPU Driver
    platformName    : VMware vSphere
    platformVersion : 8.0
    releaseDate     : 2025-05-27
    url             : 
    version         : 18.2
    productName     : vGPU
    checksumUrl     : 
    checksumFormat  : SHA256    

    .EXAMPLE
    $apiKey = Read-Host -AsSecureString -Prompt 'NVIDIA License System API Key'
    $software = Find-NVLSDownload -ApiKey $apikey -PlatformName 'Red Hat Enterprise Linux OS'
    $software.downloads | Sort-Object -Property releaseDate | Select-Object -Last 1

    description     : NLS License Server (DLS) 3.5.0 - Container with Orchestrator Platform for Red Hat Enterprise Linux 9.x OS
    downloadType    : Image
    linkType        : Preferred
    name            : DLS 3.5.0 Appliance as a Container for RHEL 9
    platformName    : Red Hat Enterprise Linux OS
    platformVersion : 
    releaseDate     : 2025-05-22
    url             : 
    version         : 
    checksumUrl     : 
    checksumFormat  : MD5    

    .OUTPUTS
    [PSCustomObject].

    .LINK
    https://ui.licensing.nvidia.com/api-doc/nls-api-docs.html#tag/Software-Download/operation/getDownloadsWithApiKey    

    .LINK
    https://docs.nvidia.com/license-system/latest/nvidia-license-system-user-guide/index.html    

    .LINK
    https://blog.graa.dev/PowerShell-NVIDIASoftware

#>

function Find-NVLSDownload {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory = $true)]
        [SecureString]$ApiKey,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Jetson', 'NVAIE', 'Omniverse Enterprise Private Offer', 'Pipelines', 'vGPU')]
        [String]$ProductName,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Citrix Hypervisor', 'Citrix XenServer', 'Container', 'Linux', 'Linux KVM',
        'Microsoft Azure Local', 'Microsoft Azure Stack HCI', 'Microsoft Hyper-V', 'Microsoft Hyper-V Server', 'Microsoft Windows Server',
        'Red Hat Enterprise Linux KVM', 'Red Hat Enterprise Linux OS', 'Ubuntu KVM', 'vGPU Driver Catalog', 'VMware vCenter',
        'VMware vRealize Operations', 'VMware vSphere', 'Windows', 'XenServer')]
        [String]$PlatformName,        

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]$DownloadVersion,
        
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]$PlatformVersion,

        [Parameter(Mandatory = $false)]
        [ValidateSet('GUEST', 'HOST')]
        [String]$Type,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Current', 'Preferred', 'Archived')]
        [String]$LinkType = 'Preferred'
    )

    begin {
        $uri = 'https://api.licensing.nvidia.com/v1/downloads'

        $headers = @{
            'Content-Type' = 'application/json'
            'Accept' = 'application/json'
            'X-Api-Key' = $apikey | Convert-SecureStringToPlaintext
        }

        $body = @{}

        if ($PSBoundParameters.ContainsKey('ProductName')) {
            $body.Add('productName', $ProductName)
        }

        if ($PSBoundParameters.ContainsKey('PlatformName')) {
            $body.Add('platformName', $PlatformName)
        }

        if ($PSBoundParameters.ContainsKey('DownloadVersion')) {
            $body.Add('downloadVersion', $DownloadVersion)
        }        

        if ($PSBoundParameters.ContainsKey('PlatformVersion')) {
            $body.Add('platformVersion', $PlatformVersion)
        }

        if ($PSBoundParameters.ContainsKey('Type')) {
            $body.Add('type', $Type)
        }        

        $body.Add('linkType', $LinkType)              

        $body = $body | ConvertTo-Json

        Write-Verbose -Message ($body | Out-String)
    }

    process {
        try {
            $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body

            $response
        }
        catch {
            Write-Error -Message ('Error encountered retrieving software downloads from the NVIDIA License System API: {0}' -f $_) -ErrorAction Stop
        }
    }

    end { }
}
