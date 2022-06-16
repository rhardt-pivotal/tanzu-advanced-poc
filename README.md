# VMware Tanzu for Kubernetes Operators Proof of Concept (PoC) Test Plan

This PoC test plan and evaluation process focuses on demonstrating functional operation, capabilities, and features of the `VMware Tanzu for Kubernetes Operators` suite of products.

**IMPORTANT** - This pre-sales offering does not consider all best practices and recommendations for production or extended pilot use.  VMware strongly encourages Customers to thoroughly review all publicly available product documentation and engage with the Professional Services Organization and Partners before going forward with any production design decisions. The PoC evaluation system is not the appropriate platform for intensive and lengthy performance testing and evaluation.

## Intended Audience

This guide is for cloud architects, engineers, administrators, and developers whose organization has an interest integrating `VMware Tanzu for Kubernetes Operators` into their multi-cloud strategy and environments.

## System Users and Roles

>NOTE: BEFORE PROCEEDING TO THE TEST CASES, READ THIS SECTION IN ITS ENTIRETY AS IT INCLUDES PREPARATIONS AND PREREQUISITES REQUIRED TO SUCCESSFULLY RUN THE TEST CASES.

The test approach bases the test scenarios and executing the test procedures from the perspective of standard operations and development roles. System user accounts or groups of users map to roles defined within the specified IDP (LDAP, AD, OIDC).  Following user authentication, a user’s role association determines his/her level of authorization and entitlements while interacting with the interfaces and system resources.

This repo assumes that we have an external IDP source.  It will be necessary to create users, groups, and user -> group mappings in that IDP.  The following image provides a conceptual representation of how the test plan organizes users and groups membership.

Additional information on configuring [Identity Management](<https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.5/vmware-tanzu-kubernetes-grid-15/GUID-mgmt-clusters-deploy-ui.html#configure-identity-management-16>).

![Groups and Users](images/TestPlanGroupsUsers.png)

### vSphere/NSX-T Administrator

As a vSphere/NSX-T administrator, you will play an ancillary role in this POC.  You will execute some of the initial steps to set up infrastructure, then you'll pair with the DevOps engineer(s) to set up a management cluster.  At that point, the DevOps team should be self sufficient with the Tanzu Kubernetes components managing infrastructure.

#### NSX Advanced Load Balancer -> vCenter
This service account is set up in vCenter to allow NSX ADvanced Load Balancer to create virtual infrastructure.  It needs to be mapped to a vSphere role(s) the following vCenter privileges
* **Virtual Machine**
    * Change Configuration
        * Acquire disk lease
        * Add existing disk
        * Add new disk
        * Add or remove device
        * Advanced configuration
        * Change CPU count
        * Change Memory
        * Change Settings
        * Change Swapfile placement
        * Change resource
        * Configure Host USB device
        * Configure Raw device
        * Configure managedBy
        * Display connection settings
        * Extend virtual disk
        * Modify device settings
        * Query Fault Tolerance compatibility
        * Query unowned files
        * Reload from path
        * Remove disk
        * Rename
        * Reset guest information
        * Set annotation
        * Toggle disk change tracking
        * Toggle fork parent
        * Upgrade virtual machine compatibility
    * Edit Inventory
        * Create from existing
        * Create new         
        * Move
        * Register
        * Remove
        * Unregister
    * Guest Operations
        * Guest operation alias modification 
        * Guest operation alias query
        * Guest operation modifications
        * Guest operation program execution 
        * Guest operation queries        
    * Interaction
        * Answer question
        * Backup operation on virtual machine  
        * Configure CD media
        * Configure floppy media
        * Connect devices
        * Console interaction
        * Create screenshot
        * Defragment all disks
        * Drag and drop
        * Guest operating system management by VIX API         
        * Inject USB HID scan codes
        * Install VMware Tools
        * Pause or Unpause
        * Perform wipe or shrink operations
        * Power off
        * Power on
        * Record session on virtual machine
        * Replay session on virtual machine
        * Reset
        * Resume Fault Tolerance
        * Suspend
        * Suspend Fault Tolerance
        * Test failover
        * Test restart Secondary VM
        * Turn off Fault Tolerance
        * Turn on Fault Tolerance   
    * Provisioning
        * Allow disk access
        * Allow file access
        * Allow read-only disk access
        * Allow virtual machine download
        * Allow virtual machine files upload
        * Clone template
        * Clone virtual machine
        * Create template from virtual machine         
        * Customize guest
        * Deploy template
        * Mark as template
        * Mark as virtual machine
        * Modify customization specification
        * Promote disks
        * Read customization specifications         
* **vApp**
    * Add virtual machine
    * Assign resource pool
    * Assign vApp
    * Clone
    * Create
    * Delete
    * Export
    * Import
    * Move
    * Power off     
    * Power on     
    * Rename
    * Suspend
    * Unregister
    * View OVF environment
    * vApp application configuration     
    * vApp instance configuration
    * vApp managedBy configuration     
    * vApp resource configuration
* **Folder**
    * Create Folder

#### NSX Advanced Load Balancer -> NSX-T Manager
According to the documentation [here](<https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.5/vmware-tanzu-kubernetes-grid-15/GUID-mgmt-clusters-install-nsx-adv-lb.html#nsx-cloud-v152-13>) we currently require the NSX Manager **admin** account.

#### Tanzu Kubernetes Grid -> vCenter

We also need a service account the *Tanzu Kubernetes Grid* will use to create virtual infrastructure in vSphere.  The specific permissions for this service account are enumerated [here](<https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.5/vmware-tanzu-kubernetes-grid-15/GUID-mgmt-clusters-vsphere.html#required-permissions-for-the-vsphere-account-5>)


### DevOps Engineer

A DevOps engineer might be a Kubernetes developer and an application owner, a Kubernetes administrator, or combine functions of both. A DevOps engineer uses kubectl commands to deploy Tanzu Kubernetes Grid Guest clusters via a Tanzu Kubernetes Grid Management Cluster. Typically, a DevOps engineer does not need to be an expert on vSphere and NSX-T but has basic understanding about these technologies and how the TKG Management Cluster interacts with them.

Test cases involving the DevOps engineer role require at least one (1) user account in the IDP provider. The recommendation is to create a group such as one named DevOps in the identity source and add individual user accounts as members to the group.  After creating a management cluster and registering it with Tanzu Mission Control, we'll be able to map the IDP group to a TMC role that allows the DevOps engineer to use the management cluster to create guest clusters, assign policies, create backups, etc.

### Application Developer

Application developers translate business and product objectives into application code. They administer the application development lifecycle through CI/CD pipeline automation and an assortment of product integrations. They connect to a Tanzu Kubernetes Grid guest cluster and use kubectl commands or other tools such as Helm or Jenkins to deploy workloads, including pods, services, load balancers, and other resources.

Test cases involving the application developer role require ideally two (2) user accounts. The recommendation is to create two (2) groups such as DevTeamA and DevTeamB in the identity provider and add individual user accounts as members to the groups.  After the DevOps engineer deploys a TKG cluster, the DevOps engineer will have the ability to entitle the application developer with permissions to the TKG cluster in Tanzu Mission Control through standard Kubernetes RBAC policies.  Furthermore, TMC allows us to limit developers' access to particular namespaces, allowing for multi-tenant kubernetes clusters that can be safely used by multiple differentteams.

### VMware Software Build Information

For the deployed vSphere 7 with Tanzu PoC environment, populate the following table with the system components’ version and build number.

Software Product | Version | Build
--- | --- | --- |
VMware Cloud Foundation | x | x |
VMware vSphere ESXi | x | x |
VMware vCenter | x | x |
VMware NSX-T | x | x |
vRealize Operations Manager | x | x |
vRealize LogInsight | x | x |

### Software Tools

This POC requires a jumpbox or bastion server with network access to the Virtual Infrastructure management network as well as to the public internet.  We are not covering the specific complexities of http proxies or internal corporate trusted CAs in this version, though another workshop may be in the works to cover those issues.

You will need to install several tools onto the bastion box.  

* **kubectl**
    * installation instructions for version 1.22:
    ```sh
    curl -LO "https://dl.k8s.io/release/v1.22.10/bin/linux/amd64/kubectl"
    sudo mv kubectl /usr/local/bin
    ```
* **tanzu** cli with **Tanzu Kubernetes Grid** plugins:
    * installation documentation: [here](<https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.5/vmware-tanzu-kubernetes-grid-15/GUID-install-cli.html#install-the-tanzu-cli-2>)

* **tmc** cli to interact with Tanzu Mission Control:
    * download and login instructions [here](<https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-using/GUID-7EEBDAEF-7868-49EC-8069-D278FD100FD9.html>)
    

### Test-Cases-Inventory

#### Operator SC01: Make Virtual Infrastructure Components Available and Install Tanzu Baseline and 

Test Case ID | Test Case Description |
--- | --- |
[SC01-TC01](scenarios/operator/sc01-tc01.md) | Validate vCenter Installation |
[SC01-TC02](scenarios/operator/sc01-tc02.md) | Validate NSX-T Manager Installation with Necessary Network Segments |
[SC01-TC03](scenarios/operator/sc01-tc03.md) | Install NSX Advanced Load Balancer Controller OVA & Test Virtual Service |
[SC01-TC04](scenarios/operator/sc01-tc04.md) | Configure and Install a Tanzu Kubernetes Grid Management Cluster |

#### Operator SC02: Install Tanzu Baseline and Integrate with SaaS
Test Case ID | Test Case Description |
--- | --- |
[SC02-TC01](scenarios/operator/sc02-tc01.md) | Install Tanzu Kubernetes Grid Management Cluster |
[SC02-TC02](scenarios/operator/sc02-tc02.md) | Integrate Management Cluster with Tanzu Mission Control |
[SC02-TC03](scenarios/operator/sc02-tc03.md) | Validate IDP Integration with the Management Cluster and TMC-Configured Roles |


#### DevOps SC03: Provision and Manage Kubernetes Workload Clusters

Test Case ID | Test Case Description |
--- | --- |
[SC03-TC01](scenarios/devops/sc03-tc01.md) | Provision Tanzu Kubernetes Grid Guest Clusters Using the Tanzu CLI |
[SC03-TC02](scscenarios/devops/sc03-tc02.md) | Provision Tanzu Kubernetes Grid Guest Clusters Using Tanzu Mission Control |
[SC03-TC03](scenarios/devops/sc03-tc03.md) | Scale a Tanzu Kubernetes Grid Guest Cluster Using the Tanzu CLI|
[SC03-TC04](scenarios/devops/sc03-tc04.md) | Scale a Tanzu Kubernetes Grid Guest Cluster Using Tanzu Mission Control |
[SC03-TC05](scenarios/devops/sc03-tc05.md) | Delete a Tanzu Kubernetes Grid Clsuter Using Tanzu Mission Control |
[SC03-TC06](scenarios/devops/sc03-tc06.md) | Upgrade a Tanzu Kubernetes Grid Clsuter Using Tanzu Mission Control |
[SC03-TC07](scenarios/devops/sc03-tc07.md) | Set up and verify DevOps and Developer Access Policies using Tanzu Mission Control |
[SC03-TC08](scenarios/devops/sc03-tc08.md) | Backup and Restore a Cluster and All Volumes with Tanzu Mission Control Data Protection |
[SC03-TC09](scenarios/devops/sc03-tc09.md) | Create and Validate Load Balancer Services via NSX Advanced Load Balancer |
[SC03-TC10](scenarios/devops/sc03-tc10.md) | Integrate Tanzu Kubernetes Grid Clusters with vRops and vRLI |
[SC03-TC11](scenarios/devops/sc03-tc11.md) | Backup and Restore Clusters with Commvault |
[SC03-TC12](scenarios/devops/sc03-tc12.md) | Provision and Verify Encrypted Storage for Cluster Ephemeral Disk and Persistent Volumes |
[SC03-TC13](scenarios/devops/sc03-tc13.md) | Monitor and Observe Clusters with Tanzu Observability  |


#### DevOps SC04: Integrate with Existing DevOps Tooling

Test Case ID | Test Case Description |
--- | --- |
[SC04-TC01](scenarios/devops/sc04-tc01.md) | Integrate with Existing Jenkins Pipelines |
[SC04-TC02](scscenarios/devops/sc04-tc02.md) | Package and Deploy an Application with Carvel Kapp |
[SC04-TC03](scscenarios/devops/sc04-tc03.md) | Map out Future State App Delivery |
[SC04-TC04](scscenarios/devops/sc04-tc04.md) | Move Existing Applications onto Platform |

#### Security SC05: Implement Security Measures and Controls

Test Case ID | Test Case Description |
--- | --- |
[SC05-TC01](scenarios/security/sc05-tc01.md) | Auto-generate and Apply TLS Certificates with Cert-Manager |
[SC05-TC02](scscenarios/security/sc05-tc02.md) | Sync External Vault Secrets with Kubernetes Secrets |
[SC05-TC03](scscenarios/security/sc05-tc03.md) | Integrate Antrea CNI Features with NSX-T Distributed Firewall |
[SC05-TC04](scscenarios/security/sc05-tc04.md) | Apply and Verify Open Policy Agent Policies with Tanzu Mission Control and Gatekeeper |
[SC05-TC05](scscenarios/security/sc05-tc05.md) | Deploy a Multi-Cluster Distributed Application with E2E mTLS using Tanzu Service Mesh |
