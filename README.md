# Packer Templates

This repository generates Packer templates for building virtual machines.

## Requirements

In order to use this repository your system requires the following:

* [Packer](https://www.packer.io)
* [jq](https://stedolan.github.io/jq/)
* [VirtualBox](https://www.virtualbox.org/)

## `build.sh`

Using `jq` this script manipulates fragments of JSON into a complete template before feeding it to `packer`.
The following environment variables control what's built:

* `OS`: Corresponds to the operating system template in [`os`](./os), can be `centos` or `ubuntu`.
* `OS_RELEASE`: Corresponds to the operating system release used, e.g., `7.4` for [CentOS](./os/centos) or `trusty` for [Ubuntu](./os/ubuntu).
* `POST_PROCESSOR`: The [`post-processor`](./post-processor) to use:
  * `vagrant`: This is the default, creates a Vagrant box in the `output` directory.
  * `vagrant-cloud`: Creates a vagrant box and uploads it Vagrant Cloud.
  * `amazon-import`: Creates an OVA that is imported as an AMI using the AWS VM Import service.

Any additional command-line arguments are passed directly to `packer` which is useful for customization of [user variables](https://www.packer.io/docs/templates/user-variables.html).  For example:

```sh
OS=ubuntu ./build.sh \
  -var 'vm_name=trusty' \
  -var 'headless=true' \
  -var 'disk_size=81920' \
  -var-file ~/my-variables.json
```

## Examples

Examples are provided below of how this repository was used to generate their respective boxes on Vagrant Cloud.

### `hoot/centos7-minimal`

VirtualBox provided:

```sh
OS=centos OS_RELEASE=7.4 POST_PROCESSOR=vagrant-cloud ./build.sh \
  -var 'vm_name=centos7-minimal' \
  -var 'box_tag=hoot/centos7-minimal' \
  -var 'access_token=AAABBBCCC'
```

AWS-provided:

```
OS=centos OS_RELEASE=7.4 POST_PROCESSOR=amazon-import ./build.sh \
  -var 'vm_name=centos7-minimal' \
  -var 'ami_description=CentOS 7 Minimal' \
  -var 'region=us-east-1' \
  -var 's3_bucket_name=my-bucket' \
  -var 'access_key=AAAABBBBCCCC' \
  -var 'secret_key=secret'
```

### `hoot/trusty-minimal`

VirtualBox provided:

```sh
OS=ubuntu OS_RELEASE=trusty POST_PROCESSOR=vagrant-cloud ./build.sh \
  -var 'vm_name=trusty-minimal' \
  -var 'box_tag=hoot/trusty-minimal' \
  -var 'access_token=AAABBBCCC'
```

AWS provided:

```sh
OS=ubuntu OS_RELEASE=trusty POST_PROCESSOR=amazon-import ./build.sh \
  -var 'vm_name=trusty-minimal' \
  -var 'ami_description=Ubuntu 14.04 Minimal' \
  -var 'region=us-east-1' \
  -var 's3_bucket_name=my-bucket' \
  -var 'access_key=AAAABBBBCCCC' \
  -var 'secret_key=secret'
```
