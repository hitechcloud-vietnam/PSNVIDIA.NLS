function Convert-SecureStringToPlaintext {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [SecureString]$SecureString
    )

    process {
        switch ($PSVersionTable.PSEdition) {
            'Core' {
                $SecureString | ConvertFrom-SecureString -AsPlainText
            }

            default {
                [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString))
            }
        }
    }
}
