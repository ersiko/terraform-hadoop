Hadoop cluster terraform templates and Ansible playbooks for Ambari / Hortonworks configuration.

Specify most cluster configuration variables in "variables.tf". So far only tested with CentOS 7 and Ambari. Java version and build are configurable from within each playbook (cnodes.yaml, mnodes.yaml and utility.yaml files).

Ansible host inventory and ambari server are automatically generated from template (see 'files.tf') and copied to the utility host for reference by playbook variable lookup. If changes are made to the cluster, it's critical to either re-launch the utility host and then re-run the site playbook, or update the ansiblehosts.txt manually and then re-run the site playbook.

A successful build should result in two addresses output. The public address should be used to connect your ssh proxy below, and the internal address to connect to your cluster on port 8080.

Master nodes are provisioned with MySQL repositories, and can be used to configure Hadoop services.

Instructions:

1. Create terraform.tfvars with AWS access key and secret key for your IAM account, IAM keypair and local keyfile.
2. Ensure terraform is installed. From the "hadoop" directory, run "terraform plan" and correct any errors.
3. Execute "terraform apply" and watch the build output. Current provisioners are CentOS-specific bash scripts.
4. Output from the terraform command includes the utility host's public dns address.
5. Connect to the remote network via ssh SOCKS proxy:

$ ssh -i ~/.ssh/myrsakey -D 55055 [terraform output: "util_public_dns"]

6. Configure your browser's proxy settings for SOCK5 operation on localhost:55055 and enable remote DNS
7. Now run the ansible playbooks, they should complete without failure:

$ ansible-playbook --private-key .ssh/mykey site.yaml

8. Connect to Ambari in your browser with:
 
HTTP://[terraform output: "util_private_dns"]:8080/    #(default login is admin:admin)

9. Launch the installation wizard (click the button, follow the steps); OR


// going to create a playbook for this step using the URI module http://docs.ansible.com/ansible/uri_module.html
9. Configure a blueprint and launch a cluster:

a. Get a list of blue prints (should be an empty set to start):

curl -H "X-Requested-By: Pythian" -X GET -u admin:admin http://[terraform output: "util_private_dns"]:8080/api/v1/blueprints

b. Post a blueprint (i.e. previously exported from a wizard-based setup):

curl -H "X-Requested-By: Pythian" -X POST -u admin:admin http://[terraform output: "util_private_dns"]:8080/api/v1/blueprints/testclus -d @testclus.json

c. Get a list of clusters (should be an empty set to start):
curl -H "X-Requested-By: Pythian" -X GET -u admin:admin http://[terraform output: "util_private_dns"]:8080/api/v1/clusters

d. Post a cluster configuration template (created from terraform output, a list of the cluster nodes (see blueprints/hostmap.json):

curl -H "X-Requested-By: Pythian" -X POST -u admin:admin http://[terraform output: "util_private_dns"]:8080/api/v1/clusters -d @hostmap.json

{
  "href" : "[terraform output: "util_private_dns"]:8080/api/v1/clusters/testclus/requests/1",
  "Requests" : {
    "id" : 1,
    "status" : "Accepted"
}

e. Note that at this point, the cluster should begin building. Agents are pre-registered by ansible to ensure they are available for the build.
