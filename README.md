You probably need to start here. 

These files should allow you to install an environment with all of the tools to support 
HipparchiaBuilder and HipparchiaServer.

The macOS version is semi-straightforward. It comes in two versions: 

[1] a walkthrough that guides you through the commands to send the terminal. 

[2] a somewhat more **dangerous** automated installation that may or may not do it all for you

If #2 does not work, you will have to try to walk through #1 but with the disadvantage
that a bunch of things will already be half-installed. 

This script has 'worked for me' status: clean installations of macOS 10.12.2 and 10.13.2 successfully loaded this.
So if you want to pick door #2, launch Terminal.app and paste the following into it:

```
curl https://raw.githubusercontent.com/e-gun/HipparchiaMacOS/master/automated_macOS_install.sh | /bin/bash
```

This will download, configure and install all of the starter files.

Please also realize the inherent folly of cutting and pasting commands into the terminal
as per the random dictates of some web page you stumbled across. Specifically this same
paradigm could be used to get you to delete the contents of your hard drive...

A more sensible thing to do would be to download the script, then read it, then run it. 


```
[download]
curl https://raw.githubusercontent.com/e-gun/HipparchiaMacOS/master/automated_macOS_install.sh

[read]
more automated_macOS_install.sh

[execute]
/bin/sh automated_macOS_install.sh
```