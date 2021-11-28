# MetalLB

## Usage

### Helm chart installation

Prepare Helm repos:
```shell
helm repo add metallb https://metallb.github.io/metallb
```

Deploy / upgrade Helm chart:
```shell
helm repo update

kubectl use-context <previousy set up context>

skaffold run
```
