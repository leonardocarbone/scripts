$REGISTRY_PATH = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\7516b95f-f776-4464-8c53-06167f40cc99\8EC4B3A5-6868-48c2-BE75-4F3044BE88A7"
$REGISTRY_ITEM = "Attributes"
$REGISTRY_ITEM_VALUE = 2

if(Test-Path -Path $REGISTRY_PATH) {    
    Write-Host "Changing Registry Settings"
    Write-Host "   $REGISTRY_PATH -Item: $REGISTRY_ITEM"
    
    $REGISTRY_ITEM_CURENTVALUE = Get-ItemPropertyValue -Path $REGISTRY_PATH -Name $REGISTRY_ITEM
    Write-Host "   Current Value: $REGISTRY_ITEM_CURENTVALUE / New Value: $REGISTRY_ITEM_VALUE"
    Set-ItemProperty -Path $REGISTRY_PATH -Name $REGISTRY_ITEM -Value $REGISTRY_ITEM_VALUE -Force
    Write-Host "   Done!"

    C:\Windows\System32\control.exe /name Microsoft.PowerOptions /page pagePlanSettings    
} else {
    Write-Host "Registry Path $REGISTRY_PATH does not exist!"
}

