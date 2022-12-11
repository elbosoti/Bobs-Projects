#iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/elbosoti/Bobs-Projects/main/PC/GetPcSpecs.ps1'))

function GetPcSpecsArray{
    $systemSpecs = @(
        getProcessor
        getMotherboard
    )
    $systemSpecs += GetGraphicsCards
    $systemSpecs += getMemory
    $systemSpecs += getDrives
    return $systemSpecs
}


function GetSystemInfo{

}

function GetProcessor{
    $processorInfo = Get-CimInstance -ClassName Win32_Processor
    $processorObject = [PSCustomObject]@{
        Type = "Processor"
        Brand = $processorInfo.Manufacturer
        Model = $processorInfo.Name
        Size = $processorInfo.NumberOfCores.ToString() + " Cores"
    }
    return $processorObject
}


function GetMotherboard{
    $motherboardInfo = Get-CimInstance -ClassName Win32_BaseBoard
    $biosInfo = Get-CimInstance -ClassName Win32_BIOS
    $motherboardObject = [PSCustomObject]@{
        Type = "Motherboard"
        Brand = $motherboardInfo.Manufacturer
        Model = $motherboardInfo.Product
        Size = $biosInfo.Caption
        Extra = $motherboardInfo.SerialNumber
    }
    return $motherboardObject
}

function GetGraphicsCards{
    $graphicsInfo = Get-CimInstance -ClassName Win32_VideoController
    $graphicsCardArray = @()
    foreach ($graphics in $graphicsInfo){
        $graphicsCardArray += [PSCustomObject]@{
            Type = "Graphics Card"
            Brand = $graphics.AdapterCompatibility
            Model = $graphics.Name
            Size = DisplayInBytes($graphics.AdapterRAM)
        }
    }
    return $graphicsCardArray
}
function GetMemory{
    $memoryArray = Get-CimInstance -ClassName Win32_PhysicalMemory
    $memoryObjectArray = @()
    foreach( $memoryDimm in $memoryArray){
        $memoryObjectArray += [PSCustomObject]@{
            Type = "RAM"
            Brand = $memoryDimm.Manufacturer
            Model = $memoryDimm.PartNumber
            Size = DisplayInBytes($memoryDimm.Capacity)
            Extra = $memoryDimm.DeviceLocator
            }

    }
    return $memoryObjectArray
}

function GetDrives{
    $drives = Get-PhysicalDisk
    $driveArray = @()
    foreach($drive in $drives){
        $driveArray += [PSCustomObject]@{
            Type = $drive.BusType +" "+ $drive.MediaType
            Brand = $drive.FriendlyName
            Model = $drive.SerialNumber
            Size = DisplayInBytes($drive.Size)
        }
    }
    return $driveArray
}

function DisplayInBytes($size){
    $units = "B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"
    $index = 0
    while($size -ge 1024){
        $index++
        $size = $size / 1024
    }
    return [math]::Round($size, 2).ToString() + $units[$index]
}
getPcSpecsArray


