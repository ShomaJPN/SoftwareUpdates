# SoftwareUpdates (macOS)

## Overview
These Bash ShellScripts help to check UpdatePolicy and install SoftwareUpdate(MS Office and macOS).  
Display FinderDialog to prompt for changing policy / installing if necessary.  
If administrator privileges is required, it shows "Touch ID" dialog.  
Plese use with launchd / launchctl. (check Every xx hours while logged in)  
  
![touchid](https://user-images.githubusercontent.com/49780970/66632988-b891b980-ec44-11e9-938e-625929881f15.gif)
## Description
This was made to realize UserRemind and promote Education to users.
Suitable for the Organizations that encourage user behavior, may be ..  

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
Make or change launchd's command plist file, then put it to the appropriate directory. `(ex.~/Library/LaunchAgents)`  
At the first run, confirmation dialog (xxx would like to control "System Events"...) is appeared.  
Please allow it (in the case of Mojave )  
<img src="https://user-images.githubusercontent.com/49780970/66634259-a6654a80-ec47-11e9-8462-74a7aa2ff958.jpg" with="280">  
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
