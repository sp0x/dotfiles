---
name: aws-ecs-exec
description: Open an interactive shell into a running AWS ECS container using the AWS Session Manager plugin. Use when asked to access, inspect, or debug a running ECS task or container.
---

## Prerequisites

Install the Session Manager Plugin if not already present:

```bash
# Ubuntu/Debian
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
```

Verify `ECS Exec` is enabled on the task definition and the ECS service (requires `enableExecuteCommand: true` and the `ssmmessages` IAM permissions on the task role).

## Opening a Shell

```bash
export c="<cluster-name>"
export t="<task-id>"
export container="<container-name>"

aws ecs execute-command \
  --cluster $c \
  --task $t \
  --container $container \
  --interactive \
  --command "/bin/sh"
```

## Finding the Task ID

```bash
# List running tasks in a cluster
aws ecs list-tasks --cluster <cluster-name>

# Describe a task to see container names and status
aws ecs describe-tasks --cluster <cluster-name> --tasks <task-id>
```

## Common Profiles

Use named AWS profiles for different environments:

```bash
export AWS_PROFILE=<profile-name>   # e.g. my-org-dev, my-org-prod
```

## Troubleshooting

- **"ExecuteCommandAgentNotRunningException"**: The `execute-command` agent is not running — the task must be started with `enableExecuteCommand: true`.
- **"TargetNotConnectedException"**: Session Manager connectivity issue; check that the task role has `ssmmessages:*` and `logs:*` permissions and the VPC has connectivity to SSM endpoints.
- **Command not found inside container**: Try `/bin/bash` instead of `/bin/sh`, or install the needed tool first via another deployment or init container.
