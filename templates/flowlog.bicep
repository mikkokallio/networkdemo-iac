
param region string
param vmName string
param storageId string
param logsId string

resource watcher 'Microsoft.Network/networkWatchers@2021-08-01' existing = {
  name: 'NetworkWatcher_${region}'
  scope: resourceGroup('NetworkWatcherRG')
}

// Flow logs go into the NetworkWatcherRG, and deployment causes: Can not perform requested operation on nested resource. Parent resource 'NetworkWatcher_northeurope' not found.
resource flowlog 'microsoft.network/networkwatchers/flowlogs@2021-08-01' = {
  name: 'NetworkWatcher_${region}/flowlog-${vmName}'
  location: region
  properties: {
    targetResourceId: watcher.id
    storageId: storageId
    enabled: true
    format: {
      type: 'JSON'
      version: 2
    }
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceId: logsId
        //workspaceRegion: ""
        //workspaceResourceId: workspaceResourceId
        trafficAnalyticsInterval: 10
      }
    }
    retentionPolicy: {
      days: 7
      enabled: true
    }
  }
}
