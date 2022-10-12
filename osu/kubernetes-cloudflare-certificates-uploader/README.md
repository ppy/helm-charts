# kubernetes-cloudflare-certificates-uploader

Just a cronjob-ed script to refresh our custom edge certificate on Cloudflare.

Application source code is available at: https://github.com/ppy/kubernetes-cloudflare-certificates-uploader

## Deployment

Make sure to deploy this in the namespace containing the certificate you want to upload to CF.
The application itself supports fetching from a different namespace, but this Helm chart doesn't support setting-up the service account permissions for cross-namespace operations.

## Configuration

See in `values.yaml` for the application's configuration and cron expression. Deploy like any other Helm chart.
