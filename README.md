# nix-s3-demo

A Demo on how to use
[arianvp/configure-aws-action](https://github.com/arianvp/configure-aws-action)
and Nix to pull from and push to an S3 binary cache using Github Action's ID
Token.


## Setup

Clone this repo and follow the instructions below to set up.

### Set up the signing key

Generate a new key pair and store the public key in Github secrets. These will
be used to sign and verify  nix store paths.
 
```shell
nix key generate-secret --key-name nix-s3-demo-1 > secret.key
nix key convert-secret-to-public < secret.key > public.key
gh secret set NIX_PUBLIC_KEY -a actions < public.key
gh secret set NIX_SECRET_KEY -a actions < secret.key
rm secret.key public.key
```

### Create S3 bucket and roles

Use opentofu to create the S3 bucket and roles and store the output in Github variables.

If you already have Github Actions federated with your AWS account you can use as is; otherwise
you will need add the following lines in  `main.tf`:

```hcl
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}
```

```shell
nix develop
tofu init
tofu apply
tofu output -raw cache_bucket_arn | gh variable set CACHE_BUCKET_ARN
tofu output -raw cache_bucket | gh variable set CACHE_BUCKET
tofu output -raw cache_bucket_region | gh variable set CACHE_BUCKET_REGION
tofu output -raw read_cache_role_arn | gh variable set READ_CACHE_ROLE_ARN
tofu output -raw write_cache_role_arn | gh variable set WRITE_CACHE_ROLE_ARN
```

### Push to your repo and done!

You should be good to go now.