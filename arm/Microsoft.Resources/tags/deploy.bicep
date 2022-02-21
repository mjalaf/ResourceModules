targetScope = 'subscription'

@description('Optional. Tags for the resource group. If not provided, removes existing tags')
param tags object = {}

@description('Optional. Instead of overwriting the existing tags, combine them with the new tags')
param onlyUpdate bool = false

@description('Optional. Name of the Resource Group to assign the tags to. If no Resource Group name is provided, and Subscription ID is provided, the module deploys at subscription level, therefore assigns the provided tags to the subscription.')
param resourceGroupName string = ''

@description('Optional. Subscription ID of the subscription to assign the tags to. If no Resource Group name is provided, the module deploys at subscription level, therefore assigns the provided tags to the subscription.')
param subscriptionId string = subscription().id

module tags_sub 'subscriptions/deploy.bicep' = if (!empty(subscriptionId) && empty(resourceGroupName)) {
  name: '${deployment().name}-Tags-Sub'
  params: {
    onlyUpdate: onlyUpdate
    tags: tags
  }
}

module tags_rg 'resourceGroups/deploy.bicep' = if (!empty(resourceGroupName) && !empty(subscriptionId)) {
  name: '${deployment().name}-Tags-RG'
  scope: resourceGroup(resourceGroupName)
  params: {
    onlyUpdate: onlyUpdate
    tags: tags
  }
}

@description('The applied tags')
output appliedTags object = (!empty(resourceGroupName) && !empty(subscriptionId)) ? tags_rg.outputs.appliedTags : tags_sub.outputs.appliedTags
