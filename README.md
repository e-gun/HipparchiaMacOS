You probably need to start here. 

These files should allow you to install an environment with all of the tools to support 
HipparchiaBuilder and HipparchiaServer.

The macOS version is semi-straightforward.

This script is verified to work on clean installations of macOS 10.12.X and 10.13.X. 
10.10.X and 10.11.X can install Hipparchia, but things can be slow. 
The glitches with old systems have (maybe) been removed. 
Testing those system profiles is not a priority...

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
/bin/bash automated_macOS_install.sh

```

But the brazen individual can just open Terminal.app and paste the following into it:

```
curl https://raw.githubusercontent.com/e-gun/HipparchiaMacOS/master/automated_macOS_install.sh | /bin/bash
```

The script takes arguments that set the style of installation (minimal, standard, devel) as well as the desire for vectors. 
'vectors' must be explicitly requested after a valid style: e.g., 'automated_macOS_install.sh standard vectors'

```
[bare minimum]
curl https://raw.githubusercontent.com/e-gun/HipparchiaMacOS/master/automated_macOS_minimal_install.sh | /bin/bash -s minimal

[maximum: devel + vectors]
curl https://raw.githubusercontent.com/e-gun/HipparchiaMacOS/master/automated_macOS_minimal_install.sh | /bin/bash -s standard vectors
```
