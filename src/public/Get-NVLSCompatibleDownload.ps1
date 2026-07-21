<#
    .SYNOPSIS
    Retrieves compatible software versions from the NVIDIA License System API.

    .DESCRIPTION
    Retrieves compatible software versions from the NVIDIA License System API.

    .PARAMETER ApiKey
    Specifies the API key with Software Downloads access type entitlement.

    .PARAMETER ProductName
    Specifies the product name. Valid values are NVAIE or vGPU.

    .PARAMETER DriverType
    Specifies the driver type. Valid values are GUEST or HOST.

    .PARAMETER DriverVersion
    Specifies one or more driver version(s).

    .PARAMETER ReleaseVersion
    Specifies one or more release version(s).

    .PARAMETER Ltsb
    Indicates whether to only search for LTSB downloads.

    .PARAMETER Latest
    Indicates whether to only return the latest result.

    .NOTES
    Tested on the NVIDIA License System API in mid June 2025.
    
    TODO:
        - Add dynamic OsName parameter (Linux/Windows) when DriverType is Guest.
        - Use Enums instead of ValidateSet?

    .EXAMPLE
    $apiKey = Read-Host -AsSecureString -Prompt 'NVIDIA License System API Key'
    $software = Get-NVLSCompatibleDownload -ApiKey $apiKey -Product vGPU -DriverType host -Latest
    $software.compatibleDownloads

    product        : vgpu
    driverType     : host
    releaseVersion : 18.2
    driverVersion  : 570.148.06
    osVersion      : 
    branchType     : 
    endOfSupport   : 2026-03-31

    .OUTPUTS
    [PSCustomObject].

    .LINK
    https://ui.licensing.nvidia.com/api-doc/nls-api-docs.html#tag/Software-Download/operation/listCompatibleDownloads

    .LINK
    https://docs.nvidia.com/license-system/latest/nvidia-license-system-user-guide/index.html

    .LINK
    https://blog.graa.dev/PowerShell-NVIDIASoftware  
#>

function Get-NVLSCompatibleDownload {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]        
    param (
        [Parameter(Mandatory = $true)]
        [SecureString]$ApiKey,

        [Parameter(Mandatory = $true)]
        [ValidateSet('NVAIE', 'vGPU')]
        [String]$ProductName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('GUEST', 'HOST')]
        [String]$DriverType,  

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String[]]$DriverVersion,        

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String[]]$ReleaseVersion,

        [Parameter(Mandatory = $false)]
        [Switch]$Ltsb,

        [Parameter(Mandatory = $false)]
        [Switch]$Latest
    )

    begin {
        $uri = 'https://api.licensing.nvidia.com/v1/downloads/compatible'

        $headers = @{
            'Content-Type' = 'application/json'
            'Accept' = 'application/json'
            'X-Api-Key' = $apikey | Convert-SecureStringToPlaintext
        }

        $body = @{}

        $body.Add('product', $ProductName)
        $body.Add('driverType', $DriverType)

        if ($PSBoundParameters.ContainsKey('DriverVersion')) {
            $body.Add('driverVersion', @($DriverVersion))
        }        

        if ($PSBoundParameters.ContainsKey('ReleaseVersion')) {
            $body.Add('releaseVersion', @($ReleaseVersion))
        }

        if ($PSBoundParameters.ContainsKey('Ltsb')) {
            $body.Add('ltsb', [bool]$ltsb)
        }
        
        if ($PSBoundParameters.ContainsKey('Latest')) {
            $body.Add('latest', [bool]$latest)
        }                

        $body = $body | ConvertTo-Json

        Write-Verbose -Message ($body | Out-String)        
    }

    process {
        try {        
            $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body

            $response
        }
        catch {
            Write-Error -Message ('Error encountered retrieving compatible software versions from the NVIDIA License System API: {0}' -f $_) -ErrorAction Stop
        }
    }

    end { }
}
