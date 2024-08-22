FICO® Xpress Insight makes it easy to create, deploy, and utilize business optimization solutions with scalable 
high-performance algorithms, a flexible modeling environment, and rapid application development and reporting 
capabilities. Xpress Insight enables teams to work in a collaborative environment with interactive visualization and an 
interface designed for the business user, work with models in business terms, and understand trade-offs and 
sensitivities implicit in the business problem. They can share results with their peers and collaborate to make 
optimized decisions by running what-if scenario analysis and comparing the impact of different strategies.

# Licensing
This image includes FICO® Xpress software, which is subject to the [Xpress Shrinkwrap License Agreement](https://community.fico.com/s/contentdocument/06980000002h0i5AAA). By downloading 
this image, you agree to the Community License terms of the [Xpress Shrinkwrap License Agreement](https://community.fico.com/s/contentdocument/06980000002h0i5AAA) with respect to the 
included FICO Xpress software. See the [licensing options overview](https://community.fico.com/s/fico-xpress-optimization-licensing-optio) for additional details and information about 
obtaining a paid license.

As with most any Docker image, this download also contains other, separate, distinct software which may be subject to 
other licenses (such as Bash, etc. from the base distribution, along with any direct or indirect dependencies of the 
primary software being contained). It is the image user's responsibility to ensure that any use of this image complies 
with the relevant licenses for all software contained within.

# Security
The provided configuration files have a built-in mechanism to rebuild images with the latest available security updates. It is the 
image user's responsibility to regularly run this mechanism, and to download the latest updates from FICO when 
available. See the section [How to run a security update](#How-to-run-a-security-update) for more information.

# Online help documentation
The online help documentation for FICO® Xpress Insight can be found [here](https://www.fico.com/fico-xpress-optimization/docs/)

# Using Docker Compose
Docker Compose is a tool that makes it easy to run multi-container applications. Insight deploys both a server and 
worker container and optionally a database container. Using Docker Compose, this supplied .yaml configuration makes it 
easy to deploy and configure the Insight software stack.

You will need to have Docker installed, and it will need to be bundled with Docker Compose V2. Only very old Docker installations
would supply Compose V1, and it is [no longer supported](https://docs.docker.com/compose/intro/history/).

# Choosing a persistence type
We have made configurations available for deploying both an Insight server and worker, with file system persistence and 
with MySQL database persistence. The file system persistence configuration mounts a Docker volume, where the Insight server 
stores all its persisted data. The MySQL database persistence configuration starts a MySQL database in another container 
and persists the MySQL binary data in a Docker Volume. The Volumes will persist even if you upgrade to a new version of 
Insight.

It is not possible to automatically change between file system and database persistence types, but Insight does 
make it possible to export and import app data from within the application.

# How to deploy Insight
Download the configuration from this repository. Navigate to the directory with the desired persistence type, either 
`insight-local-filesystem` or `insight-local-mysql`. Docker should be running at this 
point. If you have not installed it as a service, then you may need to start Docker Desktop. You should only run one of 
the configurations, depending on what type of persistence you want to use.

## How to run
1. Open a terminal, navigate to the `insight-local-<PERSISTENCE>` directory, and run the command `docker compose up`
2. The interspersed logs from Insight Server and Insight Worker will be output to your terminal.
   They can be more easily viewed in Docker Desktop.
   (In _Containers_, find _server-1_ or _worker-1_, and click.)
3. Browse to http://localhost:8080 to use Insight.
   Log in as _admin_ with password _admin123_.
4. Ctrl+C in your terminal to shut down.

## How to change to a different port
By default, Insight is served at http://localhost:8080.
If another process is using that port on the host already, the server might fail to come up. You can change the value of 
SERVER_EXTERNAL_PORT in the `insight-local-<PERSISTENCE>/.env` file to something else (for example, `8081`) and restarting 
the software.

## How to change to a different Python debug port
By default, Insight's debug port is served at http://localhost:8090.
If another process is using that port on the host already, the server might fail to come up. You can change the value of
SERVER_EXTERNAL_PYTHON_DEBUG_PORT in the `insight-local-<PERSISTENCE>/.env` file to something else (for example, `8091`) and restarting
the software.

## How to override application properties
Simply add the property to the `override.properties` file, e.g
`spring.application.name=my-insight-server`

## How to enable file logging
The logs are output to the console only by default. This means they will be written in the terminal window that `docker compose up` 
was executed from. It is possible to change this behaviour and also log to files. To do this, you will need to edit a 
few files in the `insight-local-<PERSISTENCE>` folder that you are using:
1. Add the line `insight.server.system.log-appender=CONSOLE,FILE` to the `server-config/override.properties` file
2. Add the line `insight.worker.system.log-appender=CONSOLE,FILE` to the `worker-config/override.properties` file
3. Edit the `docker-compose.yaml` and uncomment the two lines `#- ./logs:/server/logs` and `#- ./logs:/worker/logs` by 
deleting the single `#` character in front of them

The [online help documentation](https://www.fico.com/fico-xpress-optimization/docs/) has more information on how to control 
the logging features.

## How to set the execution keystore password
The server to worker communication is authenticated with a private-public key pair that is generated on startup. The 
default password is stored in `insight-local-<PERSISTENCE>/execution_keystore_password.txt`. We recommend 
changing this password. Edit the file and set the desired password as a single word with no line breaks.

## How to run a security update
The first time you run `docker compose up`, a security update runs and new images are created
(such as `insight-local-filesystem-server`). Subsequently, these images will be reused.

FICO regularly releases updates to the software, but if you want to update the underlying OS on 
the images with security patches, you can re-run the security update.

To do that, first stop the system if it is running, either with Ctrl+C in the terminal or by running 
`docker compose down`. You must remove the old images and any containers using them.
You can do this automatically by setting the `build` and `force-recreate` flags and running the command  
`docker-compose up --build --force-recreate`. This runs a security update again using the YUM package 
manager and brings up the system. You can use the normal `docker compose up` from then on. No data will be 
lost, as it is stored on the volumes.

## How to skip running the first security update
The security update step is recommended, but on some systems various security programs may prevent a
Docker re-build of the image, since the process needs to reach out to the YUM repository to fetch the latest
security updates. If you are seeing an error message like this: 

```
Error: Failed to download metadata for repo 'amazonlinux': Cannot prepare internal mirrorlist: Curl error (60): 
SSL peer certificate or SSH remote key was not OK for https://cdn.amazonlinux.com/... [SSL certificate problem: unable 
to get local issuer certificate]
```

then try temporarily disabling Internet Security tools like Zscaler or your VPN.

It is possible to start up the server and worker without running the security updates. You need to 
update the `server.build` and `worker.build` sections in the `docker-compose.yaml` file and replace them with 
`image: ${IMAGE_SERVER}` and `image: ${IMAGE_WORKER}` respectively. This will pull the original image 
directly from Docker Hub and skip the local step that re-builds the images with security updates.

## How to license Xpress
To license Xpress on the worker, edit the `docker-compose.yaml` file and uncomment the line in the `worker.volumes` 
section that looks like this:

```
- ./license/xpauth.xpr:/opt/xpressmp/bin/xpauth.xpr
```

Create a directory called `license` in your `insight-local-<PERSISTENCE>` directory and put your license file 
`xpauth.xpr` there. Restart the containers with Ctrl+C and `docker compose up`.

## Insight with file system persistence
The data is stored in the `insight-local-filesystem_data` volume, which is created when the software starts up 
for the first time. It is possible to back up this volume using Docker, but this should only be done when Insight is 
shut down.

### How to wipe all file system data and start afresh
1. If Insight is still running, Ctrl+C in your terminal to shut down.
2. Run the terminal command `docker rm insight-local-filesystem-server-1` to delete the server pod.
3. Run the terminal command `docker volume rm insight-local-filesystem_data` to delete the file persistence data volume.
4. Bring the services back up again with `docker compose up`.

## Insight with MySQL persistence
The data is stored in the `insight-local-mysql_db_data` volume, which is created when the software starts up for the 
first time. It is possible to back up this data, but that is outside the scope of this readme. It is also possible to 
expose the MySQL database port out of the Docker Compose stack to gain remote access, but that is also outside the 
scope of this readme.

### How to set the database password
The database root password is set in the `insight-local-mysql/db_root_password.txt` file and the database 
password that Insight uses is set in the `insight-local-mysql/db_password.txt` file. We recommend 
changing these passwords. Edit each of the files and set the desired passwords as a single word with no line breaks.

### How to wipe all database data and start afresh
1. If Insight is still running, Ctrl+C in your terminal to shut down.
2. Run the terminal command `docker rm insight-local-mysql-db-1` to delete the database pod.
3. Run the terminal command `docker volume rm insight-local-mysql_db_data` to delete the database volume.
4. Bring the services back up again with `docker compose up`.

## Insight with Miniconda
An example of how to set up Insight with Miniconda is provided at `insight-local-conda-filesystem` and `insight-local-conda-mysql`.
This configuration runs Insight with either [filesystem persistence](#insight-with-file-system-persistence) or [mysql persistence](#insight-with-mysql-persistence)
and also install Miniconda. 

The `worker-conda.Dockerfile` downloads and installs Miniconda to `/opt/miniconda`. 
The provided `conda-entrypoint.sh` script installs or updates the provided `environment.yml` file each time 
the container is restarted. 

### Customizing the environment
You can find an example Conda environment configuration file at `insight-local-conda-<store type>/environments/environment.yml`. 
When you make changes to this file, remember to restart the `insight-local-conda-<store type>-worker-1` docker container.
After restarting, the container updates the miniconda environment to match your configuration.

> **_NOTE:_** If you change the name of the environment in this file, make sure to also change the environment variable `MINICONDA_ENV` within `docker-compose.yaml`.
