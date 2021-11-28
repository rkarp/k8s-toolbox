# Docker Registry

## Usage

### Necessary config files

A `.htpasswd` file generated with `bcrypt` encryption is required under: `custom/secret/registry.htpasswd`

### Helm chart installation

Prepare Helm repos:
```shell
helm repo add twuni https://helm.twun.io
```

Deploy / upgrade Helm chart:
```shell
helm repo update

skaffold run
```
