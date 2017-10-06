# Packer Templates

In order to use this repository your system requires the following command-line utilities:

* [Packer](https://www.packer.io)
* [jq](https://stedolan.github.io/jq/)
* [VirtualBox](https://www.virtualbox.org/)

## `hoot/centos7-minimal`

This is a minimalist CentOS 7 image (based off of 7.4) to be used as a common
substrate for [Hootenanny](https://github.com/ngageoint/hootenanny/).

This box can be built in three separate ways using the `hoot/centos7-minimal/build.sh` script:

* `vagrant` (the default): Creates a minimal CentOS 7 image for use with Vagrant, including the VirtualBox guest extensions.
* `vagrant-cloud`: Same as `vagrant`, except the resulting box is then uploaded to Vagrant Cloud.
* `amazon-import`: This build excludes the VirtualBox guest extensions and includes `cloud-init` so it can be used with AWS.

### Vagrant

```
./build.sh
```

This will produce a local Vagrant box (using VirtualBox) at `output/hoot/centos7-minimal_virtualbox.box`.

### Vagrant Cloud

```
POST_PROCESSOR=vagrant-cloud \
./hoot/centos7-minimal/build.sh \
  -var 'box_tag=hoot/centos7-minimal'
  -var 'access_token=AAABBBCCC'
```

### Amazon Import

```
POST_PROCESSOR=amazon-import \
./hoot/centos7-minimal/build.sh \
  -var 'access_key=AAAABBBBCCCC' \
  -var 'secret_key=secret' \
  -var 'region=us-east-1' \
  -var 's3_bucket_name=my-bucket'
```
