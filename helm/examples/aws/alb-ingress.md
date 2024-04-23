
# Configuring AWS Load Balancer Controller (as ingress)

This document lists steps to configure the Spotfire CDK on an EKS cluster with an AWS load balancer ingress controller, along with Route 53 to access it from the internet.

## Prerequisites
- Administrator access to the Amazon account where the EKS cluster is deployed.
- Access to EKS cluster.
- Kubectl.
- Helm 3+.
- A domain in Route 53 (If you do not have one, then for more information, see [Registring a new domain](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-register.html).)
- A certificate for TLS configuration. For a new domain certificate, see [Request a public certificate using the console](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html).



## Configuration with AWS load balancer controller (as ingress)

- Install an AWS ALB ingress controller: Follow the steps listed at [AWS Load Balancer Controller installation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/deploy/installation/).

- As per [AWS Load balancer controller documentation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/how-it-works/#instance-mode), by default `Instance mode` ingress traffic is used by the AWS Load Balancer controller. (For example, the annotation `alb.ingress.kubernetes.io/target-type` in the ingress class is set to `NodeType`.) In this case, it requires the service to be exposed as type `NodePort`.<br />
To fulfill this requirement, deploy the `spotfire-server` chart with `haproxy.service.type=NodePort`.<br /><br />
<b>Note:</b> This setting is not needed when ingress traffic is set explicitly to `IP mode`, using the annotation `alb.ingress.kubernetes.io/target-type=IP` in the ingress resource.<br />

See the difference between these modes on the page AWS Load balancer controller [How it works](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/how-it-works/#instance-mode) and choose the configuration that best suits your use case.


### Option 1: Spotfire configuration with ingress traffic set to IP mode

&nbsp; &nbsp; <b>Note: </b>The page [EKS best practices guides](https://aws.github.io/aws-eks-best-practices/networking/loadbalancing/loadbalancing/#recommendations) recommends using this option.

1. Create an ingress values file using the following template. (Replace the variables in "<>" with appropriate values.)

&nbsp;&nbsp;&nbsp;&nbsp;ingress-values.yaml
```yaml
ingress:
  # -- Enables configuration of ingress to expose Spotfire Server. Requires ingress support in the Kubernetes cluster.
  enabled: true
  className: alb
  hosts:
    - host: "<Your domain name>"
      paths:
      - path: /
        pathType: Prefix
  # -- Annotations for the ingress object. For valid annotations, see the documentation for your ingress controller.
  # -- Ingress annotations page (https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/#annotations).
  annotations:
    # -- Group annotations are optional.
    alb.ingress.kubernetes.io/group.name: spotfire.web
    alb.ingress.kubernetes.io/group.order: "10"
    # --
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/load-balancer-name: "<Load balancer name>"
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
    alb.ingress.kubernetes.io/inbound-cidrs: 0.0.0.0/0
    alb.ingress.kubernetes.io/ip-address-type: ipv4
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/certificate-arn: "<AWS certificate ARN>"
    alb.ingress.kubernetes.io/ssl-redirect: "443"
    alb.ingress.kubernetes.io/success-codes: "200"
    external-dns.alpha.kubernetes.io/hostname: "<Your domain name>"

```

2. Install the Spotfire Server helm chart with this additional values file. For example:
```
helm install my-release .  -f ingress-values.yaml ...
```
For more information, see ["Installing" section of the Readme for the `spotfire-server` helm chart](./../../charts/spotfire-server/README.md#installing).



### Option 2: Spotfire configuration with ingress traffic set to instance mode

1. Create an ingress values file using the following template. (Replace the variables in "<>" with appropriate values.)

&nbsp; &nbsp; &nbsp; &nbsp; ingress-values.yaml
```yaml
haproxy:
  service:
    type: NodePort
ingress:
  # -- Enables configuration of ingress to expose Spotfire Server. Requires ingress support in the Kubernetes cluster.
  enabled: true
  className: alb
  hosts:
    - host: "<Your domain name>"
      paths:
      - path: /
        pathType: Prefix
  # -- Annotations for the ingress object. For valid annotations, see the documentation for your ingress controller.
  # -- Ingress annotations page (https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/#annotations).
  annotations:
    # -- Group annotations are optional.
    alb.ingress.kubernetes.io/group.name: spotfire.web
    alb.ingress.kubernetes.io/group.order: "10"
    # --
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
    alb.ingress.kubernetes.io/load-balancer-name: "<Load balancer name>"
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/ssl-redirect: "443"
    alb.ingress.kubernetes.io/success-codes: "200"
    external-dns.alpha.kubernetes.io/hostname: "<Your domain name>"
    alb.ingress.kubernetes.io/certificate-arn: "<AWS certificate ARN>"
```

2. Install the Spotfire Server helm chart with this additional values file. For example:
```
helm install my-release . -f ingress-values.yaml ...
```
For more information, see ["Installing" section in the Readme for the `spotfire-server` helm chart](./../../charts/spotfire-server/README.md#installing).

## Configuring Route 53

Add "A" record in the appropriate Route 53 hosted zone and point it to the load balancer. For more information, see [Creating records by using the Amazon Route 53 console](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-creating.html).