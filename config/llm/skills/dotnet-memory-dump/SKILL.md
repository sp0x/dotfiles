---
name: dotnet-memory-dump
description: Step-by-step workflow for collecting and analyzing .NET memory dumps from running AWS ECS containers. Use when asked to diagnose memory leaks, high memory usage, or GC pressure in a .NET application running on ECS.
---

## Collecting a Memory Dump from an ECS Container

### 1. Open a shell into the ECS container

Install `session-manager-plugin` if not present:

```bash
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
```

Open the shell:

```bash
export c="<cluster-name>"
export t="<task-id>"
aws ecs execute-command --cluster $c --task $t --container <container-name> --interactive --command "/bin/sh"
```

### 2. Collect the dump inside the container

```bash
dotnet-dump ps                   # find the .NET process PID
dotnet-dump collect -p <pid>     # produces a core_<pid> dump file
```

### 3. Copy the dump to S3

Install AWS CLI if not present in the container:

```bash
export arch=$(uname -m)
apt update && apt install unzip curl -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-$arch.zip" -o "awscliv2.zip"
unzip awscliv2.zip && ./aws/install && rm -rf aws awscliv2.zip
```

Upload:

```bash
aws s3 cp <dumpfile> s3://<your-dumps-bucket>/
```

### 4. Download and analyze locally

```bash
mkdir dumps
aws s3 cp s3://<your-dumps-bucket>/<dumpfile> ./dumps/

# If the container is arm64, use an emulator:
docker run --platform linux/arm64 --entrypoint bash \
  --rm -it -v $(pwd)/dumps:/dumps mcr.microsoft.com/dotnet/sdk:10.0

# Inside Docker:
dotnet tool install -g dotnet-dump
export PATH="$PATH:/root/.dotnet/tools"
dotnet-dump analyze /dumps/<dumpfile>
```

## Key Analysis Commands in `dotnet-dump analyze`

```text
# GC heap size and segment distribution (gen0/gen1/gen2/LOH/POH)
eeheap -gc

# Top object types by total size
dumpheap -stat

# Focus on common large allocations
dumpheap -type System.String -stat
dumpheap -type System.Byte[] -stat

# List large objects only (LOH candidates, >= 85 KB)
dumpheap -min 85000

# Inspect a specific object by address
dumpobj <address>

# Find what is keeping an object alive (GC root path)
gcroot <address>

# Inspect managed thread stacks
clrstack

# Check pending finalizers
finalizequeue
```

## Suggested Workflow

1. `eeheap -gc` + `dumpheap -stat` — identify whether growth is gen2/LOH and which types dominate.
2. `dumpheap -type <FullTypeName> -stat` on top offenders → `dumpobj <address>` on representative instances.
3. `gcroot <address>` on suspicious instances to find retention paths (static fields, caches, long-lived tasks, event handlers).
4. Repeat for the biggest offenders until a retention pattern is clear.
