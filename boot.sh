#!/bin/bash
#
# Script to bootstrap the installation process of NGAMs
#
# ICRAR - International Centre for Radio Astronomy Research
# (c) UWA - The University of Western Australia, 2016
# Copyright by UWA (in the framework of the ICRAR)
# All rights reserved
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307  USA
#

# NGAMs is usually installed in a virtualenv environment, where all its (python)
# dependencies are also installed.
# The installation procedure is driven by the fabfile scripts.
# This bootstrap script creates a virtual environment for installing NGAS on it
# and installs the minimum dependencies on it to run the Fabric-based
# installation procedure

error() {
	echo "ERROR: $1" > /dev/stderr
	exit 1
}

if [[ -z "$1" ]]
then
	error "Usage: $0 <virtualenv-directory>"
fi
veDir="$1"

if [[ -d "$veDir" ]]
then
	error "$veDir already exists"
fi

# First things first, check that we have python installed
if [[ -z "$(which python 2> /dev/null)" ]]
then
	error "No Python found in this system, install Python 2.7"
fi

# Check that the python version is correct
pythonVersion=$(python -V 2>&1)
if [[ ! "$pythonVersion" == *"2.7"* ]]
then
	error "Python 2.7 needed, found: $pythonVersion"
fi

# Check if we already have virtualenv
# If not download one and untar it
veCommand="virtualenv"
sourceCommand="source $veDir/bin/activate"
if [[ -z "$(which virtualenv 2> /dev/null)" ]]
then
	VIRTUALENV_URL='https://pypi.python.org/packages/8b/2c/c0d3e47709d0458816167002e1aa3d64d03bdeb2a9d57c5bd18448fd24cd/virtualenv-15.0.3.tar.gz#md5=a5a061ad8a37d973d27eb197d05d99bf'
	if [[ ! -z "$(which wget 2> /dev/null)" ]]
	then
		wget "$VIRTUALENV_URL" | error "Failed to download virtualenv"
	elif [[ ! -z "$(which curl 2> /dev/null)" ]]
	then
		curl "$VIRTUALENV_URL" | error "Failed to download virtualenv"
	else
		error "Can't find a download tool (tried wget and curl), cannot download virtualenv"
	fi

	tar xf virtualenv-15.0.3.tar.gz  | error "Failed to untar virtualenv"
	veCommand="python virtualenv-15.0.3/virtualenv.py"
	removeVE="rm -rf virtualenv-15.0.3"
fi

# Create a virtual environment for the NGAMS installation procedure to begin
# and source it
$veCommand $veDir
$sourceCommand
if [[ ! -z "$removeVE" ]]
then
	$removeVE
fi

# Install Fabric and Boto
for pkg in boto Fabric
do
	pip install $pkg
done

echo
echo
echo    "----------------------------------------------------------------------------"
echo -e "Now run the following command on your shell to load the virtual environment:\n$sourceCommand"
echo