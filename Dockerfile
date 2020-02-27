# Builds the image for the Infrastrucure as Code 101 Workshop

# FROM cimg/base:2020.01
FROM python:3.8.1

RUN apt update && apt install -y nano spell

WORKDIR /root/

# Install Google-Cloud-SDK CLI tool
RUN curl -o gcp-cli.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz \
    && tar -xzvf gcp-cli.tar.gz \
    && ./google-cloud-sdk/install.sh  --quiet && echo 'export PATH=$PATH:~/google-cloud-sdk/bin' >> ~/.bashrc 
    
# Install Terraform CLI
RUN curl -o terraform-cli.zip https://releases.hashicorp.com/terraform/0.12.21/terraform_0.12.21_linux_amd64.zip \
    && unzip terraform-cli.zip && mv terraform /usr/local/bin/ && terraform version \
    && rm -rf terraform-cli.zip

# Install Pulumi CLI    
RUN curl -fsSL https://get.pulumi.com | sh && ~/.pulumi/bin/pulumi version && echo 'export PATH=$PATH:~/.pulumi/bin' >> ~/.bashrc

# Create Terraform and Pulumi directories to store code
RUN mkdir -p project/terraform project/pulumi/

# Copy the Terraform and Pulumi code
ADD terraform/ project/terraform/
ADD pulumi/ project/pulumi/

WORKDIR /root/project

CMD [ "/bin/bash" ]