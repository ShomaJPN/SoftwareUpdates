# SoftwareUpdates (macOS)

## Overview
These Bash ShellScripts check UpdatePolicies and install SoftwareUpdates (MS Office and macOS).  
Display FinderDialog to prompt for changing policy / installing.  
If administrator privileges is required, it shows "Touch ID" dialog.  
Plese use with launchd / launchctl. (check Every xx hours while logged in)  
  
![touchid](https://user-images.githubusercontent.com/49780970/66632988-b891b980-ec44-11e9-938e-625929881f15.gif)
## Description
These realize User-Remind to promote Education to users.
Suitable for the Organizations that encourage user behavior, may be ..  

## Requirements
- Finder-Login user who has administrator privileges

- Bash (for ShellScript)
  - osascript (for FinderDialog)
  - do shell script (for ShellScript /w Admin Priv.)

- Tested under Mojave 10.14.4 (Confrim Dialog/TCC appear at the first run)
- Tested under MS Office 365 /2019

## Usage
Excute these ShellScripts with launchctl / launchd.
- CheckAndChange_AppleSWUpdatePolicies.sh   <-- Check and change AppleSoftwareUpdate Policy script
- AppleSoftwareUpdate.sh                    <-- Update AppleSoftware script


- CheckAndChange_MSOfficeUpdatePolicies.sh  <-- Check and change MS-OfficeUpdate Policy script
- MSSoftwareUpdate.sh                       <-- Update MS-Office script


- com.myOrganization.cmd.plist              <-- Sample /launchd's command-plist


## Install and Run
Put these ShellScripts to the appropriate directory  `(ex.~/Script)`  , and set executable permissions.  
Make or change launchd's command-plist file, then put it to the appropriate directory. `(ex.~/Library/LaunchAgents)`  
At the first run, confirmation dialog (xxx would like to control "System Events"...) will be appeared.  
Please allow it (in the case of Mojave )  
![tcc](https://user-images.githubusercontent.com/49780970/66635253-c39b1880-ec49-11e9-8e81-5ab511f87946.jpg)  
If you did not allow by mistake, try `$ tccutil reset AppleEvents`  
Ref.[tccutil reset](https://www.youtube.com/watch?v=fyUB4L3ahZ4)


Start with the following command (only the first time)  
　```launchctl load /Path/to/plist```  
Stop is ...  
　```launchctl unload /Path/to/plist```  
Stop forever...  
　```Remove plist (ex. rm command)```  
Check is ...  
　```launchctl list```  

## Author
SHOMA Shimahara : <shoma@yk.rim.or.jp>
