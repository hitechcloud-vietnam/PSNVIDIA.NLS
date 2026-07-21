# PSNVIDIA.NLS

[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/hitechcloud-vietnam/PSNVIDIA.NLS/refs/heads/main/LICENSE)
![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/PSNVIDIA.NLS?label=PowerShell%20Gallery&color=green)
![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/PSNVIDIA.NLS?color=green)

> This PowerShell module lets one accomplish various tasks with the NVIDIA License System API and is available in [the PowerShell Gallery](https://www.powershellgallery.com/packages/PSNVIDIA.NLS)

> [!TIP]  
> Read the related blog post at https://blog.graa.dev/PowerShell-NVIDIASoftware

## 🚀 Features 

* Retrieve compatible versions of e.g. vGPU software
* Retrieve download URLs for vGPU or DLS software

## 📄 Prerequisites

### PowerShell version

This module works on both Windows PowerShell and PowerShell Core.

### NVIDIA LS

> [!NOTE]  
> This module has been tested on the NVIDIA License System API in mid June 2025.

## 📦 Installation

Install the version that is published to the PowerShell Gallery:

```powershell
Install-Module -Name PSNVIDIA.NLS
```

## 🔧 Usage

### Create an API key

Create an API key in the NVIDIA Portal with the Software Downloads access type.

```powershell
$apiKey = Read-Host -AsSecureString -Prompt 'NVIDIA License System API key'
```

### Retrieve compatible software versions

```powershell
Get-NVLSCompatibleDownload -ApiKey $apiKey
```

### Retrieve software download URLs

```powershell
Find-NVLSDownload -ApiKey $apiKey
```

## 🙌 Contributing

Any contributions are welcome and appreciated!

Please do so by forking the project and opening a pull request!

## ✨ Credits

> [!NOTE]  
> This PowerShell module is unofficial and not supported by NVIDIA in any way.
