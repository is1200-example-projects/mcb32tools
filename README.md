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
the `INSTALL_DIR` variable. The `INSTALL_DIR` variable declaration can be found at the top of the
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

## Building on Microsoft Windows
### Prerequisites
Builing and using the toolchain under Microsoft Windows requires a POSIX
compatibility layer. The recommended compatibility layer is MSYS2
(https://msys2.github.io/). Follow the guide to install MSYS on your
computer. The architecture (32 or 64 bits) must match the the target
architecture. (Building for 32 bit Windows requires 32 bit MSYS2.)

When MSYS2 is installed, launch it from the Start menu. It is important
that the shell started is the MSYS2-shell and not any of the two MINGW-shells.

Building the toolchain requires a few extra dependencies. These can be installed
by running the following command in the msys shell:
`pacman -S binutils gcc bison flex libtool texinfo diffutils make wget tar gzip bzip2 git`

### Downloading the source code
Download the toolchain source code and cd to its directory:
 - `git clone https://github.com/is1200-example-projects/pic32-toolchain.git`
 - `cd pic32-toolchain`

### Starting the build process
Determine the prefix to use for the toolchain. This path is hard-coded into
the binaries, and is the path used in the final toolchain distribution.
The default and recommended is to use `/opt/pic32-toolchain` . To change
this, edit the `INSTALL_DIR` variable at the top of the Makefile.

The prefix directory must be created manually before the build can start.
If your prefix is the default one, use the command `mkdir /opt/pic32-toolchain`

To start building the toolchain, issue the command `make` .
For faster building on a multi-core machine, the command `make -j8`
can be used. Substitute the number `8` with the number of worker threads,
recommended is 1.5 × the number of processor cores.
Note that the build process will automatically download some source code
packages from the internet, hence a working internet connection is required.

### If a build fails
If the build process is aborted while running, you may have the build tree in a bad
state. It is recommended that you run `make clean`, remove the `downloads` directory
and start over. If you know for certain that only a particular download failed,
delete only the failed directory in the downloads directory.

### Optional: Pre-download the source code
The source code can be downloaded prior to the building of the toolchain.
This allows for the toolchain to be built without a working internet connection.
To download the required source code, issue the command `make download` .
The source code can then be built as usual with `make` or `make -j8`

## Building on MacOS Ẍ́
Building the toolchain on MacOS X will create an application bundle with
a launcher that automatically sources the cross compiler environment.
### Prerequisites
You need to have Xcode installed to build the toolchain. Building the toolchain
has been tested on MacOS 10.10.2 and 10.10.3, however it should work on earlier
and future versions as well.

You will also need about 3 GB of available disk space.

### Starting the build process
First, you may configure the file name of the app by setting the `INSTALL_DIR`
variable at the top of the root makefile, the variable specific for Mac OS 
(as indicated by comments.) A default of `/Applications/pic32-toolchain.app` is used,
and it is recommended that it is not changed.

Before starting the building process, you need to create the install directory first.
Do this with `sudo mkdir -p <install path>` and  `sudo chown <your user> <install path>`.

To start building the toolchain, run `make -jN` where N is the number of threads to build
with, **without** space between the number and the `-j`. A number of threads 1.5 times
the amount of hardware cores in your system is a recommended value to compensate for
blocking I/O while not completely overloading your system. If in doubt, don't pass
the `-jN` parameter at all, or use a sane number (usually less than 10).

After you've started `make`, the source code archives will be downloaded
automatically and the build process starting. To avoid issues with the caching in finder,
avoid navigating the applications folder in Finder before the build is finished, or
it may get bad data about executable or icon cached on your machine. This will not
affect binary distribution, only your own local installation.

If make finished without any errors, you should now have a working toolchain in your
Applications folder. For making a release suitable for distribution, run
`make release` and a disk image with the app will be created in the root directory
of the repo.


## Currently implemented hacks
### libgmp
At the time this toolchain was pieced together, the latest version available
was 6.0.0a, it does however extract to 6.0.0. As a crude hack, an "a" is appended to the
URL in the list of URLs. If you wish to update the version of libgmp, you probably
need to remove this stray 'a'. You can find the list of URLs near the top of the
root makefile.
