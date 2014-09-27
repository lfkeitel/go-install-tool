#!/usr/bin/env bash
#
# Author: DragonRider23
# License: MIT
#
# Short bash script to install the latest version of Go
# A version can also be specified on the command line
# This script installs Go to the default location /usr/local/go
#
# Usage:
# To update to latest version: ./install_go.sh -u
# To install specific version: ./install_go.sh -r 1.3.1
# To update to specific version: ./install_go.sh -ur 1.3.1
# To uninstall: ./install_go.sh -x
# To use a different GOROOT: ./install_go.sh -p /path/to/go
#
# Flags:
#	-a Architecture type. Can be 32 or 64, anything else is discarded
#	   Architecture is assumed to be 64 bit if not specified or unknown
#
#	-u Update to current version
#
#	-r Release to install. E.g. 1.3.2
#
#	-p Path for Go binaries
#
#   -w Path for workspace
#
#	-x Uninstall Go
#
#   -b Rebuild system path variables (use the same flags for a normal install but add this)
#
#   -s Single user install (install to $HOME/.go instead of /usr/local)
#
#   -f Force reinstall of Go. Uninstalls any versions given same install paramenters
#      and installs from scratch

# Script variables
#
WGET=`which wget`
GOVER="1.3.2"
GOOS="linux"
GOARCH="amd64"
GOCODEDIR="${HOME}/go"
GODIR="/usr/local"
UPDATE=false
SINGLE=false
FORCE=false
REBUILD=false

# Script functions
#
usage() {
	echo "Usage: $0 [-u] [-b] [-s] [-f] [-x] [-a <string>] [-w <string>] [-r <string>] [-p <string>]" 1>&2
	echo ""
	exit 1
}

removePaths() {
    echo "---Deleting paths"
    sed -i '/# GoLang Paths/d' $HOME/.bashrc
    sed -i '/export GOROOT/d' $HOME/.bashrc
    sed -i '/export GOPATH/d' $HOME/.bashrc
    sed -i '/:$GOPATH/d' $HOME/.bashrc
    sed -i '/export GOBIN/d' $HOME/.bashrc
    sed -i '/export GOSRC/d' $HOME/.bashrc
}

uninstall() {
	echo "Removing Go"

    if [[ $GOROOT == "" ]]; then
        echo "ERROR: Can't remove Go, GOROOT not defined"
        exit 1
    fi

	echo "Deleting install directory"
	if [[ -d "$GOROOT" ]]; then
		sudo rm -r $GOROOT
	fi
    removePaths
	echo "Done"
}

# Parse arguments
#
while getopts ":ubsfxa:w:r:p:" o; do
    case "${o}" in
    	a) # Architecture
			if ${OPTARG} == "32"; then
				GOARCH="386"
			fi
			;;
        b) # Rebuild paths
            REBUILD=true
            ;;
        w) # Workspace dir
            GOCODEDIR=${OPTARG}
            ;;
        u) # Update to $GOVER
            UPDATE=true
            ;;
        r) # Set version to install
            GOVER=${OPTARG}
            ;;
        p) # Install dir
			GODIR=${OPTARG}
			;;
		x) # Uninstall
			uninstall
            exit 0
			;;
        s) # Single-user install
            GODIR="$HOME/.go"
            SINGLE=true
            ;;
        f) # Force reinstall
            FORCE=true
            ;;
        *) # Other
            usage
            ;;
    esac
done

# Full Go install path
#
GOROOTDIR="${GODIR}/go"

# Check if install directory exists
#
if [[ -d "${GODIR}" || -L "${GODIR}" ]] && ! $FORCE && ! $REBUILD && ! $UPDATE; then
    echo "ERROR: Go appears to already be installed, to force a reinstall use -f"
    exit 1
fi

# Forced install message
#
if $FORCE; then
    echo ""
    echo "## Performing forced reinstall ##"
    echo ""
fi

# Rebuild path message
#
if $REBUILD; then
    echo ""
    echo "## Performing path rebuild ##"
    echo ""
fi

# Download archive
#
echo "--Fetching go language archive--"
echo ""
# Delete any existing file with the same name
if [[ -f "go${GOVER}.${GOOS}-${GOARCH}.tar.gz" ]]; then
    rm go${GOVER}.${GOOS}-${GOARCH}.tar.gz
fi
if ! $REBUILD; then
    if ! $WGET "https://storage.googleapis.com/golang/go${GOVER}.${GOOS}-${GOARCH}.tar.gz"; then
    	echo "ERROR: Download failed. Exiting."
    	exit 1
    fi
fi

# If updating or force reinstalling Go, delete old version
#
if $UPDATE || $FORCE; then
	echo "--Removing old version of Go--"
    uninstall
fi

# Extract Go
#
if ! $REBUILD; then
    echo "--Extracting Go archive--"
    if [[ ! -d "${GODIR}" || ! -L "${GODIR}" ]]; then
        mkdir -p ${GODIR}
    fi

    if $SINGLE; then
        if ! tar -C ${GODIR} -xzf "go${GOVER}.${GOOS}-${GOARCH}.tar.gz"; then
            exit 1
        fi
    else
        if ! sudo tar -C ${GODIR} -xzf "go${GOVER}.${GOOS}-${GOARCH}.tar.gz"; then
        	exit 1
        fi
    fi
fi

# Create Go workspace
#
if [[ -d "${GOCODEDIR}" && ! -L "${GOCODEDIR}" ]]; then
    echo "--Go Workspace already made--"
else
    echo "--Making Go Workspace--"
    mkdir -p ${GOCODEDIR}/src; echo "---Created workspace src folder"
    mkdir -p ${GOCODEDIR}/bin; echo "---Created workspace bin folder"
    mkdir -p ${GOCODEDIR}/pkg; echo "---Created workspace pkg folder"
fi

# Add variables to bashrc
#
echo "--Writting Go variables--"
touch $HOME/.bashrc
if grep -q "# GoLang Paths" "${HOME}/.bashrc" && ! $REBUILD; then
	echo "---Go bin already added to PATH"
else
    removePaths
    echo "---Adding Paths"
	echo '# GoLang Paths' >> $HOME/.bashrc
	echo "export GOROOT=${GOROOTDIR}" >> $HOME/.bashrc
	echo "export GOPATH=${GOCODEDIR}" >> $HOME/.bashrc
	echo 'export PATH=$PATH:$GOPATH/bin:$GOROOT/bin' >> $HOME/.bashrc
	echo 'export GOBIN=$GOPATH/bin' >> $HOME/.bashrc
	echo 'export GOSRC=$GOPATH/src' >> $HOME/.bashrc
fi

# Cleanup
#
echo "--Cleaning up--"
source $HOME/.bashrc
if [[ -f "go${GOVER}.${GOOS}-${GOARCH}.tar.gz" ]]; then
    rm go${GOVER}.${GOOS}-${GOARCH}.tar.gz
fi
echo "---Successfully installed Go ${GOVER}"

# Thank you message
#
cat <<EOF

  Thank you for installing Go!

  Please run the following line to finish the installation
  (or open a new terminal):
     source $HOME/.bashrc

  You can see all the go command line options by
  running the following command:
     go help

  This script was created by DragonRider23.
  https://github.com/dragonrider23/go-install-tool

  Released under the MIT license.
  
EOF
