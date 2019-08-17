# Use CLI to Connect an App deployed within VPC to a VCS deployment outside VPC

### Documented Steps VPC infrastructure

### Prerequisites

1. Install the [IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cloud-cli-getting-started)
2. Have access to a public SSH key.
3. Install the infrastructure-service plugin.  
   `$ ibmcloud plugin install infrastructure-service`
4. Have an instance of [VMware vCenter Server (VCS)](https://cloud.ibm.com/docs/services/vmwaresolutions?topic=vmware-solutions-vc_vcenterserveroverview) on IBM Cloud.

### Login to IBM Cloud

For a federated account use single sign on:  
   `$ ibmcloud login -sso`  
Otherwise use the default login:  
   `$ ibmcloud login`  
If you have an API Key, use --apikey:  
   `$ ibmcloud login --apikey [your API Key]`  

### 1. Create the base VPC
```
ibmcloud is vpc-create WEB-DEMO --default
###### Parameters: Name, default
Creating vpc WEB-DEMO in resource group default under account IBM - Mac's Org as user eariasn@us.ibm.com...
                            
ID                       a15040d1-8e16-4f3c-bcfb-942b3948d07a   
Name                     WEB-DEMO   
Default                  yes   
Default Network ACL      allow-all-network-acl-a15040d1-8e16-4f3c-bcfb-942b3948d07a(6d1b4afd-1ea6-41ec-8538-7c867e78c7c1)   
Default Security Group   -   
Resource Group           (e1d6e82017384baba3ecfb33f3f6a12c)   
Created                  5 seconds ago   
Status                   available 
```
### 2. Create the base subnet
```
ibmcloud is subnet-create WEB a15040d1-8e16-4f3c-bcfb-942b3948d07a us-south-1 --ipv4-cidr-block 10.240.10.0/24
###### Parameters: Name, VPC-ID, Region, IPV4-block
Creating Subnet WEB in resource group default under account IBM - Mac's Org as user eariasn@us.ibm.com...
                    
ID               5f09dce3-72fd-469e-a110-648fcc23cd9f   
Name             WEB   
IPv*             ipv4   
IPv4 CIDR        10.240.10.0/24   
IPv6 CIDR        -   
Addr available   251   
Addr Total       256   
ACL              allow-all-network-acl-a15040d1-8e16-4f3c-bcfb-942b3948d07a(6d1b4afd-1ea6-41ec-8538-7c867e78c7c1)   
Gateway          -   
Created          2 seconds ago   
Status           pending   
Zone             us-south-1   
VPC              WEB-DEMO(a15040d1-8e16-4f3c-bcfb-942b3948d07a)   
Resource Group   -  
```

### 3. Create an SSH Key

An SSH key is required when creating a VPC instance. Copy the ssh public key you wish to use to vpc-key.pub and call the key-create command to load it to the VPC environment. Remember the key id for later use.

```
$ ibmcloud is key-create vpc1-key @vpc-key.pub
Creating key vpc1-key under account Phillip Trent's Account as user pltrent@us.ibm.com...

ID            636f6d70-0000-0001-0000-00000014087d
Name          vpc1-key
Type          rsa
Length        2048
FingerPrint   SHA256:sAu2DF1zXNJQ99XghxZo7DXFXpPFO3PwWjY5a03VIPI
Key           ssh-rsa AAAAB3NzaC1BBBBBByc2EAAAADAQABAAABAQCnbhYSnc8DGQF3A3MR3zLynU4FF8UVVBjnctc3RTeNmWoRny4AJLpI06G9dlmC15QBzDMrNfy0srZnh/YMFlHcN5C73VbLdUJMj0QOqxYSPZgvKKKKrKlBn1WDjigOseO2/NmKIgk3d7lz/iEtkCNlNjNcRPWs3pPkh0NPxIMqsIwvxeWTVsv0OFktKAUA1uXvSFjx4JJRw7hy6tvgJVScbP2Mc2539pxGxiSAMNcqmHFWCQJhwIL2yHJiIcbZ33BDC1BbGg8XReCv0ZVmfXgSs+zuhJb9hDoVCElVDbzXaKs64zMREpy1NUzYQk4o9iahwLXp8gI8qOCzBx pltrent@phillips-mbp.raleigh.ibm.com

Created       1 second ago
```

### 4. Create the base instance for Web service application
```
ibmcloud is instance-create HPC-management a15040d1-8e16-4f3c-bcfb-942b3948d07a us-south-1 b-4x16 5f09dce3-72fd-469e-a110-648fcc23cd9f 1000 --image-id cc8debe0-1b30-6e37-2e13-744bfb2a0c11 --key-ids 636f6d70-0000-0001-0000-00000014087d
Creating instance WEB01 in resource group default under account IBM - Mac's Org as user eariasn@us.ibm.com...
###### Parameters: Name, VPC-ID, Region, Flavor, subnet, Network Speed, image-id, key-id

                     
ID                bf2c54ec-405a-47ac-b272-bc7088cf1da2   
Name              WEB-SERVICE   
Profile           b-4x16   
CPU Arch          amd64   
CPU Cores         4   
CPU Frequency     2000   
Memory            16   
Primary Intf      primary(8ba85a22-9f03-4291-8d6a-cddf03de181b)   
Primary Address   10.240.64.8   
Image             centos-7.x-amd64(cc8debe0-1b30-6e37-2e13-744bfb2a0c11)   
Status            pending   
Created           9 seconds ago   
VPC               vpc-hpc01(a15040d1-8e16-4f3c-bcfb-942b3948d07a)   
Zone              us-south-1   
Resource Group    -   
macbook-pro:bin earias
```
### 5. Reserve a floating IP for Web service application

```
* ibmcloud is  floating-ip-reserve WEB-eth0 --zone us-south-1
###### Parameters: Name, Region
ec9cfc2c-4430-4e49-8f02-3141c323d448   
169.61.244.40    
reforest-grab-banshee-kangaroo-headgear-syrup         
eth0(3084aaf3-.)                                                      
intf (10.240.0.4)
us-south-1 
```

### 6. Assign the floating IP to the instance that is going to host the web services
```
ibmcloud is instance-network-interface-floating-ip-add bf2c54ec-405a-47ac-b272-bc7088cf1da2 8ba85a22-9f03-4291-8d6a-cddf03de181b ec9cfc2c-4430-4e49-8f02-3141c323d448 
Creating floatingip e136da39-d05d-49b6-82f4-008c9b3bdc7a for instance 6e792d46-8c90-4288-89ac-4447ad46b2ef under account IBM - Mac's Org as user eariasn@us.ibm.com...
###### Parameters: Instance-id, Instance-interface-id, floating-ip-id

ID               e136da39-d05d-49b6-82f4-008c9b3bdc7a   
Address          169.61.244.40   
Name             WEB01-eth0   
Target           primary(8ba85a22-.)   
Target Type      intf   
Target IP        10.240.64.8   
Created          9 minutes ago   
Status           available   
Zone             us-south-1   
Resource Group   -   
Tags             -   

```

### 7. Check security groups attached to VPC circuit

```
ibmcloud is vpc a15040d1-8e16-4f3c-bcfb-942b3948d07a 
Getting vpc a15040d1-8e16-4f3c-bcfb-942b3948d07a under account IBM - Mac's Org as user eariasn@us.ibm.com...
#### Parameters: VPC-id
                            
ID                       a15040d1-8e16-4f3c-bcfb-942b3948d07a   
Name                     WEB-DEMO   
Default                  yes   
Default Network ACL      allow-all-network-acl-a15040d1-8e16-4f3c-bcfb-942b3948d07a(6d1b4afd-1ea6-41ec-8538-7c867e78c7c1)   
Default Security Group   vertigo-underpaid-expire-remarry-pupil-unsaved(2d364f0a-a870-42c3-a554-000001153485)   
Resource Group           (e1d6e82017384baba3ecfb33f3f6a12c)   
Created                  2 days ago   
Status                   available  
```

### 8. Check current rules for security groups in the VPC (SSH port 22 is required for access into the instance)
```
ibmcloud is security-group-rules 2d364f0a-a870-42c3-a554-000001153485
Listing rules of security group 2d364f0a-a870-42c3-a554-000001153485 under account IBM - Mac's Org as user eariasn@us.ibm.com...
#### Parameters: security-group-id
ID                                     Direction   IPv*   Protocol                      Remote   
b597cff2-38e8-4e6e-999d-000002259937   inbound     ipv4   tcp Ports:Min=22,Max=22         -      
b597cff2-38e8-4e6e-999d-000002259937   inbound     ipv4   tcp Ports:Min=8080,Max=8080         -      
b597cff2-38e8-4e6e-999d-000002251885   inbound     ipv4   all                           vertigo-underpaid-expire-remarry-pupil-unsaved(2d364f0a-.)   
b597cff2-38e8-4e6e-999d-000002251797   outbound    ipv4   all

In case that the port is not open, use the following example to open the necessary port:

ibmcloud is security-group-rule-add 2d364f0a-a870-42c3-a554-000001153485 inbound tcp --port-max 23 --port-min 23 --ip-version ipv4 
Creating rule for security group 2d364f0a-a870-42c3-a554-000001153485 under account IBM - Mac's Org as user eariasn@us.ibm.com...

#### Parameters: security-group-id, DIRECTION PROTOCOL, Max destination port, Min destination port, IP version
                          
ID                     b597cff2-38e8-4e6e-999d-000002275001   
Direction              inbound   
IPv*                   ipv4   
Protocol               tcp   
Min Destination Port   23   
Max Destination Port   23   
Remote                 -  

```

### 8. Access the instance over ssh using the floating IP and install Apache HTTP for demo purposes
```
* ssh root@instance_floating_ip
* sudo yum -y install httpd
```
### 9. Test the installation of the webserver by accessing the port using a regular web browser from a VCS hosted VM with Internet connectivity
http://169.61.244.100:8080 (example IP)