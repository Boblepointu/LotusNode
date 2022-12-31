# LotusNode

## Abstract

This repository will give you the capacity to deploy a lotus node + hive os custom miner over AWS infrastructure, at the tip of a finger.
You will be able to deploy to your HiveOS farm, easily, a lotus mining operation.

## Requirements

- An AWS account, with programmtic access enabled (AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY)
- A domain name zone registered to Route53 in AWS (access to the node RPC and hive os custom miner download)
- A S3 bucket created manually (terraform state files)

## Operating the node

1. Fork this repository to your github account
2. Go to the forked repo in your account
3. Set up two secrets in the settings of the repo, AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY, with your keys from AWS
4. Change `dns_zone_name` and `lb_dns_record_lotus` in `/.deployment/variables.tfvars` to your liking. `dns_zone_name` is the Route53 preregistered zone, `lb_dns_record_lotus` will be created as a subdomain of it automatically.
5. Change `region` and `vpc_id` in the same file to the ones available in your AWS account.
6. Set the bucket name to the right one in `/.deployment/variables.tf`. Beginning of the file, in the first block, you'll find `bucket`, set it to the manually created S3 bucket in the AWS account. You'll also find `region`. Set it to the right AWS acc region to match other configurations.
7. Set the AWS region name once again in the CI file at `/.github/workflows/build-push-deploy-prod.yml` line 12.
8. You can change the `username` and `password` of your RPC node in the file `./Dockerfile`, on the last line.
9. Commit, Push. Check `Action` tab on your repo in your github account. Deployment will take 5 to 15 min on a fresh install.

## Deploying the custom miner to HiveOs farm

1. Be sure to have deployed the node in the last step.
2. Login to your HiveOs web account.
3. Create a new `wallet`. The parameters won't be used, but it is required later. Fill randomly.
4. Create a new `flight sheet`. 
   1. Select a random coin in the list.
   2. Select your placeholder `wallet` created the step before.
   3. Select, in `pool` the option `Configure in miner`.
   4. Select in `miner` the option `Custom`. `Setup Miner Config` should appear right over it when selected. Click it. See following screenshot for example :
   5. ![hiveoscustomconfigexample](.readmeImages/customMinerConfig.png?raw=true "HiveOs custom miner config") (See bottom for copy paste values)
   6. Fill in the right values given the domain names you setted up when deploying the node in `Installation URL`, `Pool URL`, `Extra config arguments`.
   7. Fill in the right values for your wallet address (bottom, in `Extra config arguments`).
   8. Validate, give it a name, use it on your miners.


### Copy paste

```
Miner name : lotus-miner
Installation URL : https://lotus-pool.frenchbtc.fr/lotus-miner-0.0.3.tar.gz
Wallet and worker template : %WAL%.%WORKER_NAME%
Pool URL : https://lotus-pool.frenchbtc.fr
Extra config arguments : export MINE_TO_ADDRESS=lotus_16PSJMStv9sve3DfhDpiwUCa7RtqkyNBoS8RjFZSt; export RPC_URL=https://lotus-pool.frenchbtc.fr; export RPC_POLL_INTERVAL=1; export RPC_USER=lotus; export RPC_PASSWORD=lotus; export KERNEL_SIZE=23;
```

All set ! Have fun.
