# Uninstall

## What gets deleted
1. DataScienceCluster custom resource instance
1. DSCInitialization custom resource instance
1. FeatureTracker custom resource instances created during or after installation
1. ServiceMesh custom resource instance created by the Operator during or after installation
1. KNativeServing custom resource instance created by the Operator during or after installation
1. redhat-ods-applications, redhat-ods-monitoring, and rhods-notebooks namespaces created by the Operator
1. Workloads in the rhods-notebooks namespace
1. Subscription, ClusterServiceVersion, and InstallPlan objects
1. KfDef object (version 1 Operator only)
## What gets left
1. Data science projects created by users
1. Custom resource instances created by users
1. Custom resource definitions (CRDs) created by users or by the Operator

Run the uninstall.sh script
`./Uninstallation/uninstall.sh`