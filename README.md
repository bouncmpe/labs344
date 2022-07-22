# Labs 344

This repository contains the development environment and instructions for CMPE344 lab sessions. 

## Containerized Lab Environment for CMPE344

Containers provides the ability to package and run applications in a loosely isolated environment. We use the container technology to package our development environment where all the necessary software and their dependencies has been installed. 

Docker was the first containerization platform and still is the most widely used software to manage containers. Check [Docker overview](https://docs.docker.com/get-started/overview/) to get more information about Docker and the containerization technology.

## Run the Lab Environment

### 1) Using Docker Engine

> :warning: You need [Docker Engine](https://docs.docker.com/engine/) installed on your system to proceed. For Ubuntu, you can install the engine by following [installation steps](https://docs.docker.com/engine/install/ubuntu/). It is also advised to follow [post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/) to run `docker` without `sudo`.

You can pull the container using the command:
```
docker pull ghcr.io/bouncmpe/labs344
```

Then you can run the container using the command:
```
docker run -it --rm ghcr.io/bouncmpe/labs344
```

### 2) Using VSCode and Remote Containers extension

The code editor VSCode has an extension to allow you develop inside containers called [Remote - Containers](https://code.visualstudio.com/docs/remote/containers). It allows you to open any folder inside (or mounted into) a container and take advantage of VSCode fully. This project provides you a `.devcontainer/devcontainer.json` file to configure the extension accordingly.

Once you have installed [Remote - Containers](https://code.visualstudio.com/docs/remote/containers) in the editor, you can open and work inside our lab environment using the extension.

