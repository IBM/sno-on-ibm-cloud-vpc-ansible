# Spin up a Single Node OpenShift Cluster on IBM Cloud

This is a set of Ansible playbooks that allow you to spin up an Single Node Openshift Cluster on IBM Cloud VPC by running a single Ansible playbook.  The playbooks  provision the required IBM Cloud resources  and  make use of Red Hat's [Assisted Installer service](https://github.com/openshift/assisted-service/tree/master/docs/user-guide) to automate the installation of the Single Node Cluster. The following are provisoned by the playbooks:

* A single Linux based VPC VSI running KVM with all the other required IBM Cloud components (a VPC instance, subnets, security groups, ssh keys etc)

* A KVM guest for the OpenShift Single Node Cluster on that VSI

* Another  KVM guest running Fedora 34 that provides DNS and DHCP services for the OpenShift Single Node Cluster KVM guest


https://console.redhat.com/openshift/assisted-installer/clusters


Running the master playbook to install the  OpenShift Single Node Cluster can be done with a single command but there are some prerequisites that must be in place  before running that command. 

## 1. Clone this repo 

Clone this Gothub repo to your local system

## 2. Setup Ansible
The playbooks have only  been tested with Ansible 2.9 (the Red Hat supported version) so it is recommended to use 2.9 to avoid potential incompatibilities  with other versions.

### 2.1 Install Ansible 2.9

The following table shows the install process for various Operating Systems

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
| IBM Cloud API Key | See instructions [here](https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui).|
| OpenShift Pull Secret | If you don't have a Red Hat subscription for OpenShift you can get a free Developer one [here](https://developers.redhat.com/articles/faqs-no-cost-red-hat-enterprise-linux).<br/> Once you have a subscription, Download the pull secret [here](https://console.redhat.com/openshift/install/pull-secret).|
| OpenShift Cluster Manager API Token | Copy the secret from [here](https://console.redhat.com/openshift/token/show). Save it in a local file called `token.txt`.|


##  Set the playbook variables 

TBD
