# jitsi-meet

## Usage

### Helm chart installation

Prepare Helm repos:
```shell
helm repo add jitsi https://jitsi-contrib.github.io/jitsi-helm
```

Deploy / upgrade Helm chart:
```shell
helm repo update

skaffold run
```
