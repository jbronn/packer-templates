# Packer Templates

This repository generates Packer templates for building virtual machines.

## Requirements

In order to use this repository your system requires the following:

* [Packer](https://www.packer.io)
* [jq](https://stedolan.github.io/jq/) (minimum version of 1.5)
* [VirtualBox](https://www.virtualbox.org/)

## `build.sh`

Using `jq` this script manipulates fragments of JSON into a complete template before feeding it to `packer`.
The following environment variables control what's built:

* `OS`: Corresponds to the operating system template in [`os`](./os), can be `centos` or `ubuntu`.
* `OS_RELEASE`: Corresponds to the operating system release used, e.g., `7.5` for [CentOS](./os/centos) or `bionic` for [Ubuntu](./os/ubuntu).
* `POST_PROCESSOR`: The [`post-processor`](./post-processor) to use:
  * `vagrant`: This is the default, creates a Vagrant box in the `output` directory.
  * `vagrant-cloud`: Creates a vagrant box and uploads it Vagrant Cloud.
  * `amazon-import`: Creates an OVA that is imported as an AMI using the AWS VM Import service.
* `PROVISIONER`:  The [`provisioner`](./provisoner) installs additional software:
  * [`default`](./provisioner/default.json): The default provisioner does nothing.
  * [`hoot`](./provisioner/hoot.json): Prepares the host with packages necessary to install and test [Hootenanny](https://github.com/ngageoint/hootenanny/).

Any additional command-line arguments are passed directly to `packer` which is useful for customization of [user variables](https://www.packer.io/docs/templates/user-variables.html).  For example:

```sh
OS=ubuntu ./build.sh \
  -var 'vm_name=bionic' \
  -var 'headless=true' \
  -var 'disk_size=81920' \
  -var-file ~/my-variables.json
```

## `release.sh`

This script is a wrapper for `build.sh` that automatically sets up proper variables for the release versions of Hootenanny Vagrant Cloud boxes.  Examples are provided below of how this repository was used to generate the specific boxes.  All examples assume proper AWS and Vagrant Cloud credentials are in the environment:

```sh
export AWS_ACCESS_KEY_ID=AAAABBBBCCCC
export AWS_SECRET_ACCESS_KEY=secret
export AWS_SESSION_TOKEN=AAAABBBBCCCC
export VAGRANT_CLOUD_TOKEN=AAABBBCCC
```

AWS credentials must satisfy Amazon's [VM Import/Export Requirements](https://docs.aws.amazon.com/vm-import/latest/userguide/vmie_prereqs.html).

### `hoot/centos7-minimal`

```sh
./release.sh -n centos7-minimal -i my-bucket
```

### `hoot/trusty-minimal`

```sh
./release.sh -n trusty-minimal -i my-bucket
```
