#!/usr/bin/env bash
#
# Author: Lee Keitel
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

## BEGIN VARIABLE DECLARATIONS ##
WGET=`which wget`
GOVER="1.8.3"
GOOS="linux"
GOARCH="amd64"
GOCODEDIR="${HOME}/go"
GODIR="/usr/local"
SINGLE=false
FORCE=false
REBUILD=false
CUSPATH=false
## END VARIABLE DECLARATIONS ##

## BEGIN FUNCTION DECLARATIONS ##
usage() {
	echo "Usage: $0 [-u] [-b] [-s] [-f] [-x] [-a <string>] [-w <string>] [-r <string>] [-p <string>]" 1>&2
	echo
	exit 1
}

uninstall() {
	echo "Removing Go"

    if [[ $GOROOT == "" ]]; then
        echo "ERROR: Can't remove Go, GOROOT not defined"
        exit 1
    fi

	echo "Deleting install directory"
	if [[ -d "$GOROOT" ]]; then
		sudo rm -R $GOROOT
	fi
    removePaths
	echo "Done"
}

downloadGo() {
    echo "--Fetching Go language archive--"
    echo
    cleanUp
    if ! $REBUILD; then
        if ! $WGET "https://storage.googleapis.com/golang/go${GOVER}.${GOOS}-${GOARCH}.tar.gz"; then
            echo "ERROR: Download failed. Exiting."
            echo
            exit 1
        fi
    fi
}

extractGo() {
    echo "--Extracting Go archive--"

    # Create Go install dir
    if [[ ! -d "${GOROOTDIR}" || ! -L "${GOROOTDIR}" ]]; then
        if ! mkdir -p ${GOROOTDIR} 2>/dev/null; then
            sudo mkdir -p ${GOROOTDIR}
        fi
    fi

    # Extract
    if ! tar -xzf "go${GOVER}.${GOOS}-${GOARCH}.tar.gz"; then
        exit 1
    fi

    # Move
    if ! mv go/* $GOROOTDIR 2>/dev/null; then
        sudo mv go/* $GOROOTDIR
    fi
}

createWorkspace() {
    if [[ -d "${GOCODEDIR}" && ! -L "${GOCODEDIR}" ]]; then
        echo "--Go Workspace already made--"
    else
        echo "--Making Go Workspace--"
        mkdir -p ${GOCODEDIR}/src; echo "---Created workspace src folder"
        mkdir -p ${GOCODEDIR}/bin; echo "---Created workspace bin folder"
        mkdir -p ${GOCODEDIR}/pkg; echo "---Created workspace pkg folder"
    fi
}

removePaths() {
    echo "---Deleting paths"
    sed -i '/# GoLang Paths/d' $HOME/.bashrc
    sed -i '/export GOROOT/d' $HOME/.bashrc
    sed -i '/export GOPATH/d' $HOME/.bashrc
    sed -i '/export GOBIN/d' $HOME/.bashrc
    sed -i '/export GOSRC/d' $HOME/.bashrc
    sed -i '/:$GOROOT/d' $HOME/.bashrc
}

createPaths() {
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
        echo 'export GOBIN=$GOPATH/bin' >> $HOME/.bashrc
        echo 'export GOSRC=$GOPATH/src' >> $HOME/.bashrc
        echo 'export PATH=$PATH:$GOBIN:$GOROOT/bin' >> $HOME/.bashrc
    fi
}

cleanUp() {
    if [[ -f "go${GOVER}.${GOOS}-${GOARCH}.tar.gz" ]]; then
        rm go${GOVER}.${GOOS}-${GOARCH}.tar.gz
    fi

    if [[ -d "go" ]]; then
        rm -r go
    fi
}
## END FUNCTION DECLARATIONS ##

## BEGIN MAIN SCRIPT ##
# Parse arguments
#
while getopts ":ubsfxa:w:r:p:" o; do
    case "${o}" in
        a) # Architecture
            if [ ${OPTARG} == "32" ]; then
                GOARCH="386"
            fi
            ;;
        b) # Rebuild paths
            REBUILD=true
            echo
            echo "## Performing path rebuild ##"
            ;;
        w) # Workspace dir
            GOCODEDIR=${OPTARG}
            ;;
        u) # Update to $GOVER
            FORCE=true
            GODIR=$GOROOT       # Get current Go install directory
            GOCODEDIR=$GOPATH   # Get current workspace directory
            echo
            echo "## Performing update ##"
            ;;
        r) # Set version to install
            GOVER=${OPTARG}
            ;;
        p) # Install dir
            GODIR=${OPTARG}
            CUSPATH=true
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
            GODIR=$GOROOT       # Get current Go install directory
            GOCODEDIR=$GOPATH   # Get current workspace directory
            echo
            echo "## Performing forced reinstall ##"
            ;;
        *) # Other
            usage
            ;;
    esac
done

# Full Go install path
#
if ! $FORCE && ! $SINGLE && ! $CUSPATH; then
    GOROOTDIR="${GODIR}/go"
else
    GOROOTDIR=$GODIR
fi

echo
echo "\$GOROOT will be ${GOROOTDIR}"
echo "\$GOPATH will be ${GOCODEDIR}"
echo
read -p "Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then # This form is safer

    # Check if Go is possibly already installed
    #
    if [[ -d "${GOROOTDIR}" || -L "${GOROOTDIR}" ]] || [[ -d $GOROOT ]] && ! $FORCE && ! $REBUILD; then
        echo "ERROR: Go appears to already be installed."
        echo "To force a reinstall use -f as the first argument"
        echo
        exit 1
    fi

    # Download archive
    #
    downloadGo

    # If updating or force reinstalling Go, delete old version
    #
    if $FORCE; then
    	echo "--Removing old version of Go--"
        uninstall
    fi

    # Extract Go
    #
    if ! $REBUILD; then
        extractGo
    fi

    # Create Go workspace
    #
    createWorkspace


    # Add variables to bashrc
    #
    createPaths

    # Cleanup
    #
    echo "--Cleaning up--"
    source $HOME/.bashrc # If the user invokes with . ./ notation, source it for them. They deserve it.
    cleanUp
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

EOF
else # Else from original question
    echo
    exit 0
fi
## END MAIN SCRIPT ##
