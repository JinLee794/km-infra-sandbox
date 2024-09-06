targetScope = 'resourceGroup'

param suffix string = uniqueString(resourceGroup().id)

param location string = resourceGroup().location


param managedIdentityId string
//param managedIdentityClientId string

param containerAppName string = 'dev-mq-ai-monitor-cont-app-03'

//Jin's Adds
param containerAppsEnvironmentId string
param KernelMemoryImageTag string = 'latest'

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

param applicationInsightsConnectionString string
param AzureClientID string
param KernelMemory__ServiceAuthorization__AccessKey1 string
param KernelMemory__ServiceAuthorization__AccessKey2 string
param AzureBlobs_Account string
param AzureQueues_Account string
param AzureQueues_QueueName string
param AzureAISearch_Endpoint string
param AzureOpenAIText_Endpoint string
param AzureOpenAIText_Deployment string
param AzureOpenAIEmbedding_Endpoint string
param AzureOpenAIEmbedding_Deployment string
param AzureAIDocIntel_Endpoint string


/*
param appInsightsInstrumentationKey string
param applicationInsightsConnectionString string

param AzureBlobs_Account string
param AzureQueues_Account string
param AzureQueues_QueueName string
param AzureAISearch_Endpoint string
param AzureOpenAIText_Endpoint string
param AzureOpenAIText_Deployment string
param AzureOpenAIEmbedding_Endpoint string
param AzureOpenAIEmbedding_Deployment string
param AzureAIDocIntel_Endpoint string
*/

// Removing as this is already being created
// --------------------
// resource managedEnv 'Microsoft.App/managedEnvironments@2022-11-01-preview' existing = {
//   name: environmentName
// }

resource containerapp 'Microsoft.App/containerApps@2023-05-01' = {
  name: containerAppName
  location: location
  tags: tags
  properties: {
    environmentId: containerAppsEnvironmentId
    // environmentId: managedEnv.id

    configuration: {
      secrets: [
        {
          name: 'appinsights-key'
          value: 'af207f6f-2f6b-4e55-ae37-fe879ef1b090'
        }
      ]
      registries: []
      activeRevisionsMode: 'Single'
      ingress: {
        external: false
        transport: 'Auto'
        allowInsecure: false
        targetPort: 9001 // Previously 80 from provided bicep
        stickySessions: {
          affinity: 'none'
        }
        // This traffic block is also missing from original config
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
        // additionalPortMappings: []
      }
    }

    template: {
      revisionSuffix: 'firstrevision'
      containers: [
        // Replacing the original config with what has been provided in the km module
        // {
        //   name: 'busybox'
        //   image: 'devaimonitoracr.azurecr.io/busybox:latest'
        //   resources: {
        //     cpu: json('1')
        //     memory: '1Gi'
        //   }
        // }
        {
          name: 'kernelmemory-service'
          image: 'docker.io/kernelmemory/service:${KernelMemoryImageTag}'
          command: []
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Production'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: applicationInsightsConnectionString
            }

            {
              name: 'AZURE_CLIENT_ID'
              value: AzureClientID
            }
            {
              name: 'KernelMemory__Service__OpenApiEnabled'
              value: 'true'
            }
            {
              name: 'KernelMemory__DocumentStorageType'
              value: 'AzureBlobs'
            }
            {
              name: 'KernelMemory__TextGeneratorType'
              value: 'AzureOpenAIText'
            }
            {
              name: 'KernelMemory__DefaultIndexName'
              value: 'default'
            }
            {
              name: 'KernelMemory__ServiceAuthorization__Enabled'
              value: 'true'
            }
            {
              name: 'KernelMemory__ServiceAuthorization__AuthenticationType'
              value: 'APIKey'
            }
            {
              name: 'KernelMemory__ServiceAuthorization__HttpHeaderName'
              value: 'Authorization'
            }
            {
              name: 'KernelMemory__ServiceAuthorization__AccessKey1'
              value: KernelMemory__ServiceAuthorization__AccessKey1
            }
            {
              name: 'KernelMemory__ServiceAuthorization__AccessKey2'
              value: KernelMemory__ServiceAuthorization__AccessKey2
            }
            {
              name: 'KernelMemory__DataIngestion__DistributedOrchestration__QueueType'
              value: 'AzureQueues'
            }
            {
              name: 'KernelMemory__DataIngestion__EmbeddingGeneratorTypes__0'
              value: 'AzureOpenAIEmbedding'
            }
            {
              name: 'KernelMemory__DataIngestion__MemoryDbTypes__0'
              value: 'AzureAISearch'
            }
            {
              name: 'KernelMemory__DataIngestion__ImageOcrType'
              value: 'AzureAIDocIntel'
            }
            {
              name: 'KernelMemory__Retrieval__EmbeddingGeneratorType'
              value: 'AzureOpenAIEmbedding'
            }
            {
              name: 'KernelMemory__Retrieval__MemoryDbType'
              value: 'AzureAISearch'
            }
            {
              name: 'KernelMemory__Services__AzureBlobs__Account'
              value: AzureBlobs_Account
            }
            {
              name: 'KernelMemory__Services__AzureQueues__Account'
              value: AzureQueues_Account
            }
            {
              name: 'KernelMemory__Services__AzureQueues__QueueName'
              value: AzureQueues_QueueName
            }
            {
              name: 'KernelMemory__Services__AzureAISearch__Endpoint'
              value: AzureAISearch_Endpoint
            }
            {
              name: 'KernelMemory__Services__AzureOpenAIText__Endpoint'
              value: AzureOpenAIText_Endpoint
            }
            {
              name: 'KernelMemory__Services__AzureOpenAIText__Deployment'
              value: AzureOpenAIText_Deployment
            }
            {
              name: 'KernelMemory__Services__AzureOpenAIEmbedding__Endpoint'
              value: AzureOpenAIEmbedding_Endpoint
            }
            {
              name: 'KernelMemory__Services__AzureOpenAIEmbedding__Deployment'
              value: AzureOpenAIEmbedding_Deployment
            }
            {
              name: 'KernelMemory__Services__AzureAIDocIntel__Endpoint'
              value: AzureAIDocIntel_Endpoint
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
    workloadProfileName: 'test'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }  
}

output kmServiceName string = containerapp.name
output kmServiceId string = containerapp.id
output kmServiceAccessKey1 string = KernelMemory__ServiceAuthorization__AccessKey1
output kmServiceAccessKey2 string = KernelMemory__ServiceAuthorization__AccessKey2
@description('The FQDN of the frontend web app service.')
output kmServiceFQDN string = containerapp.properties.configuration.ingress.fqdn
