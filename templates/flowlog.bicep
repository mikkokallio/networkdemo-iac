
param region string
param vmName string
param nsgId string
param storageId string
param logsId string

// Flow logs go into the NetworkWatcherRG, and deployment causes: Can not perform requested operation on nested resource. Parent resource 'NetworkWatcher_northeurope' not found.
resource flowlog 'microsoft.network/networkwatchers/flowlogs@2021-08-01' = {
  name: 'NetworkWatcher_${region}/flowlog-${vmName}'
  location: region
  properties: {
    targetResourceId: nsgId
    storageId: storageId
    enabled: true
    format: {
      type: 'JSON'
      version: 2
    }
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceResourceId: logsId
        trafficAnalyticsInterval: 10
      }
    }
    retentionPolicy: {
      days: 7
      enabled: true
    }
  }
}
