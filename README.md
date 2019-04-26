# SoftwareUpdates (macOS)

## Overview
This Bash ShellScript checks and changes the User's SoftwareUpdate policy, and install SoftwareUpdate.
Displays FinderDialog for changing / installing during Finder login ,using with launchd / launchctl. (ex. check Every xx hours while logged in)  

## Description
It was made to realize UserReminderService, promote Education to users that is not enough with push-service(MDM).  
Check SoftwareUpdate policy and new files during Finderlogin, show FinderDialog for changing / installing (then do it)  
Suitable for organizations that encourage users to act.  

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
Put ShellScripts to the appropriate directory  `(ex.~/Script)`  
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
