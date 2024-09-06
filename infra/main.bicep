@description('Suffix to create unique resource names; 4-6 characters. Default is a random 6 characters.')
@minLength(4)
@maxLength(6)
param suffix string = substring(newGuid(), 0, 6)

@description('The tags to apply to all resources. Refer to https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging for best practices.')
param tags object = {
  Application: 'Kernel-Memory'
  Environment: 'Demo'
}

@description('''
Kernel Memory Docker Image Tag.  Check available tags at https://hub.docker.com/r/kernelmemory/service/tags
''')
@minLength(3)
@maxLength(16)
param KernelMemoryImageTag string = 'latest'

///////////////////////////// AI Model Params ///////////////////////////////

// @description('''
// ATTENTION: USE MODELS THAT YOUR AZURE SUBSCRIPTION IS ALLOWED TO USE.


// Azure OpenAI Inference Model. https://learn.microsoft.com/en-gb/azure/ai-services/openai/concepts/models

// Default model version will be assigned. The default version is different for different models and might change when there is new version available for a model.
// ''')
// @allowed([
//   'gpt-35-turbo-16k'
//   'gpt-4'
//   'gpt-4-32k'
//   'gpt-4o'
//   'gpt-4o-mini'
// ])
// param InferenceModel string = 'gpt-35-turbo-16k'

// @description('''
// Inference deployment model\'s Tokens-Per-Minute (TPM) capacity, measured in thousands.
// The default capacity is 30 that represents 30,000 TPM. 
// For model limits specific to your region, refer to the documentation at https://learn.microsoft.com/azure/ai-services/openai/concepts/models#standard-deployment-model-quota.
// ''')
// @minValue(1)
// @maxValue(40)
// param InferenceModelDeploymentCapacity int = 30

// @description('''
// ATTENTION: USE MODELS THAT YOUR AZURE SUBSCRIPTION IS ALLOWED TO USE.

// Azure OpenAI Embedding Model. https://learn.microsoft.com/azure/ai-services/openai/concepts/models#embeddings

// Default model version will be assigned. The default version is different for different models and might change when there is new version available for a model.
// ''')
// @allowed([
//   'text-embedding-ada-002'
//   'text-embedding-3-small'
//   'text-embedding-3-large'
// ])
// param EmbeddingModel string = 'text-embedding-ada-002'

// @description('''
// Embedding deployment model\'s Tokens-Per-Minute (TPM) capacity, measured in thousands.
// The default capacity is 30 that represents 30,000 TPM.
// For model limits specific to your region, refer to the documentation at https://learn.microsoft.com/azure/ai-services/openai/concepts/models#standard-deployment-model-quota.
// ''')
// @minValue(1)
// @maxValue(40)
// param EmbeddingModelDeploymentCapacity int = 30

///////////////////////////// App Keys ///////////////////////////////

@description('''
PLEASE CHOOSE A SECURE AND SECRET KEY ! -
Kernel Memory Service Authorization AccessKey 1.
The value is stored as an environment variable and is required by the web service to authenticate HTTP requests.
''')
@minLength(32)
@maxLength(128)
@secure()
param WebServiceAuthorizationKey1 string

@description('''
PLEASE CHOOSE A SECURE AND SECRET KEY ! -
Kernel Memory Service Authorization AccessKey 2.
The value is stored as an environment variable and is required by the web service to authenticate HTTP requests.
''')
@minLength(32)
@maxLength(128)
@secure()
param WebServiceAuthorizationKey2 string

///////////////////////////// Networking Params ///////////////////////////////

// @description('''
// Define the address space of your virtual network. Refer to the documentation at https://learn.microsoft.com/azure/virtual-network/concepts-and-best-practices
// ''')
// param VirtualNetworkAddressSpace string = '10.0.0.0/16'

// @description('''
// Select an address space and configure your subnet for Infrastructure. You can also customize a subnet later. Refer to the documentation at https://learn.microsoft.com/azure/virtual-network/virtual-network-vnet-plan-design-arm#subnets
// ''')
// param InfrastructureSubnetAddressRange string = '10.0.0.0/23'

// @description('''
// Select an address space and configure your subnet for Application Gateway. You can also customize a subnet later. Refer to the documentation at https://learn.microsoft.com/azure/virtual-network/virtual-network-vnet-plan-design-arm#subnets
// ''')
// param ApplicationGatewaySubnetAddressRange string = '10.0.2.0/24'

// @description('''
// Select an address space and configure your subnet for Private Endpoints. You can also customize a subnet later. Refer to the documentation at https://learn.microsoft.com/azure/virtual-network/virtual-network-vnet-plan-design-arm#subnets
// ''')
// param PrivateEndpointSubnetAddressRange string = '10.0.3.0/24'

/////////////////////////////////////////////////////////////////////////////

var rg = resourceGroup()

var location = resourceGroup().location

/////////////////////////////////////////////////////////////////////////////


/* 
  Module to create an Azure Container Apps environment and a container app
  See https://learn.microsoft.com/en-us/azure/container-apps/environment
      and https://azure.github.io/aca-dotnet-workshop/aca/10-aca-iac-bicep/iac-bicep/#2-define-an-azure-container-apps-environment for more samples
*/
module module_containerAppsEnvironment 'modules/Container-Apps-Env/main.bicep' = {
  name: 'module-containerAppsEnvironment-${suffix}'
  scope: rg
  params: {
    location: location
    suffix: suffix
    tags: tags
    // network
    // acaSubnetId: module_vnet.outputs.envInfraSubnetId
    // logAnalyticsWorkspaceName: module_insights.outputs.logAnalyticsWorkspaceName
    // applicationInsightsName: module_insights.outputs.applicationInsightsName
  }
}

/*
  Module to create web app containing the Docker image
  See https://azure.microsoft.com/products/container-apps
  
  The Azure Container app hosts the docker container containing KM web service.
*/

param applicationInsightsConnectionString string
param AzureClientID string
param managedIdentityId string
param AzureBlobs_Account string
param AzureQueues_Account string
param AzureQueues_QueueName string
param AzureAISearch_Endpoint string
param AzureOpenAIText_Endpoint string
param AzureOpenAIText_Deployment string
param AzureOpenAIEmbedding_Endpoint string
param AzureOpenAIEmbedding_Deployment string
param AzureAIDocIntel_Endpoint string


module module_containerApp 'modules/Container-Apps/main.bicep' = {
  name: 'module-containerAppService-${suffix}'
  scope: rg
  params: {
    location: location
    suffix: suffix
    tags: tags
    containerAppsEnvironmentId: module_containerAppsEnvironment.outputs.containerAppsEnvironmentId

    KernelMemoryImageTag: KernelMemoryImageTag

    KernelMemory__ServiceAuthorization__AccessKey1: WebServiceAuthorizationKey1
    KernelMemory__ServiceAuthorization__AccessKey2: WebServiceAuthorizationKey2
    
    AzureClientID: AzureClientID
    managedIdentityId: managedIdentityId

    applicationInsightsConnectionString: applicationInsightsConnectionString
    AzureAISearch_Endpoint: AzureAISearch_Endpoint
    AzureBlobs_Account: AzureBlobs_Account
    AzureQueues_Account: AzureQueues_Account
    AzureQueues_QueueName: AzureQueues_QueueName
    AzureOpenAIEmbedding_Deployment: AzureOpenAIEmbedding_Deployment
    AzureOpenAIEmbedding_Endpoint: AzureOpenAIEmbedding_Endpoint
    AzureOpenAIText_Deployment: AzureOpenAIText_Deployment
    AzureOpenAIText_Endpoint: AzureOpenAIText_Endpoint
    AzureAIDocIntel_Endpoint: AzureAIDocIntel_Endpoint
  }
}

/* 
  Outputs
*/

// @description('The public IP of the Kernel Memory service.')
// output kmServiceEndpoint string = module_appGateway.outputs.ipAddress

@description('Service Access Key 1.')
output kmServiceAccessKey1 string = module_containerApp.outputs.kmServiceAccessKey1

@description('Service Access Key 2.')
output kmServiceAccessKey2 string = module_containerApp.outputs.kmServiceAccessKey2
