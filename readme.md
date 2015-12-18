Hadoop cluster terraform templates and Ansible playbooks for Ambari / Hortonworks configuration.

Specify most cluster configuration variables in "variables.tf".

So far only tested with CentOS 7 and Ambari.

Java version and build are configurable from within each playbook (cnodes.yaml, mnodes.yaml and utility.yaml files in playbooks/).

Ansible host inventory and ambari server are automatically generated from terraform output and copied to the utility host for reference. If changes are made to the cluster, it's critical stop all ambari agents and to either re-launch the utility host (to reconstruct the ansiblehosts.txt) and then re-run the site playbook, or to update the ansiblehosts.txt manually and then re-run the site playbook.

To stop the agents across the cluster and shut down the ambari server:

$ ansible-playbook --private-key .ssh/mykey stopagents.yaml

A successful build should result in two addresses output. The public address should be used to connect your ssh proxy below, and the internal address to connect to your cluster on port 8080.

Master nodes are provisioned with MySQL repositories, and can be used to configure Hadoop services.

Instructions (after git clone and cd to your cloned directory):

1. Create terraform.tfvars with AWS access key and secret key for your IAM account, IAM keypair and local keyfile.
2. Ensure terraform is installed. From the main project directory, run "terraform plan" and correct any errors.
3. Execute "terraform apply" and watch the build output.
4. Output from the terraform command includes the utility host's private and public dns addresses.
5. Connect to the remote network via ssh SOCKS proxy:

$ ssh -i ~/.ssh/myrsakey -D 55055 [terraform output: "util_public_dns"]

6. Configure your browser's proxy settings for SOCK5 operation on localhost:55055 and enable remote DNS
7. From the utility host, run the ansible playbooks, they should complete without failure:

$ ansible --private-key .ssh/mykey all -m ping  # checking hosts are up and accepting host authenticity here
$ ansible-playbook --private-key .ssh/mykey site.yaml  # configure the cluster hosts, ambari server and agents, cluster config commented out
$ ansible-playbook --private-key .ssh/mykey cluster.yaml  # configure the cluster services, depends on hostmap.tpl manual update (for now)

8. Connect to Ambari in your browser with:
 
HTTP://[terraform output: "util_private_dns"]:8080/    #(default login is admin:admin)

...and watch the cluster build!

Useful curl commands for manual execution/verification (these steps are completed by the cluster playbook):


List your registered hosts to confirm ambari knows about them:

curl -H "X-Requested-By: Pythian" -X GET -u admin:admin http://[terraform output: "util_private_dns"]:8080/api/v1/hosts

Get a list of registered blueprints:

curl -H "X-Requested-By: Pythian" -X GET -u admin:admin http://[terraform output: "util_private_dns"]:8080/api/v1/blueprints

Post a blueprint to the Ambari server:

curl -H "X-Requested-By: Pythian" -X POST -u admin:admin http://[terraform output: "util_private_dns"]:8080/api/v1/blueprints/testclus -d @testclus.json

Get a list of managed clusters:

curl -H "X-Requested-By: Pythian" -X GET -u admin:admin http://[terraform output: "util_private_dns"]:8080/api/v1/clusters

Post a cluster configuration template:

curl -H "X-Requested-By: Pythian" -X POST -u admin:admin http://[terraform output: "util_private_dns"]:8080/api/v1/clusters -d @hostmap.json

{
  "href" : "[terraform output: "util_private_dns"]:8080/api/v1/clusters/testclus/requests/1",
  "Requests" : {
    "id" : 1,
    "status" : "Accepted"
}

