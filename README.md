# SecureChain cloud infrastructure

Terraform definitions for the SecureChain AWS network, application services, and a site-to-site WireGuard gateway.

## Repository layout

- `environments/bootstrap` creates the encrypted, versioned S3 state bucket and DynamoDB lock table.
- `environments/dev` deploys the development VPC, network security, ECS/ECR resources, and VPN gateway.
- `environments/prod` is a placeholder; it is not ready to deploy.
- `modules/` contains reusable VPC, security, ECS, and VPN components.
- `.github/workflows/terraform.yml` checks formatting and validates the bootstrap and dev Terraform roots.

## Prerequisites

- Terraform 1.5 or newer.
- AWS credentials with permissions for the resources in the selected environment.
- AWS CLI configured for the same account and region.
- For the VPN, a fixed public IPv4 address for the remote peer, its WireGuard public key, and a Secrets Manager secret containing the gateway private key.

Never commit private keys, Terraform state, or populated `.tfvars` files.

## Bootstrap remote state

The bootstrap environment keeps its own state locally. Preserve and back up that state file after the first apply.

```sh
terraform -chdir=environments/bootstrap init
terraform -chdir=environments/bootstrap plan
terraform -chdir=environments/bootstrap apply
```

This creates the S3 bucket and DynamoDB table used by the dev backend. The dev configuration stores state in S3 with encryption and locking enabled.

## Configure the WireGuard secret

Generate a WireGuard key pair for the AWS gateway and keep the private key out of the repository and Terraform variables. Create a Secrets Manager secret whose JSON value has this shape:

```json
{"private_key":"<gateway-private-key>"}
```

Use the default AWS managed Secrets Manager key. The instance role is scoped to read only the secret ARN supplied to Terraform. If you use a customer managed KMS key, grant the instance role `kms:Decrypt` on that key as well.

Configure the remote peer with the gateway public key, the gateway's Terraform output public IP, and UDP port `51820`. The dev gateway listens only to the peer public IPv4 address supplied as a `/32` CIDR. The default peer tunnel address is `10.200.0.2/32`; change it if that range conflicts with either network.

The remote peer must route the AWS VPC CIDR through WireGuard. AWS-side route tables send the configured lab CIDR through the gateway. Ensure destination security groups permit only the required lab traffic.

## Plan the dev environment

Initialize the dev root after bootstrap has created its backend:

```sh
terraform -chdir=environments/dev init
terraform -chdir=environments/dev plan \
  -var='vpn_peer_public_ip_cidr=<peer-public-ip>/32' \
  -var='vpn_peer_public_key=<peer-wireguard-public-key>' \
  -var='vpn_private_key_secret_arn=<secrets-manager-secret-arn>'
```

The lab network defaults to `10.20.0.0/16`. Override it with `-var='vpn_allowed_lab_cidr=<lab-cidr>'` if needed. Do not apply until the plan has been reviewed and the remote peer and AWS security groups are configured.

## CI

GitHub Actions runs `terraform fmt -check -recursive` and initializes and validates the bootstrap and dev roots without accessing the remote backend or applying infrastructure. It does not run a plan or deploy AWS resources.
