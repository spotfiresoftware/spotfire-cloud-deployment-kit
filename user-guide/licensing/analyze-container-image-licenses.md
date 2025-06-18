# Analyze container images and their associated licenses

This document describes how to analyze container images for software artifacts and associated licenses.

## Base container image

This project uses a [Debian](https://www.debian.org/) [official container]( https://hub.docker.com/_/debian?tab=description) image as the common base image layer for building images.

See the [license information](https://www.debian.org/legal/licenses/) for details on Debian licenses and software package types.
See also the Debian notes on the [Debian official images](https://wiki.debian.org/Docker).

As with all container images, the Debian container image can contain other software (such as `bash`, `glibc`, `zlib`, and others from the base distribution, along with any direct or indirect dependencies of the primary software included in the built image) that might be subjected to other licenses.

The following links provide auto-detected license information for the Debian official images:

- [debian](https://hub.docker.com/_/debian)
    - [local](https://github.com/docker-library/repo-info/blob/master/repos/debian/local/)
    - [remote](https://github.com/docker-library/repo-info/blob/master/repos/debian/remote/)

For example, you can find information about the artifacts of the [debian:bullseye-20220328-slim](https://github.com/docker-library/repo-info/blob/018ba0596bc427655726665ad8fb59c45fa4d9b3/repos/debian/local/bullseye-20220328-slim.md) official image.

**Note**: The image user has the responsibility to ensure that any use of the image complies with all relevant licenses for all software contained within.

## Additional software packages

Building images often installs additional software packages (fetched from the official distribution software repositories, from other user added repositories, or from specific locations), in addition to the packages already provided by the base image.
You can inspect the Dockerfiles to identify these additional packages.

For example, when you read the `spotfire-workerhost` Dockerfile, you see a list of packages that are installed in the image, as specified in the Dockerfile:

```
--8<-- "containers/images/spotfire-workerhost/Dockerfile"
```

Each such specified package can, in turn, install other software packages as dependencies.

**Note**: There are different ways to extract the list of installed packages and other installed artifacts.
Providing detailed instructions on software license analysis specialized tools is outside the scope of this document.
Retrieving information on software artifacts other than software packages installed with the package manager tools is also outside the scope of this document.
The following sections provide basic examples using standard container and package management tools.

### Manually retrieve installed packages information

You can use the command `dpkg-query` to retrieve the full list of installed packages in a container image.

**Example**: To retrieve the list of installed packages in the `debian:bullseye-20220328-slim` image:
```bash
$ docker run --rm debian:bullseye-20220328-slim dpkg-query -l
```
**Result**:
```
Unable to find image 'debian:bullseye-20220328-slim' locally
bullseye-20220328-slim: Pulling from library/debian
c229119241af: Pull complete
Digest: sha256:78fd65998de7a59a001d792fe2d3a6d2ea25b6f3f068e5c84881250373577414
Status: Downloaded newer image for debian:bullseye-20220328-slim
Desired=Unknown/Install/Remove/Purge/Hold
| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
||/ Name                    Version                      Architecture Description
+++-=======================-============================-============-========================================================================
ii  adduser                 3.118                        all          add and remove users and groups
ii  apt                     2.2.4                        amd64        commandline package manager
ii  base-files              11.1+deb11u3                 amd64        Debian base system miscellaneous files
ii  base-passwd             3.5.51                       amd64        Debian base system master password and group files
ii  bash                    5.1-2+b3                     amd64        GNU Bourne Again SHell
ii  bsdutils                1:2.36.1-8+deb11u1           amd64        basic utilities from 4.4BSD-Lite
ii  coreutils               8.32-4+b1                    amd64        GNU core utilities
ii  dash                    0.5.11+git20200708+dd9ef66-5 amd64        POSIX-compliant shell
ii  debconf                 1.5.77                       all          Debian configuration management system
ii  debian-archive-keyring  2021.1.1                     all          GnuPG archive keys of the Debian archive
...
```

### Manually retrieve installed packages licenses

You can use the command `dpkg` to retrieve the license for any installed package.

**Example**: To retrieve the license information for the installed package `apt`:
```bash
$ docker run --rm debian:bullseye-20220328-slim sh -c 'cat `dpkg -L apt | grep copyright`'
```
**Result**:
```
Apt is copyright 1997, 1998, 1999 Jason Gunthorpe and others.
Apt is currently developed by APT Development Team <deity@lists.debian.org>.

License: GPLv2+

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.

See /usr/share/common-licenses/GPL-2, or
<http://www.gnu.org/copyleft/gpl.txt> for the terms of the latest version
of the GNU General Public License.
```

### Manually retrieve installed packages sources

You can use the command `apt-get` to retrieve the source for any installed package.

**Example**: To retrieve the source for the installed package `apt`:
```bash
$ docker run --rm debian:bullseye-20220328-slim sh -c "find /etc/apt/sources.list* -type f -exec sed -i -e 'p; s/^deb /deb-src /' '{}' + && apt-get update -qq && apt-get source -qq --print-uris apt=2.2.4"
```
**Result**:
```
'http://deb.debian.org/debian/pool/main/a/apt/apt_2.2.4.dsc' apt_2.2.4.dsc 2780 SHA256:750079533300bc3a4f3e10a9c8dbffaa0781b92e3616a12d7e18ab1378ca4466
'http://deb.debian.org/debian/pool/main/a/apt/apt_2.2.4.tar.xz' apt_2.2.4.tar.xz 2197424 SHA256:6eecd04a4979bd2040b22a14571c15d342c4e1802b2023acb5aa19649b1f64ea
```

### Manually retrieve installed files

You can use the command `docker` to extract the contents of a container for further inspection.
Here we show 2 common methods to extract the image contents without running the container.

#### Method 1: Using a temporal container image to extract the files

Create a temporal container image based on the image you want to inspect, and export its whole filesystem (or parts of it).

**Example**:

1. Create a temporal container image called `temp-container`, based on the `unknown-image:latest` image:
    ```bash
    docker create --name temp-container unknown-image:latest
    ```

2. Extract the whole container image filesystem as a TAR file:
   ```bash
    docker export temp-container > temp-container.tar
    ```

    Or, if you want to list only the included files:
    ```bash
    docker export temp-container | tar t > temp-container-files.txt
    ```

This method is a direct way to extract the image's final filesystem.
It provides a **composite view of a container instance's filesystem**.

**Note**: This is the fastest way to list the included files or extract individual files.

#### Method 2: Extract the container image layers as a set of layers

Create a TAR file with all the individual image layers that compose the final container image.

**Example**:

- Use the command `docker image save` to create a TAR file containing all the container image layers:
    ```bash
    docker image save unknown-image:latest > temp-image.tar
    ```

The TAR file includes a `manifest.json` file, which describes the image's layers and a set of separate directories containing the content of each of the individual layers.

This method produces an archive that exposes the container image format, not the container instances created from it.
It provides a **layered view of the container image**.

**Note**: This is useful when you want to evaluate each layer's role in building the image.

#### Layered view vs composite view

The following diagram illustrates the differences between the layered view and the composite view of a container image.

![](container-image-views.png)

References:
- For more information on the docker command arguments, see the [Docker CLI](https://docs.docker.com/engine/reference/commandline/docker/) documentation.
- For more information on the container image format, see the [OCI image format specification](https://github.com/opencontainers/image-spec/blob/main/spec.md).
