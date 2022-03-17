# Spin up a Single Node OpenShift Cluster on IBM Cloud

This is a set of Ansible playbooks that allow you to spin up an Single Node Openshift Cluster on IBM Cloud VPC by running a single master Ansible playbook.  The playbooks  provision the required IBM Cloud resources  and  make use of Red Hat's [Assisted Installer service](https://github.com/openshift/assisted-service/tree/master/docs/user-guide) to automate the installation of the Single Node Cluster. The following are provisoned by the playbooks:

* A single Linux based VPC VSI running KVM with all the other required IBM Cloud components (a VPC instance, subnets, security groups, ssh keys etc)

* A KVM guest for the OpenShift Single Node Cluster on that VSI

* Another  KVM guest running Fedora 34 that provides DNS and DHCP services for the OpenShift Single Node Cluster KVM guest


Running the master playbook to install the  OpenShift Single Node Cluster can be done with a single command but there are some prerequisites that must be in place  before running that command. 

## 1. Clone this repo 

From a terminal window, clone this Github repo to your local system.

```
   git clone <repo_url>
   
```

Go to the **ansible** sub-folder of the cloned repos root folder. **Note:** All subsequent command line instructions assume that you will be in this folder.

```
  cd sno-on-ibm-cloud-vpc-ansible/ansible

```

## 2. Setup Ansible
The playbooks have only  been tested with Ansible 2.9 (the Red Hat supported version) so it is recommended to use 2.9 to avoid potential incompatibilities  with other versions.

### 2.1 Install Ansible 2.9

The following table shows the install process for various Operating Systems:

| OS Family | Commands |
| --- | --- |
| RHEL/CentOS/Fedora/Rocky |  `dnf install epel-release`<br/>`dnf update`<br/>`dnf install ansible` |
| Ubuntu/Debian | `sudo apt update`<br/>`sudo apt install software-properties-common`<br/>`sudo apt-add-repository --yes --update ppa:ansible/ansible`<br/>`sudo apt install ansible-2.9`|
| MacOS | `brew install ansible@2.9` |
| Windows | TBD | 


### 2.2 Install required Ansible collections


Run the following commands:

``` 
    ansible-galaxy collection install ibm.cloudcollection

    ansible-galaxy collection install community.libvirt
```

## 3. Get required credentials

The following table lists the  credentials required by the playbooks.

| Credential | How to obtain |
| --- | --- |
| IBM Cloud API Key | See instructions [here](https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui). Download the API key as a file  or copy the value to your clipboard and paste it into a local file.|
| OpenShift Pull Secret | If you don't have a Red Hat subscription for OpenShift, you can get a free Developer one [here](https://developers.redhat.com/articles/faqs-no-cost-red-hat-enterprise-linux).<br/> Once you have a subscription, download the pull secret [here](https://console.redhat.com/openshift/install/pull-secret).|
| OpenShift Cluster Manager API Token | Copy the secret from [here](https://console.redhat.com/openshift/token/show). Save it in a local file called `token.txt`.|


##  4 Set the playbook variables 

### 4.1 Environment variables

The playbooks expect your  IBM Cloud API Key to be available as an environment variable. Execution will fail if this is not the  case. From the terminal window you opened in section **1.**  export the IBM Cloud API Key as follows:

```
   export IC_API_KEY="<your api key value>"
```

You can verify that the API Key has been setup correclty by running the following ad hoc Ansible command :

```
  ansible localhost -m ibm.cloudcollection.ibm_is_images_info -a "name=ibm-debian-11-2-minimal-amd64-1"

```

The output should look like the following:

```
localhost | SUCCESS => {
    "changed": false,
    "rc": 0,
    "resource": {
        "id": "2022-03-17 12:08:24.745036 +0000 UTC",
        "images": [
            {
                "architecture": "amd64",
                "checksum": "38a853cd338d8cea2b01b5b216da8d966310fc6aa3693b6cfb274522ccf6fe3e",
                "crn": "crn:v1:bluemix:public:is:us-south:a/811f8abfbd32425597dc7ba40da98fa6::image:r006-3bfa4c4f-9c9e-454b-83fb-2f473cc015bd",
                "encryption": "none",
                "encryption_key": "",
                "id": "r006-3bfa4c4f-9c9e-454b-83fb-2f473cc015bd",
                "name": "ibm-debian-11-2-minimal-amd64-1",
                "os": "debian-11-amd64",
                "source_volume": "",
                "status": "available",
                "visibility": "public"
            }
        ],
        "name": "ibm-debian-11-2-minimal-amd64-1",
        "resource_group": null,
        "visibility": null
    },
    "stderr": "",
    "stderr_lines": [],
    "stdout": "data.ibm_is_images.ansible_ibmdebian112minimalamd641: Refreshing state...\n\nWarning: Argument is deprecated\n\nThe generation field is deprecated and will be removed after couple of\nreleases\n\n\nApply complete! Resources: 0 added, 0 changed, 0 destroyed.\n",
    "stdout_lines": [
        "data.ibm_is_images.ansible_ibmdebian112minimalamd641: Refreshing state...",
        "",
        "Warning: Argument is deprecated",
        "",
        "The generation field is deprecated and will be removed after couple of",
        "releases",
        "",
        "",
        "Apply complete! Resources: 0 added, 0 changed, 0 destroyed."
    ]
}
```

### 4.2 OpenShift Pull Secret and OpenShift Cluster Manager API Token 

#### 4.2.1 Pull Secret

Copy the pull secret you downloaded in section **3.** (*pull-secret.txt*) to the *ansible/auth* folder in the directory tree of your local copy of this GH repo. 

#### 4.2.2 Cluster Manager API Token 

Copy the API token file  you saved in section **3.** (*token.txt*) to the *ansible/auth* folder in the directory tree of your local copy of this GH repo. 

#### 4.2.3 Required Playbook parameters

i. Create a copy of the  the file *ansible/auth/all.example*  in  the directory tree of your local copy of this GH repo. The copy should be in the same folder and named *all*

ii. Edit the file  *ansible/auth/all* replacing all the values set to `"*****change me*****"` with valid values. The table below gives more details about the required and optional parameters.

| Parameter | Type |  Description | Required | Default Value |
| --- | --- | --- | --- | --- |
| name_prefix | String | The prefix used for all IBM Cloud resources provisioned by the playbooks. Suffixes will be added to indicate the type of resource. For example `mynameprefix-vpc` for a VPC instance  and `mynameprefix-vsi` for a Virtual Server instamnce etc. | Yes | None |
| region | String | Short name of IBM Cloud region where VPC resources will be created .  e.g. us-south, us-east, eu-gb, jp-tok, au-syd etc | Yes | None |
| zone | String | Short name of IBM Cloud zone with selected region . It is the region short name with a numeric suffix. e.g. us-east-2 or eu-de-1 etc | Yes | None |
| resource_group_name | String | Name of existing IBM Cloud resource group in which  VPC resources will be created. | Yes | None |
| sno_cluster_name | String | Name of OpenShift cluster to be used by the Assisted Installer API | Yes | None |
| sno_domain_name | String | Name of OpenShift cluster domain name to be used by the Assisted Installer API . The format should be a valid domain e.g. `example.com`  but it does not have to resolveable via public DNS servers | Yes | None |
| setup_vsi_gui | Boolean | When set to true, the KVM VSI will be provioned with a GUI desktop and access via VNC will be configured. If false access to the KVM VSI will be via SSH only. | No | false |
| sno_version | String | OpenShift version to install. Valid values are "4.8","4.9" and "4.10" | No | "4.10" |





