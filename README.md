You probably need to start here. 

These files should allow you to install an environment with all of the tools to support 
HipparchiaBuilder and HipparchiaServer.

The macOS version is semi-straightforward.

This script is verified to work on clean installations of macOS 10.12.X and 10.13.X.

This will download, configure and install all of the starter files.

Please also realize the inherent folly of cutting and pasting commands into the terminal
as per the random dictates of some web page you stumbled across. Specifically this same
paradigm could be used to get you to delete the contents of your hard drive...

A sensible thing to do would be to download the script, then read it, then run it.

```
[download]
curl https://raw.githubusercontent.com/e-gun/HipparchiaMacOS/master/automated_macOS_install.sh

[read]
more automated_macOS_install.sh

[execute]
/bin/sh automated_macOS_install.sh
```

But the brazen individual can just open Terminal.app and paste the following into it:

```
curl https://raw.githubusercontent.com/e-gun/HipparchiaMacOS/master/automated_macOS_install.sh | /bin/bash
```
