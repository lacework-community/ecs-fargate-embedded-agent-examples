# Example repo for embedding Lacework agent into a secure base image


## Base image Dockerfiles
- [`Dockerfile-examplecorp-base-alpine`](Dockerfile-examplecorp-base-alpine)
- [`Dockerfile-examplecorp-base-scratch`](Dockerfile-examplecorp-base-scratch)
- [`Dockerfile-examplecorp-base-ubuntu`](Dockerfile-examplecorp-base-ubuntu)

Each of the above Dockerfiles do essentially the same thing:

1. They ensure the lacework agent exists at `/var/lib/lacework/datacollector`
1. They add an entrypoint script to the base container at `/examplecorp-entrypoint.sh`
1. They ensure the root ca certificates are in `/etc/ssl/certs/ca-certificates.crt`

## Base image entrypoint.sh
- [`examplecorp-entrypoint.sh`](examplecorp-entrypoint.sh)

The entrypoint script does the following functions:
1. Creates `/var/lib/lacework/config/config.json` and sets the lacework access token at runtime (provided as an environment variable).
1. Starts the Lacework agent and backgrounds it
1. `exec`s the next command provided by docker (the common last step of any entrypoint script)

Note: This script can be used for more than just Lacework, as it is intended to be used by all downstream containers built from your secure baseline image.  Some example modifications from other customers would include:

- Embedding the access token, or retrieving it from a secret store
- Conditionally running the agent only in AWS environments
- Adding other packages or running other agents


## Example downstream application container
- [`Dockerfile-examplecorp-nginx`](Dockerfile-examplecorp-nginx)

This is a simplified copy of the official Dockerfile from nginx https://github.com/nginxinc/docker-nginx

This example has two main differences from the public nginx Dockerfile:

1. It is built from a (fictional) secure baseline image which would have been built by one of the above example Dockerfiles.
1. The `ENTRYPOINT` has been prepended with our `examplecorp-entrypoint.sh` which starts the Lacework agent

## Requirements at Runtime

The [`examplecorp-entrypoint.sh`](examplecorp-entrypoint.sh) script is setup to accept the Lacework Access Token as an environment variable which can be set inside your task definitions with [environment variables](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/taskdef-envfiles.html) or [secrets](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data-secrets.html).

This is provided as an example, but other options would include modifying the entrypoint script to get these secrets at runtime from a source of your own choosing, or embedding your access token directly into the script.

Example of setting the access token inside a task definition as an environment variable:

```
{
  "containerDefinitions": [{
    "environment": [{
      "name": "environment_variable_name",
      "valueFrom": "arn:aws:secretsmanager:region:aws_account_id:secret:secret_name-AbCdEf"
    }]
  }]
}
```

## Directions To Test

To test if the base entrypoint (with Lacework agent) is excecuting, you can run these test commands.

```
cd examples/base-image
docker build . -f Dockerfile-examplecorp-base-alpine -t examplecorp-base-alpine
docker build . -f Dockerfile-examplecorp-nginx -t examplecorp-nginx
docker run -i examplecorp-nginx
```

You should see the following output if the base entrypoint is working:

```
Setting up Lacework Agent
Please set the LaceworkAccessToken environment variable
[container terminates]
```