# Prometheus

## Usage

### Helm chart installation

Prepare Helm repos:
```shell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

Deploy / upgrade Helm chart:
```shell
helm repo update

skaffold run
```
