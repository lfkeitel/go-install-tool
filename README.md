Go Install Script for Linux
===========================

Bash script to automate Go language tools single user or system-wide installation (Linux).

Latest available version for download at the time of this writing was for Go version 1.3.2.

Requirements
------------

* Linux

Is it any good?
---------------

[Yes](https://news.ycombinator.com/item?id=3067434)

Usage
-----

```bash
./install_go.sh [-u] [-b] [-s] [-f] [-x] [-a [32|64]] [-w <string>] [-r <string>] [-p <string>]
```

Flags:
* -u Update to current version (as defined by script)
* -b Rebuild system path variables (use the same flags for a normal install but add this)
* -s Single user install (install to $HOME/.go instead of /usr/local)
     Effectively equal to '-p $HOME/.go'
* -f Force reinstall of Go. Uninstalls any versions given same install paramenters
     and installs from scratch. Use to switch from single-user to system-wide setup,
     or simply reinstall go.
* -x Uninstall Go
* -a Architecture type. Valid parameters are 32 or 64. If not 32, assumed to be 64.
* -r Release version to install. E.g. 1.3.2
* -p Path for Go install directory
* -w Path for Go workspace

Examples
--------

To install 64-bit (system-wide, default install and workspace directories, simpliest)

```bash
$ ./install_go.sh
```

To install 32-bit:

```bash
$ ./install_go.sh -a 32
```

To uninstall Go (created with this tool):

```bash
$ ./install_go.sh -x
```

Install for a single user:

```bash
$ ./install_go.sh -s
```

Update to latest version (as defined by the script):

```bash
$ ./install_go.sh -u
```

Install a specific version:

```bash
$ ./install_go.sh -r 1.3.1
```

Define custom Go install directory:

```bash
$ ./install_go.sh -p /path/to/go/dir
```

Define custom Go workspace directory:

```bash
$ ./install_go.sh -w /path/to/go/dir
```

Force system-wide reinstall:

```bash
$ ./install_go.sh -f
```

Force single-user reinstall:

```bash
$ ./install_go.sh -sf
```

Rebuild system Go path variables (default installation):

```bash
$ ./install_go.sh -b
```

Defaults
--------

Go install directory: /usr/local
Go workspace: $HOME/go

Read more about the workspace at http://golang.org/doc/code.html

Notes
-----

* If $GOROOT is not defined, this script cannot uninstall Go.

Release Notes
-------------

v1.0.0

- Initial Release

Versioning
----------

For transparency into the release cycle and in striving to maintain backward compatibility,
This application is maintained under the Semantic Versioning guidelines.
Sometimes we screw up, but we'll adhere to these rules whenever possible.

Releases will be numbered with the following format:

`<major>.<minor>.<patch>`

And constructed with the following guidelines:

- Breaking backward compatibility **bumps the major** while resetting minor and patch
- New additions without breaking backward compatibility **bumps the minor** while resetting the patch
- Bug fixes and misc changes **bumps only the patch**

For more information on SemVer, please visit <http://semver.org/>.