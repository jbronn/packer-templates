#!/bin/bash
set -euo pipefail

# Default values.
AMI_DISK_SIZE=8192
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-}"
BOX_VERSION="$(date +%Y%m%d).0.0"
BOX_NAME=""
MEMSIZE=512
PROVISIONER=default
REGION="${AWS_DEFAULT_REGION:-us-east-1}"
USAGE="no"
VAGRANT_CLOUD_TOKEN="${VAGRANT_CLOUD_TOKEN:-}"
VAGRANT_CLOUD_TOKEN_FILE=""
VAGRANT_CLOUD_USER="hoot"
VMIMPORT_BUCKET=""

# Retrieving command-line options.
while getopts ":i:n:t:u:v:" opt; do
    case "$opt" in
        i)
            VMIMPORT_BUCKET="$OPTARG"
            ;;
        n)
            BOX_NAME="$OPTARG"
            ;;
        t)
            VAGRANT_CLOUD_TOKEN_FILE="$OPTARG"
            ;;
        v)
            BOX_VERSION="$OPTARG"
            ;;
        *)
            USAGE=yes
            ;;
    esac
done
shift $((OPTIND-1))

# Document the usage for this script.
function usage() {
    echo "release.sh -n <Box Name> -i <VM Import S3 Bucket>"
    echo "  [-t <Vagrant Cloud Token JSON file>]"
    echo "  [-u <Vagrant Cloud User, default: '$VAGRANT_CLOUD_USER'>"
    echo "  [-v <Box Version, default: '$BOX_VERSION'>]"
    echo ""
    echo "  This script requires Vagrant Cloud and AWS credentials."
    echo "  AWS credentials may be specified in in ~/.aws/credentials or the"
    echo "  \$AWS_ACCESS_KEY_ID and \$AWS_SECRET_ACCESS_KEY environment"
    echo "  variables. The credentials must have IAM privileges to use the"
    echo "  AWS VM Import/Export service on the provided VM Import S3 Bucket."
    echo ""
    echo "  The Vagrant Cloud token may be provided via a JSON file with an"
    echo "  'access_token' key (-t option) or the \$VAGRANT_CLOUD_TOKEN "
    echo "  environment variable."
    exit 1
}

# If AWS credentials aren't passed in via environment variables, attempt
# to get them using the CLI tools.
if [ -z "$AWS_ACCESS_KEY_ID" -o -z "$AWS_SECRET_ACCESS_KEY" ]; then
    if [ -x "$(which aws)" ]; then
        AWS_ACCESS_KEY_ID="$(aws configure get aws_access_key_id || true)"
        AWS_SECRET_ACCESS_KEY="$(aws configure get aws_secret_access_key || true)"
    fi
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    printf "Error: AWS_ACCESS_KEY_ID is undefined.\n\n"
    USAGE=yes
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    printf "Error: AWS_SECRET_ACCESS_KEY is undefined.\n\n"
    USAGE=yes
fi

# Retrieve the Vagrant Cloud token from a JSON file that has an 'access_token'
# key (e.g., it could be used as a `-var-file` Packer argument).
if [ -f "$VAGRANT_CLOUD_TOKEN_FILE" ]; then
    VAGRANT_CLOUD_TOKEN="$(jq -M -r -s '(if .[0].access_token? then .[0].access_token else "" end)' "$VAGRANT_CLOUD_TOKEN_FILE")"
fi

if [ -z "$VAGRANT_CLOUD_TOKEN" ]; then
    printf "Error: VAGRANT_CLOUD_TOKEN is undefined.\n\n"
    USAGE=yes
fi

# Checking required arguments.
if [ -z "$BOX_NAME" ]; then
    printf "Error: Box name not provided.\n\n"
    USAGE=yes
fi

if [ -z "$VMIMPORT_BUCKET" ]; then
    printf "Error: VM Import S3 Bucket not provided.\n\n"
    USAGE=yes
fi

if [ "$USAGE" = "yes" ]; then
    usage
fi

case "$BOX_NAME" in
    centos7-hoot)
        AMI_DESCRIPTION="CentOS 7 Hootenanny v$BOX_VERSION"
        AMI_DISK_SIZE=12288
        MEMSIZE=4096
        PROVISIONER=hoot
        OS=centos
        OS_RELEASE=7.5
        ;;
    centos7-minimal)
        AMI_DESCRIPTION="CentOS 7 Minimal v$BOX_VERSION"
        OS=centos
        OS_RELEASE=7.5
        ;;
    bionic-minimal)
        AMI_DESCRIPTION="Ubuntu 18.04 (bionic) Minimal v$BOX_VERSION"
        OS=ubuntu
        OS_RELEASE=bionic
        ;;
    trusty-minimal)
        AMI_DESCRIPTION="Ubuntu 14.04 (trusty) Minimal v$BOX_VERSION"
        OS=ubuntu
        OS_RELEASE=trusty
        ;;
    *)
        echo "Do not know how to create a release for $BOX_NAME."
        exit 1
        ;;
esac

# Generate VirtualBox-provided Vagrant box.
OS=$OS OS_RELEASE=$OS_RELEASE POST_PROCESSOR=vagrant-cloud PROVISIONER=$PROVISIONER \
   ./build.sh \
   -var "vm_name=$BOX_NAME" \
   -var "box_tag=hoot/$BOX_NAME" \
   -var "box_version=$BOX_VERSION" \
   -var 'headless=true' \
   -var "memsize=$MEMSIZE" \
   -var 'ssh_wait_timeout=90m' \
   -var "access_token=$VAGRANT_CLOUD_TOKEN"

# Temporary directory for AWS-box files.
BOX_DIR="$(mktemp -d)"

# Generate AWS-provided Vagrant box.
OS=$OS OS_RELEASE=$OS_RELEASE POST_PROCESSOR=amazon-import PROVISIONER=$PROVISIONER \
  ./build.sh \
  -var "vm_name=$BOX_NAME" \
  -var "ami_description=$AMI_DESCRIPTION" \
  -var "box_version=$BOX_VERSION" \
  -var "disk_size=$AMI_DISK_SIZE" \
  -var 'headless=true' \
  -var "memsize=$MEMSIZE" \
  -var "region=$REGION" \
  -var 'ssh_wait_timeout=90m' \
  -var "s3_bucket_name=$VMIMPORT_BUCKET" \
  -var "access_key=$AWS_ACCESS_KEY_ID" \
  -var "secret_key=$AWS_SECRET_ACCESS_KEY" | tee "$BOX_DIR/packer-build.log"

# Determine the AMI ID from the build log.
BOX_AMI="$(awk "{ if (\$1 ~ /^$REGION:/ ) print \$2 }" < "$BOX_DIR/packer-build.log")"
if [ -z "$BOX_AMI" ]; then
    echo "Could not determine AMI from packer log: $BOX_DIR/packer-build.log"
    exit 1
fi

# Manually create box tarball with correct metadata.json and Vagrantfile.
pushd "$BOX_DIR"
cat > metadata.json <<EOF
{
    "provider": "aws"
}
EOF

cat > Vagrantfile <<EOF
Vagrant.configure('2') do |config|
  config.vm.provider :aws do |aws|
    aws.region_config '$REGION', ami: '$BOX_AMI'
  end
end
EOF

tar -czf aws.box metadata.json Vagrantfile
popd


# The base URL for the releases.  For reference, API instructions came from:
#  https://www.vagrantup.com/docs/vagrant-cloud/api.html
VAGRANT_URL="https://vagrantcloud.com/api/v1/box/$VAGRANT_CLOUD_USER/$BOX_NAME/version/$BOX_VERSION"

# Create aws provider for the new box version.
curl \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
  "$VAGRANT_URL/providers" \
  --data '{ "provider": { "name": "aws" } }'

# Get the upload path for the new aws-provided box.
UPLOAD_RESPONSE="$(curl --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" "$VAGRANT_URL/provider/aws/upload")"
UPLOAD_PATH="$(echo "$UPLOAD_RESPONSE" | jq -M -r -s '(if .[0].upload_path? then .[0].upload_path else "" end)')"

if [ -n "$UPLOAD_PATH" ]; then
    # Upload the box and finalize the release.
    curl \
        "$UPLOAD_PATH" \
        --request PUT \
        --upload-file "$BOX_DIR/aws.box"
    curl \
        --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
        "$VAGRANT_URL/release" \
        --request PUT

    # Clean up box directory.
    rm -fr "$BOX_DIR"

    # All done!
    exit 0
else
    # Something happened, keep temp files around.
    echo "No upload path retrieved, examine log and files in $BOX_DIR."
    exit 1
fi
