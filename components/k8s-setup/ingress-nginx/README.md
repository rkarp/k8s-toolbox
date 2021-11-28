# ingress-nginx

## Usage

### Helm chart installation

Prepare Helm repos:
```shell
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```

Deploy / upgrade Helm chart:
```shell
helm repo update

skaffold run

# or
skaffold run -p <profilename>
```
