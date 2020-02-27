#/bin/bash


# docker build --rm=true -t ariv3ra/iac101:latest .
# docker build --rm=true -t ariv3ra/iac101:latest -t ariv3ra/iac101:1.0  .
# docker build --rm=true -t ariv3ra/iac101:latest -t ariv3ra/iac101:$(docker images | awk '($1 == "ariv3ra/iac101") {print $2 += .01; exit}') .
echo $DOCKER_PWD | docker login -u $DOCKER_LOGIN --password-stdin
docker push ariv3ra/iac101:latest

# General commands for this tutorial
# docker run -it --rm=true --name iactest --mount type=bind,source=/Users/angel/.config/gcloud/,target=/root/.config/gcloud/ ariv3ra/iac101
# gcloud auth activate-service-account --key-file ~/.config/gcloud/cicd_demo_gcp_creds.json
