# K8s Toolbox

This toolbox allows you to install various components on a K8s cluster.

## Design

* The main goal is to make it easy to install K8s essentials needed to be able to subsequently deploy your own applications
  with full HTTPS support.
* The content of this repo can be used as an initial template for your K8s infrastructure setup code.
* Component configuration can be customized using `values.custom.yaml` when using the `custom` Skaffold profile.

## K8s setup components

The components under [`components/k8s-setup`](components/k8s-setup) cover some basic requirements
for deploying applications on K8s:

* [ingress-nginx](https://kubernetes.github.io/ingress-nginx/): Commonly used ingress controller for K8s.
* [cert-manager](https://cert-manager.io/): As set up here, allows automatically generating
  and renewing certificates for deployed ingresses with Let's Encrypt.
* [MetalLB](https://metallb.universe.tf): Allows creating services of type `LoadBalancer` so you can accept traffic
  to external IPs at any desired port. See also: <https://www.reddit.com/r/kubernetes/comments/qyhv16/help_me_understand_kubernetes_external_networking/>
* [Docker Registry](https://artifacthub.io/packages/helm/twuni/docker-registry): A K8s-internal registry so images don't have to be stored
  outside the cluster.
* [Prometheus](https://artifacthub.io/packages/helm/prometheus-community/prometheus): Collects metrics for nodes and services.

## Usage

### Prerequisites

* [Helm](https://helm.sh/docs/intro/install)
* [Skaffold](https://skaffold.dev/docs/install) 

**Note**: In order to deploy with Skaffold, make sure [`KUBECONFIG`](https://skaffold.dev/docs/environment/kube-context/) is set properly.

### Tips

#### Docker pull limit error

If you get `TOOMANYREQUESTS: You have reached your pull rate limit` you can use this instead of `skaffold dev`:
```shell
skaffold run --cache-artifacts=false --tail
skaffold delete
```

This will avoid the [Skaffold-specific cache checks](https://github.com/GoogleContainerTools/skaffold/issues/4978#issuecomment-726988034)
which may pull from Docker Hub.

## Useful links

* [Ingress Options for Bare Metal Kubernetes](https://www.thebookofjoel.com/bare-metal-kubernetes-ingress)

## License

Licensed under either of

 * Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any
additional terms or conditions.
