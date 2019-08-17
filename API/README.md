# Use API to Connect an App deployed within VPC to a VCS deployment outside VPC

## Documented Steps
To build this scenario we will first deploy the VPC infrastructure to host virtual server that will run the Demo application that is going to be integrated with the VCS hosted machine.

### Prerequisites

1. Generate an [IBM Cloud API Key](https://cloud.ibm.com/docs/iam?topic=iam-userapikey)\
    Once generated, create an environment variable labeled `apikey`.  Example:
    `apikey=<value of your apikey>`
2. Have access to a public SSH key.
3. curl command
4. Have an instance of [VMware vCenter Server (VCS)](https://cloud.ibm.com/docs/services/vmwaresolutions?topic=vmware-solutions-vc_vcenterserveroverview) on IBM Cloud.

### Generate an IAM Bearer Token
[Documentation](https://cloud.ibm.com/docs/iam?topic=iam-iamtoken_from_apikey)\
Issue the following to generate a Bearer token:

```
curl -k -X POST \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --header "Accept: application/json" \
  --data-urlencode "grant_type=urn:ibm:params:oauth:grant-type:apikey" \
  --data-urlencode "apikey=$apikey" \
  "https://iam.cloud.ibm.com/identity/token"
```

Response:
```
{
  "access_token": "eyJhbGciOiJIUz......sgrKIi8hdFs",
  "refresh_token": "SPrXw5tBE3......KBQ+luWQVY=",
  "token_type": "Bearer",
  "expires_in": 3600,
  "expiration": 1473188353
}
```

Store the response variable access_token in an environment variable called iam_token:\
  `iam_token="eyJhbGciOiJIUz......sgrKIi8hdFs"`



### Deploy VPC Infrastructure   

### Retrieve list of Resource Groups
```
curl -k -X GET -H "Accept: application/json"    -H "Authorization: Bearer $iam_token"   -H "Content-Type: application/json"   -H "Cache-Control: no-cache" https://resource-manager.bluemix.net/v1/resource_groups | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  5944  100  5944    0     0   5514      0  0:00:01  0:00:01 --:--:--  5932
{
  "resources": [
    {
      "id": "03bf4fd296f24eb19f0eced2a8fb6366",
      "crn": "crn:v1:bluemix:public:resource-controller::a/26a3d1a386bd2cc44df1997eb7ac0ef1::resource-group:03bf4fd296f24eb19f0eced2a8fb6366",
      "account_id": "26a3d1a386bd2cc44df1997eb7ac0ef1",
      "name": "arg",
      "state": "ACTIVE",
      "default": false,
      "quota_id": "a3d7b8d01e261c24677937c29ab33f3c",
      "quota_url": "/v1/quota_definitions/a3d7b8d01e261c24677937c29ab33f3c",
      "payment_methods_url": "/v1/resource_groups/03bf4fd296f24eb19f0eced2a8fb6366/payment_methods",
      "resource_linkages": [],
      "teams_url": "/v1/resource_groups/03bf4fd296f24eb19f0eced2a8fb6366/teams",
      "created_at": "2019-01-09T19:02:53.168Z",
      "updated_at": "2019-01-09T19:02:53.168Z"
    }
    {
      "id": "ed47c192ea664338aa1c3dec2d518d02",
      "crn": "crn:v1:bluemix:public:resource-controller::a/26a3d1a386bd2cc44df1997eb7ac0ef1::resource-group:ed47c192ea664338aa1c3dec2d518d02",
      "account_id": "26a3d1a386bd2cc44df1997eb7ac0ef1",
      "name": "test-group",
      "state": "ACTIVE",
      "default": false,
      "quota_id": "a3d7b8d01e261c24677937c29ab33f3c",
      "quota_url": "/v1/quota_definitions/a3d7b8d01e261c24677937c29ab33f3c",
      "payment_methods_url": "/v1/resource_groups/ed47c192ea664338aa1c3dec2d518d02/payment_methods",
      "resource_linkages": [],
      "teams_url": "/v1/resource_groups/ed47c192ea664338aa1c3dec2d518d02/teams",
      "created_at": "2018-03-21T20:00:22.168Z",
      "updated_at": "2018-03-21T20:00:22.168Z"
    },
    {
      "id": "fcc917908acd4614bb2f1118caaaded8",
      "crn": "crn:v1:bluemix:public:resource-controller::a/26a3d1a386bd2cc44df1997eb7ac0ef1::resource-group:fcc917908acd4614bb2f1118caaaded8",
      "account_id": "26a3d1a386bd2cc44df1997eb7ac0ef1",
      "name": "test3",
      "state": "ACTIVE",
      "default": false,
      "quota_id": "a3d7b8d01e261c24677937c29ab33f3c",
      "quota_url": "/v1/quota_definitions/a3d7b8d01e261c24677937c29ab33f3c",
      "payment_methods_url": "/v1/resource_groups/fcc917908acd4614bb2f1118caaaded8/payment_methods",
      "resource_linkages": [],
      "teams_url": "/v1/resource_groups/fcc917908acd4614bb2f1118caaaded8/teams",
      "created_at": "2018-03-14T18:12:44.297Z",
      "updated_at": "2018-03-14T18:12:44.297Z"
    }
  ]
}
```
Select the resource group where the VPC is going to be created, an environment variable called `resource_group`:\ needs to be exported: `export resource_group="03bf4fd296f24eb19f0eced2a8fb6366"`

### Create the VPC for the Application deployment
Note: This VPC will be called web-demo-vpc and stored under the resource group called arg

```
curl -X POST \
  "https://us-south.iaas.cloud.ibm.com/v1/vpcs" \
  -H "Authorization: Bearer $iam_token" \
  -H "User-Agent: IBM_One_Cloud_IS_UI/2.4.0" \
  -H "Content-Type: application/json" \
  -H "Cache-Control: no-cache" \
  -H "accept: application/json" \
  -d "{\"name\":\"wwindows-vpc\",\"resource_group\":{\"id\":\"$resource_group\"}}"
```

Response:
```
{
  "id": "57b0a0b2-534f-4fce-b7c7-2f22512ba834",
  "crn": "crn:v1:bluemix:public:is:us-south:a/26a3d1a386bd2cc44df1997eb7ac0ef1::vpc:57b0a0b2-534f-4fce-b7c7-2f22512ba834",
  "name": "web-demo-vpc",
  "href": "https://us-south.iaas.cloud.ibm.com/v1/vpcs/57b0a0b2-534f-4fce-b7c7-2f22512ba834",
  "status": "available",
  "is_default": false,
  "classic_peered": false,
  "created_at": "2019-02-01T19:43:27Z",
  "default_network_acl": {
    "id": "942a7195-1a3a-424e-98cd-0dc1ae1ea798",
    "href": "https://us-south.iaas.cloud.ibm.com/v1/network_acls/942a7195-1a3a-424e-98cd-0dc1ae1ea798",
    "name": "allow-all-network-acl-57b0a0b2-534f-4fce-b7c7-2f22512ba834"
  },
  "default_security_group": {
    "id": "2d364f0a-a870-42c3-a554-000001218401",
    "href": "https://us-south.iaas.cloud.ibm.com/v1/security_groups/2d364f0a-a870-42c3-a554-000001218401",
    "name": "entitle-juggle-breeches-reorder-superman-drum"
  },
  "resource_group": {
    "id": "03bf4fd296f24eb19f0eced2a8fb6366",
    "href": "https://resource-manager.bluemix.net/v1/resource_groups/03bf4fd296f24eb19f0eced2a8fb6366"
  }
}
```


### Confirm the prefix created for the VPC as part of the deployment, change them if required
Note: These prefixes are created by default

```

curl -s --request GET --http1.1 --url "https://us-south.iaas.cloud.ibm.com/v1/vpcs/$vpc_id/address_prefixes?version=2019-01-04"  --header "accept: application/json" --header "authorization: Bearer $iam_token" | jq
{
  "limit": 10,
  "first": {
    "href": "https://us-south.iaas.cloud.ibm.com/v1/vpcs/57b0a0b2-534f-4fce-b7c7-2f22512ba834/address_prefixes?limit=10"
  },
  "address_prefixes": [
    {
      "id": "36206138-71c6-4043-9554-ac56dce52a10",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/vpcs/57b0a0b2-534f-4fce-b7c7-2f22512ba834/address_prefixes/36206138-71c6-4043-9554-ac56dce52a10",
      "name": "dwell-dartboard-clamshell-genetics-shell-stilt",
      "cidr": "10.240.64.0/18",
      "zone": {
        "name": "us-south-2"
      },
      "created_at": "2019-02-01T19:43:27Z",
      "has_subnets": false,
      "is_default": true
    },
    {
      "id": "7b2cabb7-bcb1-4de1-94ba-53937a2c59b0",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/vpcs/57b0a0b2-534f-4fce-b7c7-2f22512ba834/address_prefixes/7b2cabb7-bcb1-4de1-94ba-53937a2c59b0",
      "name": "scribe-shed-puritan-stock-justifier-untracked",
      "cidr": "10.240.0.0/18",
      "zone": {
        "name": "us-south-1"
      },
      "created_at": "2019-02-01T19:43:27Z",
      "has_subnets": false,
      "is_default": true
    },
    {
      "id": "b873fe43-f4ec-4a37-a262-33fc6123dc72",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/vpcs/57b0a0b2-534f-4fce-b7c7-2f22512ba834/address_prefixes/b873fe43-f4ec-4a37-a262-33fc6123dc72",
      "name": "rut-runner-delirious-showplace-suffice-candle",
      "cidr": "10.240.128.0/18",
      "zone": {
        "name": "us-south-3"
      },
      "created_at": "2019-02-01T19:43:27Z",
      "has_subnets": false,
      "is_default": true
    }
  ]
}

```

### Create a VPC Subnet using the Address Prefix

Create a new VPC subnet in us-south-2 for ipv4-cidr-block 10.240.64.0/18.
The initial status of a newly created subnet is set to **pending**; you must
wait until the subnet staus is available before assiging any resources to it.

```

curl -s --request POST --http1.1 --url "https://us-south.iaas.cloud.ibm.com/v1/subnets?version=2019-01-01" --data '{"ipv4_cidr_block":"10.240.64.0/18","name":"web-demo-subnet","vpc":{"id":"57b0a0b2-534f-4fce-b7c7-2f22512ba834"},"zone":{"name":"us-south-2"}}' --header "accept: application/json" --header "authorization: Bearer $iam_token"

{
  "id": "0ee9d35c-c5b7-4fb3-a74c-325000a354c6",
  "name": "web-demo-subnet",
  "href": "https://us-south.iaas.cloud.ibm.com/v1/subnets/0ee9d35c-c5b7-4fb3-a74c-325000a354c6",
  "ipv4_cidr_block": "10.240.64.0/18",
  "available_ipv4_address_count": 16379,
  "total_ipv4_address_count": 16384,
  "ip_version": "ipv4",
  "zone": {
    "name": "us-south-2",
    "href": "https://us-south.iaas.cloud.ibm.com/v1/regions/us-south/zones/us-south-2"
  },
  "vpc": {
    "id": "57b0a0b2-534f-4fce-b7c7-2f22512ba834",
    "crn": "crn:v1:bluemix:public:is:us-south:a/26a3d1a386bd2cc44df1997eb7ac0ef1::vpc:57b0a0b2-534f-4fce-b7c7-2f22512ba834",
    "name": "windows-vpc",
    "href": "https://us-south.iaas.cloud.ibm.com/v1/vpcs/57b0a0b2-534f-4fce-b7c7-2f22512ba834"
  },
  "status": "pending",
  "created_at": "2019-02-06T02:49:53Z",
  "network_acl": {
    "id": "942a7195-1a3a-424e-98cd-0dc1ae1ea798",
    "href": "https://us-south.iaas.cloud.ibm.com/v1/network_acls/942a7195-1a3a-424e-98cd-0dc1ae1ea798",
    "name": "allow-all-network-acl-57b0a0b2-534f-4fce-b7c7-2f22512ba834"
  }
}

```

### Add a SSH key
Store the key in an environment variable by issuing the following command on the file that the public key is contained in:
`export ssh_key=$(cat ~/.ssh/id_rsa.pub)`

```
curl -X POST \
  "https://us-south.iaas.cloud.ibm.com/v1/keys" \
  -H "Authorization: Bearer $iam_token" \
  -H "User-Agent: IBM_One_Cloud_IS_UI/2.4.0" \
  -H "Content-Type: application/json" \
  -H "Cache-Control: no-cache" \
  -H "accept: application/json" \
  -d "{\"name\":\"web-tier\",\"public_key\":\"$ssh_key\",\"type\":\"rsa\"}"
```

Output
```
{
  "created_at": "2019-01-28T20:21:08.000Z",
  "crn": "crn:v1:bluemix:public:is:us-south:a/26a3d1a386bd2cc44df1997eb7ac0ef1::key:636f6d70-0000-0001-0000-0000001437a5",
  "fingerprint": "SHA256:bdSRdJ1cuG5SQiMQ0JplQ1WjODC2KH5ptscD9v1Q0ag",
  "href": "https://us-south.iaas.cloud.ibm.com/v1/keys/636f6d70-0000-0001-0000-0000001437a5",
  "id": "636f6d70-0000-0001-0000-0000001437a5",
  "length": 4096,
  "name": "access-key",
  "public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7tr42FB07TptWpFFEka29Lf1DppauLj8UTXMDsLVDCnhwVnwLzqPR0svuNjQaisJKlC1xE2FrrBAe7UnweSEJYv/FvqT7aXCuHsz6e1QyGfD9XlHHtsC715EyCfyRWlOKWPsz6oqNKaG/jnYFNWeA2I0HEKSQyM1SwuFxeOgbf+8exMfM2oChVHvhj5hhrSsHqZNZHqEvTH93OXIXWzBRk/HcLYmmW1el5NFNWEkTqyIYpf4OYyb9SfwSw9yDoVn92xa7kJUjZU7+s2FGq51WB6X2aJwGaw/kJORhx/R69u1cMwxsdhdKlG15jObwLfYGYRuxW6U0vsG5wChAhkzrAbhZ9UoGRzG91wIreprEpDOp+BeGl5uIQ7NMbKHoZPK9Kgy7gdxep4hK6nv+IlgJ3XjZIQjJWAInlwJPNaRJd3J2Sq5a0Z6EFHfU7iudsxI7lcIQliH5lJysLs8W3LDNoBrIZQSXhq/RYZIXeIwk8sWKg+AGk9zQ0WWLNwCO6qtOG7Ekqj4o9rCjYSPEyj9mf8sfQrt+3EUSPxEH0ViYbNU/k3I0LOEgIbrmdCGy27nFRCEDvQCpE1WyixyNPTWhwzZOz6PEGs3DHeTb661MmU7Yo0FlWbyh01ESWBCOi7mCwxL7g1gr2ywFT/n8zmAzrpd9QQ4zWxSEy2+6fqFbrw== demo@us.ibm.com",
  "type": "rsa"
}
```

Store the id:
`export ssh_key_id="636f6d70-0000-0001-0000-000000142e9b"`

### Setup the deployment VSI

Create a new VSI (instance) and set it up so that we can
login via Remote desktop protocol.

#### Check out available VPC Instance Profiles and Images

If you are not sure what VSI profiles are available,
then list them using the CLI. We will need to choose
one to use when we create the instance.

```


curl -s --request GET --http1.1 --url "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles?version=2019-01-01" --header "accept: application/json" --header "authorization: Bearer $iam_token"

{
  "first": {
    "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles?limit=50"
  },
  "limit": 50,
  "next": {},
  "total_count": 17,
  "profiles": [
    {
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::profile:b-62x248",
      "family": "balanced",
      "generation": "gc",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles/b-62x248",
      "name": "b-62x248"
    },
    {
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::profile:c-2x4",
      "family": "cpu",
      "generation": "gc",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles/c-2x4",
      "name": "c-2x4"
    },
    {
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::profile:b-4x16",
      "family": "balanced",
      "generation": "gc",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles/b-4x16",
      "name": "b-4x16"
    },
    {
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::profile:b-16x64",
      "family": "balanced",
      "generation": "gc",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles/b-16x64",
      "name": "b-16x64"
    },
    {
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::profile:c-16x32",
      "family": "cpu",
      "generation": "gc",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles/c-16x32",
      "name": "c-16x32"
    },
    {
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::profile:b-32x128",
      "family": "balanced",
      "generation": "gc",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles/b-32x128",
      "name": "b-32x128"
    },
    {
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::profile:m-4x32",
      "family": "memory",
      "generation": "gc",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles/m-4x32",
      "name": "m-4x32"
    },
    {
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::profile:m-2x16",
      "family": "memory",
      "generation": "gc",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles/m-2x16",
      "name": "m-2x16"
    },
    {
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::profile:b-2x8",
      "family": "balanced",
      "generation": "gc",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles/b-2x8",
      "name": "b-2x8"
    },
    {
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::profile:m-16x128",
      "family": "memory",
      "generation": "gc",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles/m-16x128",
      "name": "m-16x128"
    },
    {
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::profile:c-8x16",
      "family": "cpu",
      "generation": "gc",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles/c-8x16",
      "name": "c-8x16"
    },
    {
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::profile:c-4x8",
      "family": "cpu",
      "generation": "gc",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles/c-4x8",
      "name": "c-4x8"
    },
    {
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::profile:m-8x64",
      "family": "memory",
      "generation": "gc",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles/m-8x64",
      "name": "m-8x64"
    },
    {
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::profile:b-48x192",
      "family": "balanced",
      "generation": "gc",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles/b-48x192",
      "name": "b-48x192"
    },
    {
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::profile:c-32x64",
      "family": "cpu",
      "generation": "gc",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles/c-32x64",
      "name": "c-32x64"
    },
    {
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::profile:b-8x32",
      "family": "balanced",
      "generation": "gc",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles/b-8x32",
      "name": "b-8x32"
    },
    {
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::profile:m-32x256",
      "family": "memory",
      "generation": "gc",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles/m-32x256",
      "name": "m-32x256"
    }
  ]
}
```

If you are not sure what Image types (OS distributions) are available,
then list them using the CLI. We will need to choose
one to use when we create the instance.

```

curl -s --request GET --http1.1 --url "https://us-south.iaas.cloud.ibm.com/v1/images?version=2019-01-01" --header "accept: application/json" --header "authorization: Bearer $iam_token"

{
  "first": {
    "href": "https://us-south.iaas.cloud.ibm.com/v1/images?limit=50"
  },
  "limit": 50,
  "total_count": 8,
  "images": [
    {
      "architecture": "amd64",
      "created_at": "2018-10-30T06:12:06.651Z",
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::image:cc8debe0-1b30-6e37-2e13-744bfb2a0c11",
      "file": {
        "checksum": "cc8debe01b306e372e13744bfb2a0c11",
        "href": "ims://images/OS_CENTOS_7_X_MINIMAL_64_BIT"
      },
      "href": "https://us-south.iaas.cloud.ibm.com/v1/images/cc8debe0-1b30-6e37-2e13-744bfb2a0c11",
      "id": "cc8debe0-1b30-6e37-2e13-744bfb2a0c11",
      "name": "centos-7.x-amd64",
      "operating_system": {
        "name": "CentOS",
        "vendor": "CentOS",
        "version": "7.x - Minimal Install"
      },
      "status": "READY",
      "visibility": "public"
    },
    {
      "architecture": "amd64",
      "created_at": "2018-10-30T06:12:06.624Z",
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::image:660198a6-52c6-21cd-7b57-e37917cef586",
      "file": {
        "checksum": "660198a652c621cd7b57e37917cef586",
        "href": "ims://images/OS_DEBIAN_8_X_JESSIE_MINIMAL_64_BIT"
      },
      "href": "https://us-south.iaas.cloud.ibm.com/v1/images/660198a6-52c6-21cd-7b57-e37917cef586",
      "id": "660198a6-52c6-21cd-7b57-e37917cef586",
      "name": "debian-8.x-amd64",
      "operating_system": {
        "name": "Debian GNU/Linux",
        "vendor": "Debian",
        "version": "8.x jessie/Stable - Minimal Install"
      },
      "status": "READY",
      "visibility": "public"
    },
    {
      "architecture": "amd64",
      "created_at": "2018-10-30T06:12:06.705Z",
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::image:e15b69f1-c701-f621-e752-70eda3df5695",
      "file": {
        "checksum": "e15b69f1c701f621e75270eda3df5695",
        "href": "ims://images/OS_DEBIAN_9_X_STRETCH_MINIMAL_64_BIT"
      },
      "href": "https://us-south.iaas.cloud.ibm.com/v1/images/e15b69f1-c701-f621-e752-70eda3df5695",
      "id": "e15b69f1-c701-f621-e752-70eda3df5695",
      "name": "debian-9.x-amd64",
      "operating_system": {
        "name": "Debian GNU/Linux",
        "vendor": "Debian",
        "version": "9.x Stretch/Stable - Minimal Install"
      },
      "status": "READY",
      "visibility": "public"
    },
    {
      "architecture": "amd64",
      "created_at": "2018-10-30T06:12:06.537Z",
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::image:7eb4e35b-4257-56f8-d7da-326d85452591",
      "file": {
        "checksum": "7eb4e35b425756f8d7da326d85452591",
        "href": "ims://images/OS_UBUNTU_16_04_LTS_XENIAL_XERUS_MINIMAL_64_BIT_FOR_VSI"
      },
      "href": "https://us-south.iaas.cloud.ibm.com/v1/images/7eb4e35b-4257-56f8-d7da-326d85452591",
      "id": "7eb4e35b-4257-56f8-d7da-326d85452591",
      "name": "ubuntu-16.04-amd64",
      "operating_system": {
        "name": "Ubuntu Linux",
        "vendor": "Canonical",
        "version": "16.04 LTS Xenial Xerus Minimal Install"
      },
      "status": "READY",
      "visibility": "public"
    },
    {
      "architecture": "amd64",
      "created_at": "2018-10-30T06:12:06.510Z",
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::image:cfdaf1a0-5350-4350-fcbc-97173b510843",
      "file": {
        "checksum": "cfdaf1a053504350fcbc97173b510843",
        "href": "ims://images/OS_UBUNTU_18_04_LTS_BIONIC_BEAVER_MINIMAL_64_BIT"
      },
      "href": "https://us-south.iaas.cloud.ibm.com/v1/images/cfdaf1a0-5350-4350-fcbc-97173b510843",
      "id": "cfdaf1a0-5350-4350-fcbc-97173b510843",
      "name": "ubuntu-18.04-amd64",
      "operating_system": {
        "name": "Ubuntu Linux",
        "vendor": "Canonical",
        "version": "18.04 LTS Bionic Beaver Minimal Install"
      },
      "status": "READY",
      "visibility": "public"
    },
    {
      "architecture": "amd64",
      "created_at": "2018-10-30T06:12:06.678Z",
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::image:b45450d3-1a17-2226-c518-a8ad0a75f5f8",
      "file": {
        "checksum": "b45450d31a172226c518a8ad0a75f5f8",
        "href": "ims://images/OS_WINDOWS_2012_FULL_STD_64_BIT"
      },
      "href": "https://us-south.iaas.cloud.ibm.com/v1/images/b45450d3-1a17-2226-c518-a8ad0a75f5f8",
      "id": "b45450d3-1a17-2226-c518-a8ad0a75f5f8",
      "name": "windows-2012-amd64",
      "operating_system": {
        "name": "Windows Server",
        "vendor": "Microsoft",
        "version": "2012 Standard Edition"
      },
      "status": "READY",
      "visibility": "public"
    },
    {
      "architecture": "amd64",
      "created_at": "2018-10-30T06:12:06.564Z",
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::image:81485856-df27-93b8-a838-fa28a29b3b04",
      "file": {
        "checksum": "81485856df2793b8a838fa28a29b3b04",
        "href": "ims://images/OS_WINDOWS_2012_R2_FULL_STD_64_BIT"
      },
      "href": "https://us-south.iaas.cloud.ibm.com/v1/images/81485856-df27-93b8-a838-fa28a29b3b04",
      "id": "81485856-df27-93b8-a838-fa28a29b3b04",
      "name": "windows-2012-r2-amd64",
      "operating_system": {
        "name": "Windows Server",
        "vendor": "Microsoft",
        "version": "2012 R2 Standard Edition"
      },
      "status": "READY",
      "visibility": "public"
    },
    {
      "architecture": "amd64",
      "created_at": "2018-10-30T06:12:06.590Z",
      "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::image:5ccbc579-dc22-0def-46a8-9c2e9b502d37",
      "file": {
        "checksum": "5ccbc579dc220def46a89c2e9b502d37",
        "href": "ims://images/OS_WINDOWS_2016_FULL_DC_64_BIT_VIRTUAL"
      },
      "href": "https://us-south.iaas.cloud.ibm.com/v1/images/5ccbc579-dc22-0def-46a8-9c2e9b502d37",
      "id": "5ccbc579-dc22-0def-46a8-9c2e9b502d37",
      "name": "windows-2016-amd64",
      "operating_system": {
        "name": "Windows Server",
        "vendor": "Microsoft",
        "version": "2016 Standard Edition"
      },
      "status": "READY",
      "visibility": "public"
    }
  ]
}
```

#### Create the Windows Deployment VSI

```
INST_NAME="web-demo-vcs-instance"
VPC="57b0a0b2-534f-4fce-b7c7-2f22512ba834"
SUBNET="0ee9d35c-c5b7-4fb3-a74c-325000a354c6"
IMAGEID="7eb4e35b-4257-56f8-d7da-326d85452591"
KEYID="636f6d70-0000-0001-0000-000000142e9b"
ZONE="us-south-2"
PROFILE_NAME="b-2x8"
PORT_SPEED="1000"


curl -s --request POST --http1.1 --url "https://us-south.iaas.cloud.ibm.com/v1/instances?version=2019-01-01" --data '{"image":{"id":"cfdaf1a0-5350-4350-fcbc-97173b510843"},"keys":[{"id":"636f6d70-0000-0001-0000-000000142e9b"}],"name":"web-demo-vcs-instance","primary_network_interface":{"name":"primary","port_speed":1000,"subnet":{"id":"0ee9d35c-c5b7-4fb3-a74c-325000a354c6"}},"profile":{"name":"b-2x8"},"vpc":{"id":"57b0a0b2-534f-4fce-b7c7-2f22512ba834"},"zone":{"name":"us-south-2"}}' --header "accept: application/json" --header "authorization: Bearer $iam_token"

{
  "cpu": {
    "architecture": "amd64",
    "cores": 2,
    "frequency": 2000
  },
  "created_at": "2019-02-06T03:27:09.135Z",
  "crn": "crn:v1:bluemix:public:is:us-south-2:a/26a3d1a386bd2cc44df1997eb7ac0ef1::instance:da4e8162-08cd-4dae-92c4-14f10ec0d4b5",
  "href": "https://us-south.iaas.cloud.ibm.com/v1/instances/da4e8162-08cd-4dae-92c4-14f10ec0d4b5",
  "id": "da4e8162-08cd-4dae-92c4-14f10ec0d4b5",
  "image": {
    "crn": "crn:v1:bluemix:public:is:us-south:a/843f59bad5553123f46652e9c43f9e89::image:cfdaf1a0-5350-4350-fcbc-97173b510843",
    "href": "https://us-south.iaas.cloud.ibm.com/v1/images/cfdaf1a0-5350-4350-fcbc-97173b510843",
    "id": "cfdaf1a0-5350-4350-fcbc-97173b510843",
    "name": "ubuntu-18.04-amd64"
  },
  "memory": 8,
  "name": "web-demo-vcs-instance",
  "network_interfaces": [
    {
      "href": "https://us-south.iaas.cloud.ibm.com/v1/instances/da4e8162-08cd-4dae-92c4-14f10ec0d4b5/network_interfaces/43e230d2-b3d0-4da3-951f-9d92db713acc",
      "id": "43e230d2-b3d0-4da3-951f-9d92db713acc",
      "name": "primary",
      "primary_ipv4_address": "10.240.64.4",
      "subnet": {
        "crn": "crn:v1:bluemix:public:is:us-south-2:a/26a3d1a386bd2cc44df1997eb7ac0ef1::subnet:0ee9d35c-c5b7-4fb3-a74c-325000a354c6",
        "href": "https://us-south.iaas.cloud.ibm.com/v1/subnets/0ee9d35c-c5b7-4fb3-a74c-325000a354c6",
        "id": "0ee9d35c-c5b7-4fb3-a74c-325000a354c6",
        "name": "windows-subnet"
      }
    }
  ],
  "primary_network_interface": {
    "href": "https://us-south.iaas.cloud.ibm.com/v1/instances/da4e8162-08cd-4dae-92c4-14f10ec0d4b5/network_interfaces/43e230d2-b3d0-4da3-951f-9d92db713acc",
    "id": "43e230d2-b3d0-4da3-951f-9d92db713acc",
    "name": "primary",
    "primary_ipv4_address": "10.240.64.4",
    "subnet": {
      "crn": "crn:v1:bluemix:public:is:us-south-2:a/26a3d1a386bd2cc44df1997eb7ac0ef1::subnet:0ee9d35c-c5b7-4fb3-a74c-325000a354c6",
      "href": "https://us-south.iaas.cloud.ibm.com/v1/subnets/0ee9d35c-c5b7-4fb3-a74c-325000a354c6",
      "id": "0ee9d35c-c5b7-4fb3-a74c-325000a354c6",
      "name": "windows-subnet"
    }
  },
  "profile": {
    "crn": "crn:v1:bluemix:public:is:us-south:a/26a3d1a386bd2cc44df1997eb7ac0ef1::instance-profile:b-2x8",
    "href": "https://us-south.iaas.cloud.ibm.com/v1/instance/profiles/b-2x8",
    "name": "b-2x8"
  },
  "status": "pending",
  "vpc": {
    "crn": "crn:v1:bluemix:public:is::a/26a3d1a386bd2cc44df1997eb7ac0ef1::vpc:57b0a0b2-534f-4fce-b7c7-2f22512ba834",
    "href": "https://us-south.iaas.cloud.ibm.com/v1/vpcs/57b0a0b2-534f-4fce-b7c7-2f22512ba834",
    "id": "57b0a0b2-534f-4fce-b7c7-2f22512ba834",
    "name": "windows-vpc"
  },
  "zone": {
    "href": "https://us-south.iaas.cloud.ibm.com/v1/regions/us-south/zones/us-south-2",
    "name": "us-south-2"
  }
}

```

#### Reserve a Floating IP

Reserve a Floating IP. We will assign this to our VSI in
the next step so that it can have access to the internet.

```


curl -s --request POST --http1.1 --url "https://us-south.iaas.cloud.ibm.com/v1/floating_ips?version=2019-01-01" --data '{"name":"windows-fip","zone":{"name":"us-south-2"}}' --header "accept: application/json" --header "authorization: Bearer $iam_token"

{
  "id": "19f1f39e-2ca6-4e5e-8f30-649590e328b5",
  "crn": "",
  "name": "windows-fip",
  "address": "169.61.160.16",
  "href": "https://us-south.iaas.cloud.ibm.com/v1/floating_ips/19f1f39e-2ca6-4e5e-8f30-649590e328b5",
  "status": "pending",
  "created_at": "2019-02-06T03:33:20Z",
  "zone": {
    "name": "us-south-2",
    "href": "https://us-south.iaas.cloud.ibm.com/v1/regions/us-south/zones/us-south-2"
  },
  "target": null
}

```

#### Assign the Floating IP to our VSI

```
INSTANCE="da4e8162-08cd-4dae-92c4-14f10ec0d4b5"
NIC="43e230d2-b3d0-4da3-951f-9d92db713acc"
FIP="19f1f39e-2ca6-4e5e-8f30-649590e328b5"



curl -s --request PUT --http1.1 --url "https://us-south.iaas.cloud.ibm.com/v1/instances/da4e8162-08cd-4dae-92c4-14f10ec0d4b5/network_interfaces/43e230d2-b3d0-4da3-951f-9d92db713acc/floating_ips/19f1f39e-2ca6-4e5e-8f30-649590e328b5?version=2019-01-01" --header "accept: application/json" --header "authorization: Bearer $iam_token"


{
  "address": "169.61.160.16",
  "created_at": "2019-02-06T03:33:20.000Z",
  "crn": "crn:v1:bluemix:public:is:us-south:a/26a3d1a386bd2cc44df1997eb7ac0ef1::floating_ip:19f1f39e-2ca6-4e5e-8f30-649590e328b5",
  "href": "https://us-south.iaas.cloud.ibm.com/v1/floating_ips/19f1f39e-2ca6-4e5e-8f30-649590e328b5",
  "id": "19f1f39e-2ca6-4e5e-8f30-649590e328b5",
  "name": "windows-fip",
  "status": "available",
  "target": {
    "href": "https://us-south.iaas.cloud.ibm.com/v1/instances/a64586e8-e8ad-4c63-8573-3ca95cdb8354/network_interfaces/43e230d2-b3d0-4da3-951f-9d92db713acc",
    "id": "43e230d2-b3d0-4da3-951f-9d92db713acc",
    "name": "primary",
    "primary_ipv4_address": "10.240.64.4"
  },
  "zone": {
    "href": "https://us-south.iaas.cloud.ibm.com/v1/regions/us-south/zones/us-south-2",
    "name": "us-south-2"
  }
}

```

#### Assign a Security Group Rule for SSH access on port 22

Add a rule to our VSI NIC's security group to allow RDP traffic

```

curl -s --request POST --http1.1 --url "https://us-south.iaas.cloud.ibm.com/v1/security_groups/2d364f0a-a870-42c3-a554-000001183743/rules?version=2019-01-01" --data '{"direction":"inbound","ip_version":"ipv4","port_max":22,"port_min":22,"protocol":"tcp"}' --header "accept: application/json" --header "authorization: Bearer $iam_token"

{
  "id": "b597cff2-38e8-4e6e-999d-000002312175",
  "direction": "inbound",
  "ip_version": "ipv4",
  "protocol": "tcp",
  "port_min": 22,
  "port_max": 22
}
```

### Access the instance over ssh using the floating IP and install Apache HTTP for demo purposes
```
* ssh root@instance_floating_ip -i id_rsa.pub
* sudo yum -y install httpd
```
###  Test the installation of the webserver by accessing the port using a regular web browser from a VCS hosted VM with Internet connectivity
http://169.61.160.16:8080 (example IP)


