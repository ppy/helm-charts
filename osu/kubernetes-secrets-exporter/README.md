# kubernetes-secrets-exporter

Micro-service to expose Kubernetes secrets to clients using client certificates over HTTPS

Application source code is available at: https://github.com/ppy/kubernetes-secrets-exporter

## Breaking Changes

### 2024.416.0

HTTPS support was introduced, and listening mode is mandatory to set via `server.listenMode`.  
The application no longer trusts proxies by default, this is configurable via `server.trustProxy`.

## Deployment

Make sure to deploy this in the namespace from which you want to expose secrets.  
If you cannot deploy this in the required namespace, or need to expose secrets from multiple namespaces, you'll need to copy or synchronize them.

This application must be properly firewalled, as anything it is exposed to may be able to access secrets. This is especially true if the application is set up in HTTP mode, as that would bypass the reverse proxy's client authentication.  
A NetworkPolicy is enabled by default in the Helm chart to isolate access to the ingress-nginx controller, but you will have to make sure they're supported in your environment.  

### Prerequisites

The back-end supports two listening modes:
- In HTTP mode, the back-end expects a reverse proxy in front of the application to handle HTTPS and client certificate authentication. The back-end trusts the reverse proxy to pass the client certificate subject's common name via the `ssl-client-subject-dn` header. The application must not be exposed to anything but the reverse proxy.  
  The Helm chart is pre-configured with appropriate annotations to enable client authentication for `ingress-nginx`. It also provides a NetworkPolicy to restrict access to the ingress controller.
- In HTTPS mode, the back-end handles the TLS termination and client certificate authentication directly.  
  The Helm chart is pre-configured with public TLS certificate provisioning through cert-manager.  
  A reverse proxy is optional in this mode, so this can be exposed in many ways (but a firewall is always recommended!).  
  If desired, the chart also supports `ingress-nginx` in this mode using SSL Passthrough. This feature must be enabled at the controller-level, see [TLS/HTTPS on the ingress-nginx documentation](https://kubernetes.github.io/ingress-nginx/user-guide/tls/#ssl-passthrough).

The application should be deployed in the namespace containing the secrets to be exposed.

### 1. Generate your Certificate Authority certificate & key files

This command will create an RSA 4096 bits certificate authority for our application:

```
openssl req -x509 -sha256 -newkey rsa:4096 -keyout ca.key -out ca.crt -days 3650 -nodes -subj '/CN=ppy-kubernetes-secrets-exporter'
```

Make sure to keep these files safe as the key cannot be recovered if lost. `ca.key` must stay private, otherwise anyone can sign arbitrary certificates to get your precious secrets.

### 2. Create overrides based on values.yaml

Example overrides for the following configuration:
- HTTP listening mode
- Ingress deployed via Helm as `ingress-nginx` in the `ingress-nginx` namespace, with URL `https://kubernetes-secrets-exporter.ppy.sh`
- TLS certificate provided with cert-manager by the `le-http01` ClusterIssuer, that will be placed into secret `ingress-tls`
- Exposing secret `ingress-tls` to any valid certificates with common name `testing-client.ppy.sh`

```yaml
secrets:
  ingress-tls:
    allowedSubjectNames:
      - testing-client.ppy.sh

certificates:
  ca.crt: |
    -----BEGIN CERTIFICATE-----
    <paste your ca.crt here>
    -----END CERTIFICATE-----

server:
  listenMode: http
  trustProxy: true

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: le-http01
  hosts:
    - host: kubernetes-secrets-exporter.ppy.sh
      paths:
        - path: /
  tls:
    - secretName: ingress-tls
      hosts:
        - kubernetes-secrets-exporter.ppy.sh

networkPolicy:
  ingressSelectors:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
      podSelector:
        matchLabels:
          app.kubernetes.io/instance: ingress-nginx
```

Similar configuration but using HTTPS listening mode and ingress-nginx using SSL pass-through:

```yaml
secrets:
  example-tls:
    allowedSubjectNames:
      - testing-client.ppy.sh

certificates:
  ca.crt: |
    -----BEGIN CERTIFICATE-----
    <paste your ca.crt here>
    -----END CERTIFICATE-----

server:
  listenMode: https
  trustProxy: true
  https:
    certificate:
      dnsNames:
        - kubernetes-secrets-exporter.ppy.sh
      issuerRef:
        group: cert-manager.io
        kind: ClusterIssuer
        name: le-http01

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: kubernetes-secrets-exporter.ppy.sh
      paths:
        - path: /

networkPolicy:
  ingressSelectors:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
      podSelector:
        matchLabels:
          app.kubernetes.io/instance: ingress-nginx
```

### 3. Add and update our Helm repository

```
helm repo add ppy https://ppy.github.io/helm-charts
helm repo update
```

### 4. Deploy the Helm chart

This command will deploy the `example` release inside the `kubernetes-secrets-exporter` namespace from the latest version of the `ppy/kubernetes-secrets-exporter` chart using overrides placed in `values.yaml`.

```
helm upgrade --install --create-namespace --namespace kubernetes-secrets-exporter example ppy/kubernetes-secrets-exporter -f values.yaml
```

This command can also be used for upgrading.

### 5. Issue a Client Certificate

For every machine you will want to fetch certificates from, you'll need to make client certificates. For experimenting, this can be your local machine.

We'll identify this first certificate by the following Common Name: `testing-client.ppy.sh`

First, from the target machine create a key (`client.key`) and a Certificate Signing Request (`client.csr`):
```
openssl req -new -newkey rsa:4096 -keyout client.key -out client.csr -nodes -subj '/CN=testing-client.ppy.sh'
```

Transfer `client.csr` to a machine that holds `ca.crt` and `ca.key` as generated in step 1, then sign the certificate:
```
openssl x509 -req -sha512 -days 3650 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 02 -out client.crt
```

Return the resulting `client.crt` to the client machine.

Repeat for as many client certificates needed.

### 6. Fetch a certificate

Once everything is deployed (watch for pods creation and certificate issuance), you should be able to get the certificate and key files for `https://kubernetes-secrets-exporter.ppy.sh` using:

```
curl --cert client.crt --key client.key https://kubernetes-secrets-exporter.ppy.sh/secrets/ingress-tls/download/tls.crt
curl --cert client.crt --key client.key https://kubernetes-secrets-exporter.ppy.sh/secrets/ingress-tls/download/tls.key
```

### 7. Bonus: Issue and expose SSL certificates to your clients

Create a cert-manager Certificate manifest. In this example, issuing a certificate for `demo-cert.ppy.sh` using the `le-http01` ClusterIssuer:

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: demo-cert
  namespace: kubernetes-secrets-exporter
spec:
  dnsNames:
  - demo-cert.ppy.sh
  issuerRef:
    group: cert-manager.io
    kind: ClusterIssuer
    name: le-http01
  secretName: demo-cert
  usages:
  - digital signature
  - key encipherment
EOF
```

Add the secret to our app configuration and expose it to `testing-client.ppy.sh`:

```yaml
secrets:
  ingress-tls:
    allowedSubjectNames:
      - testing-client.ppy.sh
  demo-cert:
    allowedSubjectNames:
      - testing-client.ppy.sh
```

Apply using the upgrade command in step 4.

Wait for the certificate to be issued, then try fetching using:

```
curl --cert client.crt --key client.key https://kubernetes-secrets-exporter.ppy.sh/secrets/demo-cert/download/tls.crt
curl --cert client.crt --key client.key https://kubernetes-secrets-exporter.ppy.sh/secrets/demo-cert/download/tls.key
```

This certificate will eventually be renewed automatically by `cert-manager`.

Now, let's make an external machine able to fetch this certificate.

First, make a client certificate as explained in step 5.  
On the target machine, place `client.crt` and `client.key` in `/var/local/lib/fetch-ssl`.

Then, we will use the following script to fetch the `demo-cert` certificate using `curl` and apply it to a running nginx instance. This was tested on a Debian 11 machine running nginx with certificate and key located at `/etc/ssl/tls.{crt,key}`.

Place as `/usr/local/bin/fetch-ssl.sh` and mark as executable:

```bash
#!/bin/sh
set -e

# Make sure our certificate and key are only accessible by root.
chown root:root -R /var/local/lib/fetch-ssl
chmod 600 /var/local/lib/fetch-ssl/*

curl \
  --cert /var/local/lib/fetch-ssl/client.crt \
  --key /var/local/lib/fetch-ssl/client.key \
  -f \
  -o /etc/ssl/tls.crt \
  https://kubernetes-secrets-exporter.ppy.sh/secrets/demo-cert/download/tls.crt

curl \
  --cert /var/local/lib/fetch-ssl/client.crt \
  --key /var/local/lib/fetch-ssl/client.key \
  -f \
  -o /etc/ssl/tls.key \
  https://kubernetes-secrets-exporter.ppy.sh/secrets/demo-cert/download/tls.key

chown root:root /etc/ssl/tls.key
chown 600 /etc/ssl/tls.key

nginx -t
systemctl reload nginx

echo "Reloaded nginx"
```

Execute it and make sure it works as expected.

Once confirmed, add a crontab entry to run this script every day:

```sh
echo "0 0 * * * root /usr/local/bin/fetch-ssl.sh" > /etc/crontab
```

Done!
