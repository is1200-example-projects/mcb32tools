# Pic32MX toolchain


## Building on Ubuntu 14.04
### Prerequisites
Apart from the base system install, a number of additional packages are required to
build the toolchain. Before you begin, run:
`sudo apt-get install build-essential bison flex libtool texinfo`
This should install all required packages.

You will also need about 3 GB of available disk space. The compiled toolchain
will use about 250 MB of space in the installation directory.

### Starting the build process
First, you need to configure the target installation directory of the toolchain.
Since GCC and many other programs hard-code their installation location, choose wisely,
as any binary distribution will need to be unpacked in the exact same path.
The path name `/opt/pic32-toolchain` is suggested. This path is configured using
the `PREFIX` variable. The `PREFIX` variable declaration can be found at the top of the
root makefile, located at the root of this repository.

Before you can start building the toolchain, you need to create this directory and make
sure it's writable. Do this with `sudo mkdir -p <install path>` and 
`sudo chown <your user> <install path>`.

When you've done that, cd into the toolchain repository and run `make`.
If you created the installation folder correctly, the source code will be downloaded and
the build process started. If you did not create the installation folder correctly, the
build process will fail quickly with a message containing instructions with suggested
commands to fix the problem.

It is recommended that you build with at least as many threads as your CPU supports in
hardware, but at most 50% more. Otherwise it may take a long time or your system may
become overloaded. If you have 4 hardware threads, run make with `make -j6`, this will
use 6 threads to compensate for I/O wait. If you build on an SSD or RAM disk, 
4 threads may be enough. Also note that there is no space between `-j`
and the number. Insering a space inbetween will build with **all**
the threads, which will bring down your system to the out of memory killer.

### If a build fails
If the build process is aborted while running, you may have the build tree in a bad
state. It is recommended that you run `make clean`, remove the `downloads` directory
and start over.

## Currently implemented hacks
### libgmp
At the time this toolchain was pieced together, the latest version available
was 6.0.0a, it does however extract to 6.0.0. As a crude hack, an "a" is appended to the
URL in the list of URLs. If you wish to update the version of libgmp, you probably
need to remove this stray 'a'. You can find the list of URLs near the top of the
root makefile.
