#!/bin/bash
set -e
if [ -n "$INPUT_SOURCES" ]; then
    echo $INPUT_SOURCES >> /etc/apt/sources.list
fi
if [ -n "$INPUT_PPA" ]; then
    add-apt-repository "ppa:$INPUT_PPA" -y
fi

apt update && apt upgrade -y

# Set the install command to be used by mk-build-deps (use --yes for non-interactive)
install_tool="apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends --yes"
# Install build dependencies automatically
mk-build-deps --install --tool="${install_tool}" debian/control
# First build the source package
dpkg-buildpackage --build=source $INPUT_ARGS
# Then a normal build
dpkg-buildpackage $INPUT_ARGS
# Output the filename
cd ..
ls -l
mkdir -p /workspace/output/
# Move the built package into the Docker mounted workspace
mv -v *.{deb,dsc,changes,buildinfo,tar.*} /workspace/output/
