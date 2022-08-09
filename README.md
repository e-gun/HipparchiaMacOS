
## GENERIC INSTALLATION OVERVIEW

### project overview

1. Top of repository:

    * https://github.com/e-gun
    
    **mirror:**
    * https://gitlab.com/e-gun/

1. Description + Pictures of what you get/what `Hipparchia` can do: (scroll all the way down through the page…)

	https://github.com/e-gun/HipparchiaServer

---
### installation summary

1.  To get started, first pick your OS:

	* https://github.com/e-gun/HipparchiaMacOS
	* https://github.com/e-gun/HipparchiaWindows
	* https://github.com/e-gun/HipparchiaNIX

1. Then you do what your OS install instructions say: 

	e.g: open Terminal.app and paste
	
	`curl https://raw.githubusercontent.com/e-gun/HipparchiaMacOS/stable/automated_macOS_install.sh | /bin/bash`

    After watching a lot of messages fly by you will have the full framework. Its probably good news 
    if you see the following: `CONGRATULATIONS: You have installed the Hipparchia framework`

1. After you have installed the software framework, you need to load the data. 
    You either do what it says at

    **either**

	* https://github.com/e-gun/HipparchiaBuilder

    **or**

	* https://github.com/e-gun/HipparchiaSQLoader

    If you know somebody with a build, then you are interested in `HipparchiaSQLoader`.
    Your **reload** (via `reloadhipparchiaDBs.py`) the products of an 
    **extraction** (via `extracthipparchiaDBs.py`).  For example if A ran `extracthipparchiaDBs.py` and then put the `sqldump` folder on a thumb drive, 
    B could move that folder from the drive into his/her `HipparchiaData` folder and then run 
    `reloadhipparchiaDBs.py`. 

    Otherwise you need to build the databases yourself via `HipparchiaBuilder`.
    You put the data in the right place and then run `makecorpora.py`. 

1. Then you will have a working installation. Now it is time to use `HipparchiaServer`. You can `run.py` whenever you want. 
    Mac people even have a handy `launch_hipparchia.app` that can be clicked. 
    
    Once `HipparchiaServer` is running you launch a web browser and (by default) go to http://localhost:5000

    You can leave `HipparchiaServer` running forever, really: it only consumes an interesting 
    amount of computing resources when you execute queries. 
    
    The default settings should work well out of the box. Edit the files in `~/hipparchia_venv/HipparchiaServer/server/settings`
    if you want to change something. For example, `vectors` are off by default and someone who installs
    the proper `python` packages will want to edit `semanticvectorsettings.py` and set `SEMANTICVECTORSENABLED = 'yes'` 
    (and then check the list of vector search types to make sure everything desired has a `yes` next to it)

---

## MacOS SPECIFIC INSTALLATION INFORMATION

### first check that xcode is installed

`sudo xcode-select --install`

you will either be told that it is already there or be shown how to install it

--- 

### (maybe) install homebrew

`automated_macOS_install.sh` will attempt to install `homebrew` if it is not 
found. But sometimes the interactive bit of that installation can cause problems
with the rest of the script. So you can just do the installation of `homebrew` first to be safe:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

---

### then install the software framework

These files should allow you to install an environment with all of the tools to support 
HipparchiaBuilder and HipparchiaServer.

The macOS version is semi-straightforward.

This script is supposed to work on clean installations of macOS 10.12-14 
and macOS 11 (Big Sur). 
MacOS 10.10-11 can install Hipparchia, but things can be slow. 
The glitches with old systems have (maybe) been removed. 
Testing those system profiles is not a priority...

This will download, configure and install all of the starter files.

Please also realize the inherent folly of cutting and pasting commands into the terminal
as per the random dictates of some web page you stumbled across. Specifically this same
paradigm could be used to get you to delete the contents of your hard drive...

A sensible thing to do would be to download the script, then read it, then run it.

```
ARCH=$(uname -p)
[download]
curl https://raw.githubusercontent.com/e-gun/HipparchiaMacOS/stable/automated_macOS_install-${ARCH}.sh

[read]
more automated_macOS_install-${ARCH}.sh

[execute]
/bin/bash automated_macOS_install-${ARCH}.sh

```

But the brazen individual can just open Terminal.app and paste the following into it:

```
curl https://raw.githubusercontent.com/e-gun/HipparchiaMacOS/stable/$INSTALLER | /bin/bash
```

Note that that did not work. Instead you have to pause for a moment and name your architecture: (old) `i386` or (new) `arm`.

```
# set an ARCH; then you can past the 'curl...' stuff
ARCH=$(uname -p)
INSTALLER="automated_macOS_install-${ARCH}.sh"
curl https://raw.githubusercontent.com/e-gun/HipparchiaMacOS/stable/$INSTALLER | /bin/bash
```


The script takes arguments that set the style of installation (minimal, standard, devel) as well as the desire for vectors. 
'vectors' must be explicitly requested after a valid style: e.g., 'automated_macOS_install.sh standard vectors'

```
[bare minimum]
curl https://raw.githubusercontent.com/e-gun/HipparchiaMacOS/stable/$INSTALLER | /bin/bash -s minimal

[maximum: more fonts + vectors]
curl https://raw.githubusercontent.com/e-gun/HipparchiaMacOS/stable/$INSTALLER | /bin/bash -s standard vectors
```

---

### Troubleshooting

If the installation takes about one second to complete, then something went wrong. Scroll back and figure out what happened.
The most likely issue is a lack of developer tools and/or `homebrew` not installing right. Do that part
by hand (again(?)). Also delete the `hipparchia_venv` that was likely created. You do not want bogus passwords 
to be floating around in there. Then rerun the autoinstall script.
Keep checking the console output for errors. If it comes to it you can paste the commands one by one until you find
the one that dies. Then you can fix permssions, paths, or whatever so as to push on...