#!/bin/bash

active_gcp_project="$(gcloud config get-value project)"
project_name="$( basename $(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ))"

img_path="gcr.io/${active_gcp_project}/img-${project_name}"

echo ""
echo ""
echo "cloud build will be invoked for project ID [$active_gcp_project] and result in an image at [img-$img_path]. "
echo "build command: gcloud builds submit --tag $img_path"
echo ""
echo "Press any key to continue, or Ctrl-C to quit"
echo ""
read key

echo ""
echo "BUILD STARTED"
# Build image using gcloud builds
gcloud builds submit --tag ${img_path}
