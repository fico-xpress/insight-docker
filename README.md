# Xpress Insight Server and Worker will cease to be deployed via Docker Compose from the 21st of December

The existing images on Docker Hub for Xpress Insight will be removed after this date, no new versions will be deployed with immediate effect.
Xpress Workbench will continue to be deployable via this method past this date.

# Introduction

This repository contains configuration files you can use to deploy FICO® Xpress Workbench as a Docker image,
enabling a seamless deployment across all platforms.

FICO Xpress Workbench is an IDE used for developing Mosel and Python optimization models prior to their being
published to FICO® Xpress Insight.

# Getting started

```
docker compose -f workbench.yaml up --build
```

Xpress Workbench is then available on `http://localhost:9595`. Change `WORKBENCH_EXTERNAL_PORT` in `.env` to
use a different port, and set `WORKBENCH_DATA_VOLUME` to a path on your host system if you would rather your
projects were stored outside the container.

To develop Python models in a Conda environment, use the Conda variant instead:

```
docker compose -f workbench-conda.yaml up --build
```

## Connecting to Xpress Insight

The Xpress Insight server you publish your models to is configured from within the Xpress Workbench user
interface, not in this repository. Workbench connects to an existing Insight server; it does not deploy one.

If that server presents a certificate that is not signed by a public authority, place the `.pem` file for its
certificate chain in `workbench-config` as described in `workbench-config/README.md`, so that Workbench
trusts it.

## Using an Xpress Solver license

See `xpress-license/README.md`.

# Documentation

For documentation on how to configure and deploy this image, see the
[Xpress Optimization Docker Deployment Guide.](https://www.fico.com/fico-xpress-optimization/docs/latest/dockerGuide)
You can find documentation on how to use Xpress Workbench at the same location.

# License

The Docker images include FICO® Xpress software, which is subject to
the [Xpress Shrinkwrap License Agreement](https://www.fico.com/en/shrinkwrap-license-agreement-fico-xpress-optimization-suite-on-premises).
By downloading this image, you agree to the Community License terms of the Xpress Shrinkwrap License Agreement with
respect to the included FICO Xpress software. See the
[licensing options overview ](https://community.fico.com/s/fico-xpress-optimization-licensing-optio)
for additional details and information about obtaining a paid license.

The images also contain other, separate, distinct software which may be subject to other licenses
(such as Bash and other components of the base distribution, along with any direct or indirect dependencies
of the primary software being contained). It is the image user's responsibility to ensure that any use of this image
complies with the relevant licenses for all software contained within.
