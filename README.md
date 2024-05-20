# deploy-rhoai-self-managed

## User Inferface

One of the most important concepts is the OCP Project.

1. Applications
    1. Enabled (Jupyter) - a one-off notebook run in isolation
    1. Explore
1. Data Science Projects - a data science workflow
    1. Storage - 1:N persistent volumes provided by S3-compatible object storage buckets that retains the files and data you’re working on within a workbench
        1. Storage - bucket for storing your models and data
        1. Artifacts - bucket for your pipeline artifacts
    1. Data Connections - configuration parameters that are required to connect to a data source
        1. Object storage connection - To store pipeline artifacts. Must be S3 compatible
            1. Endpoint URL
            1. Access key
            1. Secret key
            1. Region
            1. Bucket name
        1. Database - To store pipeline data Use the default database to store data on your cluster, or connect to an external database.
            1. Use default database stored on your cluster
            1. Connect to external MySQL database
    1. Pipelines - data science pipelines that are executed within the project
        1. Pipeline server enables the creation, storing and management of pipelines
        1. Pipeline is the python code workflow or DAG that data scientists generate
    1. Workbenches - an isolated area where you can work with models in your preferred IDE, such as a Jupyter notebook, add accelerators and data connections, create pipelines, and add cluster storage in your workbench. [docs](https://access.redhat.com/documentation/en-us/red_hat_openshift_ai_self-managed/2.9/html/working_on_data_science_projects/creating-and-importing-notebooks_notebooks#notebook-images-for-data-scientists_notebooks)
        1. IDE Images
            1. Minimal Python
            1. Standard Data Science
            1. CUDA
            1. TensorFlow
            1. TrustyAI
            1. HabanaAI
            1. code-server (Elyra-based pipelines are not available)
        1. Deployment Size
            1. Small 2CPU, 8Gi
            1. Medium 3CPU 24Gi
            1. Large 7CPU 56Gi
            1. X Large 15CPU 120Gi
        1. Accelerator Profiles
            1. NVIDIA GPUs
            1. Habana Gaudi HPUs
        1. Environment Variables
        1. Cluster Storage
        1. Data Connections
            1. Create new data connections
            1. Use existing data connections
    1. Models - enables a model servers per data science project serve a trained model for real-time inference
        1. The model serving type can be changed until the first model is deployed from this project. After that, if you want to use a different model serving type, you must create a new project.
    1. Permissions - which users and groups can access the project
1. Data Science Pipelines - platforms for building and deploying portable and scalable machine-learning (ML) workflows visually with Elyra or using kfp SDK.
    1. Run Types
        1. Once
        1. Period
        1. Cron
    1. Schedule
        1. Max concurrent runs
        1. Timeframe
        1. Catchup if behind schedule
    1. Review the pipeline success
        1. Graph
        1. YAML
1. Distributed Workload Metrics - 
    1. Distributed Workloads - train complex machine-learning models or process data more quickly, by distributing  jobs on multiple worker nodes in parallel
        1. In 2.9 release of OpenShift AI, the only accelerators supported for distributed workloads are NVIDIA GPUs.
1. Model Serving - each project/workbench, you can specify only one model serving platform
    1. Single-model serving - Each model in the project is deployed on its own model server - suitable for large models or models that need dedicated resources.
    1. Multi-model serving - All models in the project are deployed on the same model server - suitable for sharing resources amongst deployed models.
1. Resources
1. Settings
    1. Notebook Images
    1. Cluster Settings
        1. Model serving platforms
            1. single-model serving platform
            1. multi-model serving platform
        1. PVC default sizes attached to notebooks from 1 GiB to 16384 GiB
        1. Stop idle notebooks between 10 minutes to 1000 hours
        1. Allow collection of usage data
        1. Notebook pod tolerations on tainted nodes
    1. Accelerator Profiles
        1. Details - An identifier is a unique string that names a specific hardware accelerator resource "nvidia.com/gpu" maps to 
        1. Tolerations - applied to pods and allow the scheduler to schedule pods with matching taints (key=nvidia-gpu-only) found on the MachineSets labels (cluster-api/accelerator=nvidia-gpu)
    1. Serving Runtimes - supports REST and gRPC API protocols
        1. Caikit TGIS ServingRuntimes for KServe for REST
            1. Serialized models:
                1. caitkit
        1. OpenVINO Model Server (single-model, multi-model) for REST 
            1. Serialized models:
                1. openvino v1
                1. onnx v1
                1. tensorflow v1, v2
                1. paddle v2
                1. pytorch v2
        1. TGIS Standalone ServingRuntime for KServe for gRPC
            1. Serialized models:
                1. pytorch
    1. User Management
        1. admin groups
        1. user groups

## Components

1. Dashboard
1. Curated Workbench Images (incl CUDA, PyTorch, Tensorflow, code-server)
    1. Ability to add Custom Images
    1. Ability to leverage accelerators (such as NVIDIA GPU)
1. Data Science Pipelines (including Elyra notebook interface) (Kubeflow pipelines)
1. Model Serving using ModelMesh and Kserve.
    1. Ability to use Serverless and Event Driven Applications as wells as configure secure gateways (Knative, OpenSSL)
    1. Ability to manages traffic flow and enforce access policies
    1. Ability to use other runtimes for serving (TGIS, Caikit-TGIS, OpenVino)
    1. Ability to enable token authorization for models that you deploy on the platform, which ensures that only authorized parties can make inference requests to the models (Authorino)
1. Model Monitoring
1. Distributed workloads (CodeFlare Operator, CodeFlare SDK, KubeRay, Kueue)
    1. You can run distributed workloads from data science pipelines, from Jupyter notebooks, or from Microsoft Visual Studio Code files.
    1. Ability to deploy Ray clusters with mTLS default
    1. Ability to control the remote distributed compute jobs and infrastructure
    1. Ability to manage remote Ray clusters on OpenShift
    1. Ability to run distributed workloads from data science pipelines, from Jupyter notebooks, or from Microsoft Visual Studio Code files.

Based on Red Hat OpenShift AI v2.9

|Component            |Purpose     |Dependency   |Resources          |Description      |
|---------------------|------------|-------------|-------------------|-----------------|
|operator             |            |             |                   |                 |
|dashboard            |management  |             |                   |                 |
|workbenches          |train       |             |                   |                 |
|datasciencepipelines |train       |S3 Store     |                   |                 |
|distributed workloads|train       |             |1.6 vCPU and 2 GiB |                 |
|                     |            |CodeFlare    |                   |Secures deployed Ray clusters and grants access to their URLs |
|                     |            |CodeFlare SDK|                   |controls the remote distributed compute jobs and infrastructure for any Python-based env|
|                     |            |Kuberay      |                   |KubeRay manages remote Ray clusters on OCP for running distributed workloads|
|                     |            |Kueue        |                   |Manages quotas, queuing and how distributed workloads consume them |
|modelmeshserving     |inference   |S3 Store     |                   |                 |
|kserve               |inference   |             |4 CPUs and 16 GB   |each model is deployed on a model server|
|                     |            |ServiceMesh  |4 CPUs and 16 GB   |                 |
|                     |            |Serverless   |4 CPUs and 16 GB   |                 |
|                     |            |Authorino    |                   |enable token authorization for models|



# CLI - per [docs](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/2.9/html/installing_and_uninstalling_openshift_ai_self-managed)
- [ ] oc login
- [ ] create cluster-admin
    - [ ] create cluster-admin via htpass
    - [ ] create secret for htpass
    - [ ] create and apply htpass custom resource
    - [ ] test login as cluster-admin
    - [ ] as Kubeadmin, add cluster-admin role
    - [ ] login as cluster-admin
- [ ] install the operator
    - [ ] create project redhat-ods-operator
    - [ ] create operator-group for redhat-operator
    - [ ] create a subscription for the redhat-ods-operator
- [ ] install the components
    - [ ] identify components
        - [ ] all
        - [ ] train-only
        - [ ] infer-only
    - [ ] ServiceMesh
        - [ ] verify/create istio-system project
        - [ ] install the servicemesh operator
        - [ ] create a ServiceMeshControlPlane
    - [ ] Serverless
        - [ ] install the operator
        - [ ] create knative-serving project for openshift-serverless
        - [ ] create the operator-group for openshift-serverless
        - [ ] create the subscription for serverless-operator
        - [ ] create the ServiceMeshMember object for knative-serving
        - [ ] create the knativeserving custom resource to inject and enable the istio side car
        - [ ] create a secure gateway for knative-serving with OpenSSL
            - [ ] create dir for wildcard certs and keys
            - [ ] create the OpenSSL configuration the wildcard certificate
            - [ ] generate a root certificate
            - [ ] generate a wildcard certificate signed by the root certificate
            - [ ] create a TLS secret in the istio-system namespace
            - [ ] create a gateways.yaml to define the service and ingress gateway w/ TLS secret
            - [ ] verify the the local and ingress gateways 
    - [ ] install the components
        - [ ] configure servicemesh, servleress and authorino to manual
            - [ ] change servicemesh to unmanaged in the default-dsci
            - [ ] change the kserve to managed in the default-dsc
            - [ ] change the kserve serving to unmanaged in the default-dcs
    - [ ] install authorino
        - [ ] apply the authorino subscription
        - [ ] create an authorino instance
            - [ ] create the redhat-ods-applications-auth-provider project
            - [ ] enroll the authorino project with service mesh
            - [ ] create an authorino instance 
            - [ ] patch the deployment to inject the istio sidecar to include apart of service mesh
            - [ ] Configure an Service Mesh instance to use Authorino as an extension provider
            - [ ] Create the AuthorizationPolicy resource in the namespace for your OpenShift Service Mesh instance
            - [ ] Create the EnvoyFilter resource in the namespace for your OpenShift Service Mesh instance
    - [ ] add a CA bundle
        - [ ] use self-signed certificates in a custom CA bundle separate from a cluster-wide bundle
    - [ ] Enabling the single-model serving platform via the Dashboard
    - [ ] Enabling GPU support
        - [ ] Creating Accelerator Profiles
        - [ ] Configuring accelerators for Notebook Images
        - [ ] Configuring accelerators for Serving Runtimes
- [ ] Distributed Workloads - per [docs](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/2.9/html/working_with_distributed_workloads)
    - [ ] verify the status of the following pods in the redhat-ods-applications project:   
        - [ ] codeflare-operator-manager
        - [ ] kuberay-operator
        - [ ] kueue-controller-manager
    - [ ] configure quota management
        - [ ] Create an empty Kueue resource flavor
        - [ ] Create a cluster queue to manage the empty Kueue resource flavor
            - [ ] Adjust the values per cluster
        - [ ] Create a local queue that points to your cluster queue
            - [ ] Configure the local_queue.yaml to cover all namespaces
            - [ ] Verify the status of the local queue
        - [ ] Configure the CodeFlare Operator
            - [ ] install the codeflare-cli
            - [ ] review the codeflare-operator-config configmap:
                - [ ] ingressDomain
                - [ ] mTLSEnabled
                - [ ] rayDashboardOauthEnabled
    - [ ] configure the Ray job specification to set submissionMode=HTTPMode only

# RHOAI Dashboard
- [ ] Tutorials - per [docs](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/2.9/html/openshift_ai_tutorial_-_fraud_detection_example)
    - [ ] Fraud Detection
        - [ ] Create workbench
        - [ ] Clone in repo
        - [ ] Train model
        - [ ] Store model 
        - [ ] Deploy the model on a single-model server
        - [ ] Deploy the model on a multi-model server
        - [ ] Configure Token authorization w/ service account
        - [ ] Test the inference API via Terminal
        - [ ] Build training with Elyra
            - Launch Elyra pipeline editor
            - Configure pipeline properties for the nodes
            - Drag the objects on the Elyra canvas
            - Configure the Node Properties for File Dependencies
            - Configure the data connection for the Node using Kubernetes Secrets
            - Execute the DAG from the pipeline editor
            - Inspect the Run Details 
                - [ ] Schedule the pipeline to run once
                - [ ] Schedule the pipeline to run on a schedule
        - [ ] Build training with kfp SDK
            - [ ] Import Pipeline coded with kfp SDK
- [ ] Running Distributed Workloads
    - [ ] From Notebooks
        - [ ] Clone the CodeFlare SDK notebooks to the Fraud demo workbench
        - [ ] From the terminal, login into the cluster
        - [ ] Run a distributed workload job
    - [ ] From Pipelines







TODO:
- [ ] Mirroing images for disconnected installation
- [ ] Model Serving runtimes using custom runtimes for TGI [source](https://access.redhat.com/documentation/en-us/red_hat_openshift_ai_self-managed/2.9/html/serving_models/serving-large-models_serving-large-models#adding-a-custom-model-serving-runtime-for-the-single-model-serving-platform_serving-large-models)
- [ ] Converting models to Caikit format [source](https://github.com/opendatahub-io/caikit-tgis-serving/blob/main/demo/kserve/built-tip.md#bootstrap-process)
- [ ] Service Mesh Control Plane customizations [source](https://access.redhat.com/documentation/en-us/red_hat_openshift_ai_self-managed/2.9/html/serving_models/serving-large-models_serving-large-models?extIdCarryOver=true&intcmp=701f2000001OMHaAAO&sc_cid=701f2000001Css5AAC#creating-a-knative-serving-instance_serving-large-models:~:text=Service%20Mesh%20control%20plane%20configuration%20reference)
- [ ] Using a TLS certificate to secure the mapped services for Knative Serving  [source-a](https://access.redhat.com/documentation/en-us/red_hat_openshift_ai_self-managed/2.9/html/serving_models/serving-large-models_serving-large-models?extIdCarryOver=true&intcmp=701f2000001OMHaAAO&sc_cid=701f2000001Css5AAC#creating-a-knative-serving-instance_serving-large-models) [source-b](https://docs.openshift.com/serverless/[ ]32/knative-serving/config-custom-domains/domain-mapping-custom-tls-cert.html)
- [ ] Creating a secure gateway for Knative Serving with a wildcard certificate [source](https://access.redhat.com/documentation/en-us/red_hat_openshift_ai_self-managed/2.9/html/serving_models/serving-large-models_serving-large-models?extIdCarryOver=true&intcmp=701f2000001OMHaAAO&sc_cid=701f2000001Css5AAC#creating-secure-gateways-for-knative-serving_serving-large-models)
- [ ] Configure a CA bundle [source](https://access.redhat.com/documentation/en-us/red_hat_openshift_ai_self-managed/2.9/html/installing_and_uninstalling_openshift_ai_self-managed/working-with-certificates_certs)
- [ ] Configure the cluster-wide proxy during installation [source](https://docs.openshift.com/container-platform/4.15/networking/configuring-a-custom-pki.html#installation-configure-proxy_configuring-a-custom-pki)
- [ ] Providing a CA bundle only for data science pipelines[source](https://access.redhat.com/documentation/en-us/red_hat_openshift_ai_self-managed/2.9/html/installing_and_uninstalling_openshift_ai_self-managed/working-with-certificates_certs#providing_a_ca_bundle_only_for_data_science_pipelines)
- [ ] Creating data science pipelines with Elyra and self-signed certificates [source](https://access.redhat.com/solutions/7046302)
- [ ] Dashboard configuration options [source](https://access.redhat.com/documentation/en-us/red_hat_openshift_ai_self-managed/2.9//html/managing_resources/customizing-the-dashboard#ref-dashboard-configuration-options_dashboard)
- [ ]  Adding a custom model-serving runtime for the single-model serving platform (source)[https://access.redhat.com/documentation/en-us/red_hat_openshift_ai_self-managed/2.9/html/serving_models/serving-large-models_serving-large-models?extIdCarryOver=true&intcmp=701f2000001OMHaAAO&sc_cid=701f2000001Css5AAC#adding-a-custom-model-serving-runtime-for-the-single-model-serving-platform_serving-large-models]

Questions
1. How can you remove self-provisioner from datascience-users?
1. How can datascience-admins pre-provision 1x workspace for datascience-users?
1. Do you have to create a distributed workloads local queue per project?