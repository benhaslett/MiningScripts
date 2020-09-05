# Mining Scripts
## How to create reslience of mining operations on a PC used for Gaming
* When you have one rig for Gaming and Mining.
* You may play games on the computer you use for mining.
* You may find it a hassle to remember to restart mining after you've finished gaming.
* Keeping a Mining Process Running may be a priority for you.
* This script tries to make both activities co-exist with minimal effort.
## What it does
There are a couple of JSON config files 
* MiningApps.json - Put the full paths to your miners here (full path to a .exe is all that's supported right now)
* MiningProofApps.json - Put the Process name of the thread you want to take priority over mining here

Keep these files in the folder with the script.
When the script runs it reads those files. If nothing in MiningProofApps is running it'll check if the things in MiningApps are running and start them if requried.
## TO DO
* Auto Generate MiningProofApps from what's in the steam library (or other game store)
* Write an Installer script that will setup the script to run from task scheduler
* Include some form of logging so the user has a chance to know what is going on  