cls
$index = 4
$location = "East US"
$ResourceGroupName = "hdinsightcluster$index"

$paramsObject = @{
    "location" = $location
    "clusterName" = $ResourceGroupName
    "clusterLoginUserName" = "clusteradmin"
    "clusterLoginPassword" = "Passw0rd!Passw0rd!"
    "sshUserName" = "clusteradmin"
    "sshPassword" = "Passw0rd!Passw0rd!"
    "linkAdditionalStorageAccount" = "Yes"
    "linkStorageAccountName" = "txr6yewlf2pqy"
    "linkStorageContainerName" = "hdinsightcluster1"
    "linkStorageAccountKey" = "gwhanYp21lI3AiYJtWefkk1k2y93Tm+S/tIRo+5bAoWGXM4mNUGoLyzMiH4HmVjFUtQJk/2mv1tNwAuLSeceDw=="
    #"linkStorageAccountName" = ""
    #"linkStorageContainerName" = ""
    #"linkStorageAccountKey" = ""
}

## Replace the local path of the template
$templatePath = "C:\Users\$($env:USERNAME)\Downloads\linux-hdinsight-spark-cluster.json"

#region resource group
$ResourceGroup = Get-AzureRmResourceGroup -Name $ResourceGroupName -Location $location -ErrorAction SilentlyContinue
if ($ResourceGroup -eq $null)
{
    $ResourceGroup = New-AzureRmResourceGroup -Name $ResourceGroupName -Location $location -Force
}
#endregion

$output = Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Mode Incremental -TemplateFile $templatePath -TemplateParameterObject $paramsObject -Verbose -ErrorAction Stop

if($output.Count -eq 0) {
    
    Write-Host -ForegroundColor Green "Deploy?"
    Read-Host
    New-AzureRmResourceGroupDeployment -Name $ResourceGroupName -ResourceGroupName $ResourceGroupName -Mode Incremental -Force -TemplateFile $templatePath -TemplateParameterObject $paramsObject -Verbose -ErrorVariable deploymentErr
}
#region error
else {
    Write-Error -Message "ARM template error"
    foreach($l in $output) { Write-Host $l.Code; Write-Host $l.Message }
}
#endregion