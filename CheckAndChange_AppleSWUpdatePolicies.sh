#!/bin/bash
##
## Name: 
##  CheckAndChange_AppleSWUpdatePolicies.sh
##  Created by SHOMA on 4/22/2019. Last edited by SHOMA 5/9/2019
##
## Overview:
##  Check AppleSystemUpdate policy, Show FinderDialog to change if necessary
##  Touch ID compatible
##
## Discription:
##  This script is made to realize UserReminderService , and promote 
##  Education for users that is not enough with push-services(MDM)
##  Suitable for organizations that encourage users to act.
##
## Requirements:
##  -macOS
##  -Test under macOS 10.14.4
##
## Install and Run:
##  - Copy this script to the appropriate directory (ex.~/Script)
##    and set it Excutable.
##  - Use with launchd/lauchctl
##   - Make commnad-plist file and put it ~/Library/LaunchAgents/
##    - Start with the following command (only the first time)
##       launchctl load /Path/to/plist
##  　- Stop is ...
##       launchctl unload /Path/to/plist
##    - Stop forever...
##       　Remove plist from ~/Library/LaunchAgents/
##    - Check is ...
##       　launchctl list
##  - A confirmation dialog (xxx would like to control "System Events"...)
##    appear at the first run, then push allow button.  
## 
## References:
##  If you did not confirm by mistake, try "$ tccutil reset AppleEvents"
##  
##  Update-policies's plist
##
##  /Library/Preferences/com.apple.commerce.plist <- MacAppStore's Update Policy
##      AutoUpdate
##
##  /Library/Preferences/com.apple.SoftwareUpdate.plist <- macOS's Update Policy
##      AutomaticCheckEnaled
##      AutomaticDownload
##      AutomaticallyInstallMacOSUpdtes
##      ConfigDataInstall
##      CriticalUpdateInstall
##
##
## Author: SHOMA Shimahara <shoma@yk.rim.or.jp>
##





######################## Set "Log" file and function ###########################

LogPath=$HOME/log
LogFile="$LogPath/CheckPolicySoftwareUpdateApple.log"

if [ ! -d "$LogPath" ]; then
    echo "Log directory is not exit!"
    mkdir $LogPath
    echo "Log directory is created"
  else
    echo "Log directory is exit!"
fi

function SendToLog ()
{
echo `date +"%Y-%m-%d %T"` : $@ | tee -a "$LogFile"
}

##################### End of set "Log" file and function #######################





############################## Set Variables ###################################
#
#   1. ChgPolityCmd            : raw change-policy command
#   2. ChgPolicyItems          : All items of change-policy
#   3. NumOfChgPolicyItems     : Number of all items of change-policy
#   4. MesCautionToChange      : FinderDialog's messages (CautionDialog)
#

# ChgPolicyCmd

GetUpPolCmdMAS="defaults read /Library/Preferences/com.apple.commerce.plist"
SetUpPolCmdMAS="defaults write /Library/Preferences/com.apple.commerce.plist"
GetUpPolCmdAp="defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist"
SetUpPolCmdAp="defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist"

[ "$( echo $GetUpPolCmdMAS | sh | grep 'AutoUpdate =' |grep 0 )" ]             &&
ChgPolicyCmd=$SetUpPolCmdMAS" AutoUpdate -int 1" 

[ "$( echo $GetUpPolCmdAp | sh | grep AutomaticCheckEnabled |grep 0 )" ]       &&
[ ! -z "$ChgPolicyCmd" ] && ChgPolicyCmd=$ChgPolicyCmd" ;"                     &&
ChgPolicyCmd=$ChgPolicyCmd$SetUpPolCmdAp" AutomaticCheckEnabled -int 1"

[ "$( echo $GetUpPolCmdAp | sh | grep AutomaticDownload |grep 0 )" ]           &&
[ ! -z "$ChgPolicyCmd" ] && ChgPolicyCmd=$ChgPolicyCmd" ;"                     &&
ChgPolicyCmd=$ChgPolicyCmd$SetUpPolCmdAp" AutomaticDownload -int 1"

[ "$( echo $GetUpPolCmdAp | sh | grep AutomaticallyInstall |grep 0 )" ]        &&
[ ! -z "$ChgPolicyCmd" ] && ChgPolicyCmd=$ChgPolicyCmd" ;"                     &&
ChgPolicyCmd=$ChgPolicyCmd$SetUpPolCmdAp" AutomaticallyInstallMacOSUpdates -int 1"

[ "$( echo $GetUpPolCmdAp | sh | grep ConfigDataInstal |grep 0 )" ]            &&
[ ! -z "$ChgPolicyCmd" ] && ChgPolicyCmd=$ChgPolicyCmd" ;"                     &&
ChgPolicyCmd=$ChgPolicyCmd$SetUpPolCmdAp" ConfigDataInstall -int 1"

[ "$( echo $GetUpPolCmdAp | sh | grep CriticalUpdateInstal |grep 0 )" ]        &&
[ ! -z "$ChgPolicyCmd" ] && ChgPolicyCmd=$ChgPolicyCmd" ;"                     &&
ChgPolicyCmd=$ChgPolicyCmd$SetUpPolCmdAp" CriticalUpdateInstall -int 1"

# ChgPolicyItems: extract all Items from ChgPolicyCmd
ChgPolicyItems=$(
  echo "$ChgPolicyCmd"  |
  sed -e 's/defaults write \/Library\/Preferences\/com.apple.commerce.plist //g' |
  sed -e 's/defaults write \/Library\/Preferences\/com.apple.SoftwareUpdate.plist //g' |
  sed -e 's/ -int 1//g' |
  sed -e 's/;/,/g'
)

# NumOfChgPolicyItems
NumOfChgPolicyItems=$( echo "$ChgPolicyItems" | awk -F ',' '{print NF}' ) 

#for debug
echo "ChgPolicyCmd : "$ChgPolicyCmd
echo "ChgPolicyItems : "$ChgPolicyItems
echo "NumOfChgPolicyItems: "$NumOfChgPolicyItems

# FinderDialog's Message (CautionDialog)
MesCautionToChange="ITサポートチームです

ソフトウエアアップデート設定が自動設定になっていません
常にアップデートを行なわないと動作不良になることがあります
設定変更しますか？

不明な場合はITサポートチーム(tel.xxx-xxxx-xxxx)まで


"

######################### End of Set Variables #################################





############################### Processing #####################################

SendToLog "AppleSoftwareUpdate Check Started"

[ -z "$ChgPolicyCmd" ] &&                           # No Need to Change -> exit
 SendToLog "AppleSoftuareUpdate Policies seems good" &&
 exit 0

[ ! -z "$ChgPolicyCmd" ] &&                         # Need to Change
 SendToLog "AppleSoftwareUpdate Policits to be changed are found" &&
 SendToLog "Num of changes : ""$NumOfChgPolicyItems"              &&
 SendToLog "$ChgPolicyItems"                                      &&

 ReplyOfCautionDiag=$(                              # Set Reply and Display dialog
 osascript <<-EOD &>/dev/null && echo OK || echo Cancel 
    tell application "System Events" to display dialog "$MesCautionToChange" with icon 0
EOD
)

[ "$ReplyOfCautionDiag" = "Cancel" ] &&             # Reply is Cancel -> exit
 SendToLog "Cancel AppleSoftwareUpdates Policites change by User" &&
 exit 0

[ "$ReplyOfCautionDiag" = "OK" ] &&                 # Reply is OK
 ReplyOfAdminDiag=$(                                # Set Reply and Display dialog (AdminPriv.) then Change 
 osascript <<-EOD &>/dev/null && echo OK || echo Cancel
    do shell script "$ChgPolicyCmd 2>/dev/null" with administrator privileges
EOD
)

[ "$ReplyOfAdminDiag" = "OK" ] &&                   # and Logging..
 SendToLog "AppleSoftwareUpdates Policies are Changed"
[ "$ReplyOfAdminDiag" = "Cancel" ] &&
 SendToLog "Cancel AppleSoftwareUpdates Policty change by User(AdminPriv. dialog)"




