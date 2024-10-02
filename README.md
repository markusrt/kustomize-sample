# Sample on how to use kustomize

## Directory structure

Below is a sample directory structure. Base resources are directory `base` whereas environment specific
overlays are located in `overlays/env`, e.g., `overlays/dev`. The folder secrets showcases how to potentially
create secrets but keep in mind to **not store secret data** on your version control system.

```
|-- base
    ingress.yaml
    deployment.yaml
    kustomization.yaml
|-- overlays
    |-- prod
        ingress-patch.yaml
        kustomization.yaml
    |-- dev
        ingress-patch.yaml
        kustomization.yaml
|-- secrets
    .dockerconfigjson (do not put in version control)
    kustomization.yaml
    secrets.env (do not put in version control)
```

## Create secrets

This sample also applies secrets. The source for any credentials must not be stored in a repository hence
there is a small helper script to create the files used by the secret generator:

```
./createSecrets.sh -r my.docker.registry -u my-user -p my-password -d "Admin123"
```

This is just for demonstration. Depending on your clusters security needs you might want to take a look at
these [good practices for Kubernetes Secrets](https://kubernetes.io/docs/concepts/security/secrets-good-practices/).

## Apply a kustomization

In order to deploy the dev application to you cluster you just need to run

```
kubectl apply -k overlays/dev
```

As this particular example creates all resources it will recreate and reconfigure everything and restart the services.

E.g., when switching deploying another environment via:

```
kubectl apply -k overlays/staging
```

The application will be configured to run on a different host, use a lower container image version, and a different `COLOR` configuration:

```
% kubectl port-forward service/nginxhello -n myapp 8080:80

% kubectl get ingress nginxhello -n myapp
NAME         CLASS    HOSTS                            ADDRESS   PORTS   AGE
nginxhello   <none>   nginxhello-staging.example.com             80      20m

% curl -s localhost:8080 | grep "Version:"
<h2>Version: 1.19.0</h2>

% curl -s localhost:8080 | grep -o "alt=\".* container\""
alt="red container"
````


