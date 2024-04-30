$RESOURCE_GROUP_NAME='rg-tf-avd-backend-prod-neu-001'
$Location='northeurope'
$STORAGE_ACCOUNT_NAME="avd1935549823""
$CONTAINER_NAME='prodtfstate'

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $Location --tags 'application=AVD' 'classification=internal' 'environment=dev' 'monitoring=presmon' 'owner=mehodge'

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob --tags 'application=AVD' 'classification=internal' 'environment=dev' 'monitoring=presmon' 'owner=mehodge'

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

#Get the storage access key and store it as an environment variable
$ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv) 
$env:ARM_ACCESS_KEY=$ACCOUNT_KEY



backend "azurerm" {
    resource_group_name  = "rg-tf-avd-backend-prod-neu-001"
    storage_account_name = "avd1935549823"
    container_name       = "prodtfstate"
    key                  = "terraform.tfstate"
}