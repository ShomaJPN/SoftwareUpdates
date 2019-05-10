# SoftwareUpdates (macOS)

## Overview
This Tiny Bash ShellScript help to check & change User's SoftwareUpdate policies, and install SoftwareUpdate.
During Finder login time, Check and display FinderDialog to user for changing / installing.  
Even if administrator privileges is reauired, execute using Touch ID or FinderDialg.
Use with launchd / launchctl. (ex. check Every xx hours while logged in)  

## Description
This was made to realize UserRemind and promote Education to users that is not enough with push-service(MDM).  
Suitable for organizations that encourage users to act, may be ..  

## Requirements
- Bash (for ShellScript)
  - osascript (for FinderDialog)
  - do shell script (for ShellScript /w osascript)
- Tested under Mojave 10.14.4 (Confrim Dialog/TCC appear at the first run)

## Usage
Excute these ShellScripts with launchctl / launchd.
- CheckAndChange_AppleSWUpdatePolicies.sh   <-- AppleSoftware Policy check and change script
- AppleSoftwareUpdate.sh                    <-- AppleSoftware update script  

- CheckAndChange_MSOfficeUpdatePolicies.sh  <-- MS Office Policy check and change script
- MSSoftwareUpdate.sh                       <-- MS Office update script

- com.myOrganization.cmd.plist              <-- Sample /command plist file

## Install and Run
Put ShellScripts to the appropriate directory  `(ex.~/Script)`  , then set execute permissions.  
Make or change command plist file according to your environment , then put it to the appropriate directory. `(ex.~/Library/LaunchAgents)`  
A confirmation dialog (xxx would like to control "System Events"...) appear only once at the first run ,then allow it (in the case of Mojave )  
![TCC_fig](https://user-images.githubusercontent.com/49780970/57506250-3cfaac00-7336-11e9-9cc7-019c04ea0f3c.jpg)  
If you did not allow for confirmation by mistake, try `$ tccutil reset AppleEvents`  

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
