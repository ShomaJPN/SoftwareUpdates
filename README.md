# SoftwareUpdates (macOS)

## Overview
These Tiny Bash ShellScripts help to check SoftwareUpdate policies, and install SoftwareUpdate.  
During Finder login , display FinderDialog to prompt for changing policy / installing if necessary.  
If administrator privileges is required, it shows "Touch ID" dialog.  
Plese use with launchd / launchctl. (ex. check Every xx hours while logged in)  
![touchid](https://user-images.githubusercontent.com/49780970/57564890-c2419780-73ee-11e9-8085-e87d5961af8b.gif)
## Description
This was made to realize UserRemind and promote Education to users that is not enough with push-service(MDM).  
Suitable for organizations that encourage users to act, may be ..  

## Requirements
- Bash (for ShellScript)
  - osascript (for FinderDialog)
  - do shell script (for ShellScript /w osascript)

- Tested under Mojave 10.14.4 (Confrim Dialog/TCC appear at the first run)
- Tested under MS Office 365 /2019

## Usage
Excute these ShellScripts with launchctl / launchd.
- CheckAndChange_AppleSWUpdatePolicies.sh   <-- AppleSoftware Policy check and change script
- AppleSoftwareUpdate.sh                    <-- AppleSoftware update script


- CheckAndChange_MSOfficeUpdatePolicies.sh  <-- MS Office Policy check and change script
- MSSoftwareUpdate.sh                       <-- MS Office update script


- com.myOrganization.cmd.plist              <-- Sample /launchd's command plist file


## Install and Run
Put ShellScripts to the appropriate directory  `(ex.~/Script)`  , and set execute permissions.  
Make or change launchd's command plist file according to your environment , then put it to the appropriate directory. `(ex.~/Library/LaunchAgents)`  
At the first run, confirmation dialog (xxx would like to control "System Events"...) is appeared.  
Please allow it (in the case of Mojave )  
![TCC_fig](https://user-images.githubusercontent.com/49780970/57506250-3cfaac00-7336-11e9-9cc7-019c04ea0f3c.jpg)  
If you did not allow it by mistake, try `$ tccutil reset AppleEvents`  

Start with the following command (only the first time)  
　```launchctl load /Path/to/plist```  
Stop is ...  
　```launchctl unload /Path/to/plist```  
Stop forever...  
　```Remove plist from the appropriate directory  (ex. rm command)```  
Check is ...  
　```launchctl list```  

## Author
SHOMA Shimahara : <shoma@yk.rim.or.jp>
