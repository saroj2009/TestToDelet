#Login-AzAccount


Get-AzureRMSubscription 
Select-AzureRMSubscription -Subscription "16c4dd7c-eae8-42bc-ae66-6e5691642e32"

#############Set the variables############

#Resource Group
$locationName = "westeurope"
$ResourceGroupName = "AZ-RG-DEMO"
 
 New-AzureRmResourceGroup -Name $ResourceGroupName -Location $locationName

#Virtual Network 
$networkName = "AZ-VNET"

$virtualNetwork = New-AzureRMVirtualNetwork `
  -ResourceGroupName $ResourceGroupName `
  -Location $locationName `
  -Name $networkName `
  -AddressPrefix 10.0.0.0/16


  $subnetConfig = Add-AzureRMVirtualNetworkSubnetConfig `
  -Name default `
  -AddressPrefix 10.0.0.0/24 `
  -VirtualNetwork $virtualNetwork

  $virtualNetwork | Set-AzureRMVirtualNetwork

$nicName = "NIC-"
$vnet = Get-AzureRMVirtualNetwork -Name $networkName `
                             -ResourceGroupName $ResourceGroupName
 
#Virtual Machines
$computerNames = @("VM-01")
$vmSize = "Standard_B2ms"
$publisherName = "MicrosoftWindowsServer"
$offer = "WindowsServer"
$skus = "2016-Datacenter"
 
$credential = Get-Credential
 

 ########## Azure Resource Deployment #############

 for($i = 0; $i -le $computerNames.count -1; $i++)  
{
 
 $NIC = New-AzureRMNetworkInterface -Name ($NICName+$computerNames[$i]) `
                               -ResourceGroupName $ResourceGroupName `
                               -Location $LocationName `
                               -SubnetId $Vnet.Subnets[0].Id
 
 $VirtualMachine = New-AzureRMVMConfig -VMName $computerNames[$i] `
                                  -VMSize $VMSize
 $VirtualMachine = Set-AzureRMVMOperatingSystem -VM $VirtualMachine `
                                           -Windows `
                                           -ComputerName $computerNames[$i] `
                                           -Credential $Credential `
                                           -ProvisionVMAgent  `
                                           -EnableAutoUpdate
 
 $VirtualMachine = Add-AzureRMVMNetworkInterface -VM $VirtualMachine `
                                            -Id $NIC.Id
 $VirtualMachine = Set-AzureRMVMSourceImage -VM $VirtualMachine `
                                       -PublisherName $publisherName `
                                       -Offer $offer `
                                       -Skus $skus `
                                       -Version latest
 
 New-AzureRMVM -ResourceGroupName $ResourceGroupName `
          -Location $LocationName `
          -VM $VirtualMachine `
          -Verbose
}

<#
# Install IIS
$PublicSettings = '{"commandToExecute":"powershell Add-WindowsFeature Web-Server"}'

Set-AzureRMVMExtension -ExtensionName "IIS" -ResourceGroupName $ResourceGroupName -VMName VM-01 `
  -Publisher "Microsoft.Compute" -ExtensionType "CustomScriptExtension" -TypeHandlerVersion 1.4 `
  -SettingString $PublicSettings -Location $LocationName

  Set-AzureRMVMExtension -ResourceGroupName $ResourceGroupName `
    -ExtensionName "IIS" `
    -VMName "VM-01" `
    -Location $LocationName `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.8 `
    -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server -IncludeAllSubFeature -IncludeManagementTools; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'

    #>