# Packer Templates

## CentOS 7

To build a CentOS 7 base box:

```sh
packer build centos7.json
```

If you want to customize any variables, e.g., the size of the virtual disk:

```sh
# Customizing disk size to 40GB
packer build -var 'disk_size=40960' centos7.json
```
