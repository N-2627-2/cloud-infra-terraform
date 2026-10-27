# SecureChain cloud infrastructure

Terraform definitions for the SecureChain AWS network, application services, and a site-to-site WireGuard gateway.

## Repository layout

- `environments/bootstrap` defines the S3 state bucket and DynamoDB lock table intended for a later remote-state/CI migration. It is separate from dev.
- `environments/dev` deploys the development VPC, network security, ECS/ECR resources, and VPN gateway. Dev currently uses Terraform's local state backend.
- `environments/prod` is a placeholder; it is not ready to deploy.
- `modules/` contains reusable VPC, security, ECS, and VPN components.
- `.github/workflows/terraform.yml` checks formatting and validates the bootstrap and dev Terraform roots.

## Prerequisites

- Terraform 1.5 or newer.
- AWS credentials with permissions for resources in the selected environment.
- AWS CLI configured for the target account and region.
- For VPN integration, the remote team must provide a fixed public IPv4 address and WireGuard public key. The gateway private key must be stored in AWS Secrets Manager.

Never commit private keys, Terraform state, or populated `.tfvars` files.

## Terraform state

The dev environment currently uses the default local backend. Its state is kept in the dev working directory and must be backed up securely; do not commit it. Local work does not require applying the bootstrap environment.

The bootstrap root defines the S3 bucket and DynamoDB lock table reserved for a future remote-state setup. Do not switch dev to that backend until the team agrees the remote-state and CI/CD cutover is ready. A backend migration must be planned explicitly so the existing local state is migrated without losing resource tracking.

## Configure the WireGuard secret

Generate a WireGuard key pair for the AWS gateway and keep the private key out of the repository and Terraform variables. Create a Secrets Manager secret whose JSON value has this shape:

```json
{"private_key":"<gateway-private-key>"}
```

Use the default AWS managed Secrets Manager key. The instance role is scoped to read only the secret ARN supplied to Terraform. If you use a customer managed KMS key, the instance role also needs `kms:Decrypt` on that key.

Configure the remote peer with the gateway public key, the gateway's Terraform output public IP, and UDP port `51820`. The dev gateway listens only to the peer public IPv4 address supplied as a `/32` CIDR. The default peer tunnel address is `10.200.0.2/32`; change it if that range conflicts with either network.

The remote peer must route the AWS VPC CIDR through WireGuard. AWS-side route tables send the configured lab CIDR through the gateway. Ensure destination security groups allow the required lab traffic.

## Plan the dev environment

Initialize dev locally and create a plan:

```sh
terraform -chdir=environments/dev init
terraform -chdir=environments/dev plan \
  -var='vpn_peer_public_ip_cidr=<peer-public-ip>/32' \
  -var='vpn_peer_public_key=<peer-wireguard-public-key>' \
  -var='vpn_private_key_secret_arn=<secrets-manager-secret-arn>'
```

The lab network defaults to `10.20.0.0/16`. Override it with `-var='vpn_allowed_lab_cidr=<lab-cidr>'` if needed. The peer address, peer key, and secret ARN are required to plan dev. Until the remote team supplies the peer details and both sides confirm routing and allowed traffic, the VPN integration is not ready to apply.

## CI

GitHub Actions runs `terraform fmt -check -recursive` and initializes and validates the bootstrap and dev roots with backend access disabled. It does not run a plan, authenticate to AWS, or deploy infrastructure. Remote state and AWS-authenticated CI are future integration work.
