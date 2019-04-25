# SoftwareUpdates

## Overview
Check and Change the User's SoftwareUpdate policy,and update the SoftwareUpdate.  
Display FinderDialog for changing / installing during Finderlogin.  
It is written in Bash ShellScript and is used with launchd / launchctl.(ex. check Every xx hours while logged in)  

## Description
It was made to realize ReminderService that is not enough with push-service(MDM).  
Check the SoftwareUpdate policy at specific time while logging in.  
Display FinderDialog for changing / installing, do it.  
Suitable for organizations that do not force users.  

## Requirement
- Bash (for ShellScript)
  - osascript (for FinderDialog)
  - do shell script (for ShellScript /w osascript)
- Tested under Mojave

## Usage
Copy following ShellScripts to a specific user directory.
- CheckAndChange_AppleSWUpdatePolicies.sh   <-- AppleSoftware Policy check and change script
- AppleSoftwareUpdate.sh                    <-- AppleSoftware update script  

Set up launchctl / launchd.
- com.myOrganization.cmd.plist              <-- Sample /launchd-plist file.

## Install and Run
Put 2-ShellScripts to the appropriate directory  `(ex.~/Script)`  
Make/Change launchd-plist file according to your environment, then put it to the appropriate directory `(ex.~/Library/LaunchAgents)`  

Start with the following command (only the first time)  
　```launchctl load /Path/to/plist```  
Stop is ...  
　```launchctl unload /Path/to/plist```  
Stop forever...  
　```Remove plist from the appropriate directory  (ex.~/Library/LaunchAgents)```  
Check is ...  
　```launchctl list```  

## Author
SHOMA Shimahara : <shoma@yk.rim.or.jp>
