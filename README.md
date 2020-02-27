# Infrastructure as Code 101 Workshop

This workshop introduces the basic concepts of infrastructure as code (IaC) and is a step by step guide teaches you how to manage modern cloud infrastructures using relevant Cloud Native technologies. Infrastructure as code (IaC) is the process of managing and provisioning cloud and IT resources via machine readable definition files. IaC enables organizations to provision, manage, and destroy compute resources using modern DevOps tools such as [Terraform][6] and [Pulumi][7] tools.

## Goals

- Understand the value of using Infrastructure as Code (IaC)
- Learn how to provision and deploy applications using IaC
- Go hands-on with various IaC tooling

## Prerequisites

Before you get started you'll need to have these things:

- [Google Cloud account][2]
- [Create a Google Cloud Project][3]
- [Create a Pulumi API Token and save it][4]
- [Install the Google Cloud SDK CLI locally][5]
- [Install the Docker Client locally][1]

### Create a Google Cloud Platform project

Use these instructions to [create a new Google Cloud project][3] in the google cloud web console.

### Create and get Google Cloud Project credentials

After creating a new project, you will need to create [Google Cloud credentials][10] in order to perform administrative actions using IaC tooling. 

- Go to the [Create Service Account Key page][11]. 
- Select the default service account or create a new one, select JSON as the key type, and click **Create**. 
- Save this JSON file in the `~/.config/gcloud/`directory and **rename** the file to `cicd_demo_gcp_creds.json`. This very **important** for enabling the gcloud cli in the container later on.

### Create Pulumi API Token

You'll need to get a Pulumi API to store your project state on Pulumi's backed cloud.

- Go to [app.pulumi.com/][4]
- Click > ***Select and Organization*** dropdown on the upper left side of the page and select your account
- Click > ***Settings*** on the page
- Click > ***Access Tokens*** on the left side of the page
- Click > ***New Access Token*** on the right side of the page
- Click > ***Create*** button and save the new API Token that was created. This will be used to initialize your Pulumi project later.

### Docker Pull IaC 101 Docker Image

At this point all of the prerequisites should be completed and you're to pull the docker image for this workshop. In terminal type the following `docekr pull` command.

```shell
docker pull ariv3ra/iac101
```

You should now have the `ariv3ra/iac101` docker image locally. You can verify buy running `docker images` and you should see the image listed in the results.

## Docker Run IaC101 container

Now we'll create a new Docker container based on the `ariv3ra/iac101` image which has all the IaC tools and code pre-baked. 

### Mounting the ~/.config/gcloud/ directory 

Before we run the new container you need the absilut path to your `~/.config/gcloud/` directory on my MacOs machine my absolute path is `/Users/angel/.config/gcloud/` be sure to get the absolute file path for the gcloud directory on your local machine.

### Run IaC101 container with mounts

Run this command in a terminal run but be sure to replace the `<your absolute path here>` bit with your actual absolute path to your local `glocud/`directory. If this is not correct the mount will fail and the container with not function properly.

```shell
docker run -it --name iactest --mount type=bind,source=<your absolute path here>.config/gcloud/,target=/root/.config/gcloud/ ariv3ra/iac101
```

### IaC101 Container is running

After running the previous `docker run` command your IaC101 should be up and running and you your terminal shell has dropped you into the running container. Every command you now run in your terminal shell will be executed the docker container from now on until you manually `exit` the container. The container has the Terraform and Pulumi CLI tools installed as well as example code for each that creates infrastructure in their respective tools. The container projects files are mapped as follows:

```shell
projects/
|_ terraform/gcp/compute/   # Contains the Terraform code files
|_ pulumi/gcp/compute/      # Contains the Pulumi code files
```

## Terraform Provision Infrastructure

Let's start with provisioning some resources in GCP using terraform code. The `main.tf ` in the `terraform/gcp/compute/` is the code that has our infrastructure defined. In this file we're creating a new compute instance that will install and run a Python Flask app packaged in Docker container. The terraform code will also create some Firewall rules that will allow public access to the app over port 5000.

Run this command in the terminal:

```shell
cd ~/project/terraform/gcp/compute/
```

### Terraform init

While in the `~/project/terraform/gcp/compute/` run this command:

```shell
terrform init
```

You should see results similar to the results below:

```shell
root@d9ce721293e2:~/project/terraform/gcp/compute# terraform init

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "google" (hashicorp/google) 3.10.0...

* provider.google: version = "~> 3.10"

Terraform has been successfully initialized!
```

### Terraform plan

Terraform has a command that allows you to dry run and validate your Terraform code without actually executing anything. The command is called `terraform plan` which also graphs all the actions and changes the terraform will executed against your existing infrastructure. In the terminal run:

```shell
terraform plan
```

You should see results similar to this:

```shell
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_compute_firewall.http-5000 will be created
  + resource "google_compute_firewall" "http-5000" {
      + creation_timestamp = (known after apply)
      + destination_ranges = (known after apply)
  }

    # google_compute_instance.default will be created
  + resource "google_compute_instance" "default" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + deletion_protection  = false
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + labels               = {
          + "container-vm" = "cos-stable-69-10895-62-0"
        }
      + machine_type         = "g1-small"
  }
  Plan: 2 to add, 0 to change, 0 to destroy.
```

As you can see Terraform is going to create new GCP resources for you based on the code in the `main.tf` file.

### Terraform apply

You're ready to create the new infrastructure and deploy the application. Run this command in the terminal:

```shell
terraform apply
```

Terraform prompt you to confirm your command so type yes and hit enter.

```shell
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

Terraform is not building your infrastructure and you should have an application up and running GCP shortly after terraform completes. Please note that the it take 3-5mins for the application to come online after Terraform completes. It's not an instant access because the backend systems are provisioning and bringing things online in the background.

You should see some results similar to:

```shell
Outputs:

Public_IP_Address = 34.74.75.17
```

The `Public_IP_Address` value is the IP Address that your app is running on so if you go to a browser and plug that number in plus `:5000` port address (it would look like this `34.74.75.17:5000` you should see you app running in GCP.

### Terraform destroy

Now that you have proof that your Google Compute instance and your application work, you  should run the `terraform destroy` command to destroy the assets that you created in this tutorial. You can leave it up and running, but be aware that there is a cost associated with any assets running in the Google Cloud Platform and you could be liable for those costs. Google gives a generous $300 credit for its free trial sign-up, but you could easily eat through that if you leave assets running. It's up to you, but running `terraform destroy` will terminate any running assets.

## Pulumi Provision Infrastructure

You've experienced building infrastructure using Terraform now you'll learn how to provision and deploy new infrastructure using Pulumi. The Pulumi example will create the same GCP resources previously using Pulumi code and tools. Pulumi enables you to define your infrastructure in programming languages which provides lots of flexibility. In this example we're using [Python][8] as our language. The `__main.py__` in the `~/project/pulumi/gcp/compute/` directory is where were going to define our code.

Be sure to have the Pulumi API Token you previously created available because you'll need it in the following sections.

The Pulumi example can be found in the `~/project/pulumi/gcp/compute/` directory. Run this command to change into the Pulumi example directory:

```shell
cd ~/project/pulumi/gcp/compute/
```

### Pulumi install Python dependencies

Since we're defining our IaC specs using Python we'll need to first install the Pulumi Python SDK dependencies. In the terminal run this command:

```shell
pip install -r ../requirements.txt
```

### Pulumi preview

Pulumi has dry-run command called `pulumi preview`. This command displays a preview of the updates to an existing stack whose state is represented by an existing state file. The new desired state is computed by running a Pulumi program, and extracting all resource allocations from its resulting object graph. These allocations are then compared against the existing state to determine what operations must take place to achieve the desired state. No changes to the stack will actually take place.

Run this command in the terminal:

```shell
pulumi preview
```

After running this you should see the following results prompting you for the Pulumi API Token you created earlier. At this time paste the token into the terminal. Please not that when pasting the API Token into the terminal NO values will be displayed and will remain invisible for security purposes. After you paste the token hit enter.

```shell
Manage your Pulumi stacks by logging in.
Run `pulumi login --help` for alternative login options.
Enter your access token from https://app.pulumi.com/account/tokens
    or hit <ENTER> to log in using your browser                   :
```

You may be prompted to select a stack in the terminal. If so select the `dev` option then hit enter. You should see results similar to this:

```shell
Previewing update (dev):
     Type                     Name                        Plan
 +   pulumi:pulumi:Stack      compute-dev                 create
 +   ├─ gcp:compute:Network   network                     create
 +   ├─ gcp:compute:Address   workshops-infra-as-code101  create
 +   ├─ gcp:compute:Instance  workshops-infra-as-code101  create
 +   └─ gcp:compute:Firewall  firewall                    create

Resources:
    + 5 to create
```

You've just enabled access to the Pulumi backend cloud which keeps track of the state of your infrastructures. Now you're ready to run some code.

### Pulumi up

To execute the Pulumi code use the command `pulumi up`. This command creates or updates resources in a stack. The new desired goal state for the target stack is computed by running the current Pulumi program and observing all resource allocations to produce a resource graph. This goal state is then compared against the existing state to determine what create, read, update, and/or delete operations must take place to achieve the desired goal state, in the most minimally disruptive way. This command records a full transactional snapshot of the stack’s new state afterwards so that the stack may be updated incrementally again later on.

In the terminal run:

``` shell
pulumi up
```

Select the `yes` option nd hit enter. The Pulumi app will execute and shortly you'll have a complete server running an application in GCP. You should see results similar to this:

```shell
Updating (dev):
     Type                     Name                        Status
 +   pulumi:pulumi:Stack      compute-dev                 created
 +   ├─ gcp:compute:Network   network                     created
 +   ├─ gcp:compute:Address   workshops-infra-as-code101  created
 +   ├─ gcp:compute:Firewall  firewall                    created
 +   └─ gcp:compute:Instance  workshops-infra-as-code101  created

Outputs:
    external_ip       : "34.74.75.17"
    instance_meta_data: {
        gce-container-declaration: "spec:\n  containers:\n    - name: workshops-infra-as-code101\n      image: ariv3ra/workshops-infra-as-code101:latest\n      stdin: false\n      tty: false\n  restartPolicy: Always\n"
    }
    instance_name     : "workshops-infra-as-code101"
    instance_network  : [
        [0]: {
            accessConfigs    : [
                [0]: {
                    natIp              : "34.74.75.17"
                    network_tier       : "PREMIUM"
                }
            ]
            name             : "nic0"
        }
    ]

Resources:
    + 5 created

Duration: 58s
```

In the results you'll see a `external_ip` key and it's value is the IP Address to the public facing application exposed on port 5000 so just like the previous Terraform example you can access the application in a browser. Remember to allow for a few minutes so the backend system can bring everything online.

## Pulumi destroy

Pulumi has a command to terminate all of the resources created call `pulumi destroy`. This command deletes an entire existing stack by name. The current state is loaded from the associated state file in the workspace. After running to completion, all of this stack’s resources and associated state will be gone.

Run `pulumi destroy` in the terminal and select the `yes` option when prompted to **permanently** destroy the GCP resources created.

## Summary

Congratulations you've just leveled up and now have experience provisioning and deploying applications to GCP using modern Infrastructure as Code tools [Terraform][6] and [Pulumi][7]. There is still lots to learn and I encourage you to start expanding your IaC skills. You can use the following resources to expand your knowledge:

- [Terraform Getting Started][12]
- [Pulumi Getting Started][13]
- [Docker Getting Started][14]


[1]: https://hub.docker.com/search/?type=edition&offering=community
[2]: https://cloud.google.com/free
[3]: https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project
[4]: https://app.pulumi.com/
[5]: https://cloud.google.com/sdk/docs/quickstarts
[6]: https://www.terraform.io/
[7]: https://www.pulumi.com/
[8]: https://www.python.org/
[9]: https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project
[10]: https://github.com/GoogleCloudPlatform/community/blob/master/tutorials/getting-started-on-gcp-with-terraform/index.md#getting-project-credentials
[11]: https://console.cloud.google.com/apis/credentials/serviceaccountkey
[12]: https://www.terraform.io/docs/cli-index.html
[13]: https://www.pulumi.com/docs/get-started/
[14]: https://docs.docker.com/get-started/