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
#	-x Uninstall Go

# Script variables
#
WGET=`which wget`
GOVER="1.3.2"
GOOS="linux"
GOARCH="amd64"
GOCODEDIR="${HOME}/gocode"
GODIR="/usr/local"
UPDATE=false

# Script functions
#
usage() {
	echo "Usage: $0 [-u] [-x] [-a <string>] [-r <string>] [-p <string>]" 1>&2
	echo ""
	exit 1
}

uninstall() {
	echo "Removing Go"

	echo "Deleting install directory"
	if [[ -d "$GOROOT" ]]; then
		sudo rm -r $GOROOT
	fi

	echo "Deleting paths"
	sed -i '/# GoLang Paths/d' $HOME/.bashrc
	sed -i '/export GOROOT/d' $HOME/.bashrc
	sed -i '/export GOPATH/d' $HOME/.bashrc
	sed -i '/:$GOROOT/d' $HOME/.bashrc
	sed -i '/export GOBIN/d' $HOME/.bashrc
	sed -i '/export GOSRC/d' $HOME/.bashrc

	echo "Done"
	exit 0
}

# Parse arguments
#
while getopts ":a:uxr:p:" o; do
    case "${o}" in
    	a)
			if ${OPTARG} == "32"; then
				GOARCH="386"
			fi
			;;
        u)
            UPDATE=true
            ;;
        r)
            GOVER=${OPTARG}
            ;;
        p)
			GODIR=${OPTARG}
			;;
		x)
			uninstall
			;;
        *)
            usage
            ;;
    esac
done

# Download archive
#
echo "--Fetching go language archive--"
echo ""
if ! $WGET "https://storage.googleapis.com/golang/go${GOVER}.${GOOS}-${GOARCH}.tar.gz"; then
	echo "ERROR: Download failed. Exiting."
	exit 1
fi

# If updating Go, delete old version
#
if $UPDATE; then
	echo "--Removing old version of Go--"
	if [[ -d "$GOROOT" ]]; then
		sudo rm -r $GOROOT
	fi
fi

# Extract Go
#
echo "--Extracting Go archive--"
if [[ ! -d "${GODIR}" || ! -L "${GODIR}" ]]; then
    mkdir -p ${GODIR}
fi

if ! sudo tar -C ${GODIR} -xzf "go${GOVER}.${GOOS}-${GOARCH}.tar.gz"; then
	exit 1
fi

# Add gocode dir
#
if [[ -d "${GOCODEDIR}" && ! -L "${GOCODEDIR}" ]]; then
    echo "--GoCode folder already made--"
else
    echo "--Making GoCode folder--"
    mkdir -p ${GOCODEDIR}/src; echo "---Created go code src folder"
    mkdir -p ${GOCODEDIR}/bin; echo "---Created go code bin folder"
    mkdir -p ${GOCODEDIR}/pkg; echo "---Created go code pkg folder"
fi

# Add variables to bashrc
#
echo "--Writting Go variables--"
touch $HOME/.bashrc
if grep -q "# GoLang Paths" "${HOME}/.bashrc"; then
	echo "---Go bin already added to PATH"
else
	echo '# GoLang Paths' >> $HOME/.bashrc
	echo "export GOROOT=${GODIR}/go" >> $HOME/.bashrc
	echo "export GOPATH=${GOCODEDIR}" >> $HOME/.bashrc
	echo 'export PATH=$PATH:$GOPATH/bin:$GOROOT/bin' >> $HOME/.bashrc
	echo 'export GOBIN=$GOPATH/bin' >> $HOME/.bashrc
	echo 'export GOSRC=$GOPATH/src' >> $HOME/.bashrc
fi

# Cleanup
#
echo "--Cleaning up--"
source $HOME/.bashrc
rm go${GOVER}.${GOOS}-${GOARCH}.tar.gz
echo "---Successfully installed Go ${GOVER}"

cat <<EOF

  Thank you for installing Go!

  Please run the following line to finish the installation
  (or open a new terminal):
     source $HOME/.bashrc

  You can see all the go command line options by
  running the following command:
     go help
  
EOF