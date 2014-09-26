golang-tools-install-script
==========================

Bash script to automate Go language tools single user or system-wide
installation (Linux).

Latest filename for download at the time of this writting was for version 1.3.2 of Go.

To install 64-bit

```bash
$ ./install_go.sh
```

To install 32-bit:

```bash
$ ./install_go.sh -a 32
```

To remove any changes call:

```bash
$ ./install_go.sh -x
```

Usage
-----

```bash
./install_go.sh [-u] [-x] [-a <string>] [-r <string>] [-p <string>]
```

Flags:
* -a Architecture type. Can be 32 or 64, anything else is discarded.
   Architecture is assumed to be 64 bit if not specified or unknown
* -u Update to current version
* -r Release to install. E.g. 1.3.2
* -p Path for Go binaries
* -x Uninstall Go

The script will make /usr/local/go for the installation, $HOME/gocode for your
source files, add the needed variables and PATH expansion.

```
usr/local/go folder is where go will be installed.
```

```
$HOME/gocode is the default workspace.
```

Read more about the workspace at http://golang.org/doc/code.html