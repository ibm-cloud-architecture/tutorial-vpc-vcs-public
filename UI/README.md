# Use GUI to Connect an App deployed within VPC to a VCS deployment outside VPC
### Prerequisites

1. Have an instance of [VMware vCenter Server (VCS)](https://cloud.ibm.com/docs/services/vmwaresolutions?topic=vmware-solutions-vc_vcenterserveroverview) on IBM Cloud.

### Documented Steps VPC infrastructure using the IBM Cloud console

### Login to IBM Cloud
Use IBMid or Softlayer ID as appropiate, notice that not all accounts have access to VPC infrastructure, please confirm with your IBM Cloud account master user.

![](Images/login.png)


### 1. Create the base VPC and the base subnet for the virtual server deployment.

Go to the VPC Getting Started External link icon page in IBM Cloud console.

![](Images/VPC%20creation%2001.png)

1. Click Create VPC on the Getting Started page.
2. Enter a name for the VPC, such as DemoWeb.
3. Select or create the default ACL for new subnets in this VPC. In this tutorial, let's create a new default ACL. We'll configure rules for the ACL later.
4. Enter a name for the new subnet in your VPC, such as DemoSubnet
5. Select a location for the subnet. The location consists of a region and a zone. 
6. Enter an IP range for the subnet in CIDR notation, for example: 10.240.0.0/18.
7. Select an ACL for the subnet. Let's select Use VPC default to use the default ACL that's created for this VPC.
8. Click Create virtual private cloud.

![](images/integration%20vpc%2001.png)

### 2. Confirm the VPC and subnet creation.
![](images/VPC%20creation%2003.png)

![](Images/VPC%20creation%2004.png)


### Create an SSH Key

An SSH key is required when creating a VPC instance. Copy the ssh public key you wish to use to vpc-key.pub and click over Add SSH Key to fill out the Name, Region and Public key contents, after that confirm that the key has been created.

![](Images/SSH%20creation%2001.png)

![](Images/SSH%20creation%2002.png)

![](Images/SSH%20creation%2003.png)

### 4. Create the base instances for web service instance

To create a virtual server instance in the newly created subnet:

1. Click **Virtual server instance** in the navigation pane and click **New instance**.
1. Enter a name for the instance, such as `DemoWeb`.
1. Select the VPC that you created.
1. Note the **Location** field (read-only) that shows the location of the subnet on which the instance is created.
1. Select an image (that is, operating system and version) such as CentOS Server 7.
1. To set the instance size, select one of the popular profiles or click **All profiles** to choose a different core and RAM combination that's most appropriate for your workload (profile Balanced 4x16)
1. Select an existing SSH key or add an SSH key that will be used to access the virtual server instance. 
1. In the **Network interfaces** area, you can change the name and port speed of the interface. If you have more than one subnet in your VPC, you can select the subnet that you want to attach to the instance.


You can also select which security groups to attach to this instance. By default, the VPC's default security group is attached. The default security group allows inbound SSH and ping traffic, all outbound traffic, and all traffic between instances in the group. All other traffic is blocked; you can configure rules to allow additional traffic. If you later edit the rules of the default security group, those updated rules will apply to all current and future instances in the group.

Click **Create virtual server instance**.

![](Images/VSI%20creation%2001.png)

![](images/virtual%20server%20instance.png)

![](Images/VSI%20creation%2003.png)

### 5. Reserve and associate a floating IP address to enable your instance to be reachable from the internet
**Tip:** Your instance must be running before you can associate a floating IP address. It can take a few minutes for the instance to be up and running.

To reserve and associate a floating IP address:

1. In the left navigation pane, click **Floating IP**.
1. Click **Reserve floating IP**.
1. Select the instance that you created and its network interface that you want to associate with the floating IP address.
1. Click **Reserve IP**. The new IP address is displayed on the Floating IPs page.

![](Images/Floating%20IP%2001.png)

![](images/Floating%20IP%20association.png)

### 6. The VPC is going to be associated with a security group, which has rules for inbound and outbound of traffic in case of IBM Spectrum symphony the entire 10.0.0.0/8 space was whitelisted (secured traffic), along with in this case a simple set of Floating IP's (that is public accessible IP's from the internet so it could be associated with at least the management node to be able to download software)

### 7. Check security groups attached to VPC circuit

You can configure the security group to define the inbound and outbound traffic that is allowed for the instance.

To configure the security group:

1. On the Virtual server instances page, click your new instance to view its details.
1. In the **Network interfaces** section, click the security group.
1. Click **Add rule** to configure inbound and outbound rules that define what traffic is allowed to and from of the instance. For each rule, specify the following information:  
   * Select which protocols and ports the rule applies to.   
   * Specify a CIDR block or IP address for the permitted traffic. Alternatively, you can specify a security group in the same VPC to allow traffic to or from all instances of the selected security group.    

   **Tips:**  
  * All rules are evaluated, regardless of the order in which they're added. 
  * Rules are stateful, which means that return traffic in response to allowed traffic is automatically permitted. For example, a rule that allows inbound TCP traffic on port 80 also allows replying outbound TCP traffic on port 80 back to the originating host, without the need for an additional rule.
1. _Optional:_ If you want to attach this security group to other instances, click **Attached interfaces** in the navigation pane  and select additional interfaces.
1. When you finish creating rules, click the **All security groups** breadcrumb at the top of the page.

### Example security group  

For example, you can configure inbound rules that do the following:

 * Allow all SSH traffic (TCP port 22)
 * Allow all ping traffic (ICMP type 8)
 
Then, configure outbound rules that allow all TCP traffic.

![](images/VPC%20security%20group.png)

### 7. Check current rules for security groups in the VPC (web application ports)
![](images/HPC%20security%20ports.png)

In case that any port is not open, use the following example to open the necessary port:

![](Images/Security%20group%2003.png)

### 8. Access the instance over ssh using the floating IP and install Apache HTTP for demo purposes, notice the RSA key used for SSH Key creation needs to be available.
```
* ssh root@instance_floating_ip
* sudo yum -y install httpd
```
### 9. Test the installation of the webserver by accessing the port using a regular web browser from a VCS hosted VM with Internet connectivity
http://169.61.244.100:8080 (example IP)
