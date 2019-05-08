#!/bin/bash
##
## CheckAndChange_AppleSWUpdatePolicies.sh
## Created by SHOMA on 4/22/2019. Last edited by SHOMA 5/9/2019
##
## Overview:
##  Check AppleSystemUpdate policy, and if need, Display FinderDialog to change.
##  (Touch ID compatible)
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
##  - Copy this script to the appropriate directory (ex.~/Script),and set it Excutable.
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
##  - A confirmation dialog (xxx would like to control "System Events"...) appear
##    at the first run, then push allow button.  
## 
## References:
##  If you did not confirm by mistake, try "$ tccutil reset AppleEvents"
##  
##  Update-policies's plist
##
##    /Library/Preferences/com.apple.commerce.plist <-- Mac App Store's Update Policy
##      AutoUpdate
##
##    /Library/Preferences/com.apple.SoftwareUpdate.plist <-- macOS's SoftwareUpdate Policy
##      AutomaticCheckEnaled
##      AutomaticDownload
##      AutomaticallyInstallMacOSUpdtes
##      ConfigDataInstall
##      CriticalUpdateInstall
##
##
## Author: SHOMA Shimahara <shoma@yk.rim.or.jp>
##



################### Set "Log" file and function  ######################

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

################ End of set "Log" file and function ################




############################### Set Variables ####################################
#
#   1.ChgPolityCmd            : raw change-policy command
#   2.ChgPolicyItems          : All items of change-policy
#   3.NumOfChgPolicyItems     : Number of all items of change-policy
#   4.MesCautionToChange      : FinderDialog's messages (CautionDialog)
#

# ChgPolicyCmd 
[ "$( defaults read /Library/Preferences/com.apple.commerce.plist |grep "AutoUpdate =" |grep 0 )" ] &&
ChgPolicyCmd="defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdate -int 1" 

[ "$( defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist | grep AutomaticCheckEnabled |grep 0 )" ] &&
[ ! -z "$ChgPolicyCmd" ] && ChgPolicyCmd=$ChgPolicyCmd" ;" &&
ChgPolicyCmd=$ChgPolicyCmd"defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -int 1"

[ "$( defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist | grep AutomaticDownload |grep 0 )" ] &&
[ ! -z "$ChgPolicyCmd" ] && ChgPolicyCmd=$ChgPolicyCmd" ;" &&
ChgPolicyCmd=$ChgPolicyCmd"defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -int 1"

[ "$( defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist | grep AutomaticallyInstallMacOSUpdates |grep 0 )" ] &&
[ ! -z "$ChgPolicyCmd" ] && ChgPolicyCmd=$ChgPolicyCmd" ;" &&
ChgPolicyCmd=$ChgPolicyCmd"defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticallyInstallMacOSUpdates -int 1"

[ "$( defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist | grep ConfigDataInstal |grep 0 )" ] &&
[ ! -z "$ChgPolicyCmd" ] && ChgPolicyCmd=$ChgPolicyCmd" ;" &&
ChgPolicyCmd=$ChgPolicyCmd"defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist ConfigDataInstall -int 1"

[ "$( defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist | grep CriticalUpdateInstal |grep 0 )" ] &&
[ ! -z "$ChgPolicyCmd" ] && ChgPolicyCmd=$ChgPolicyCmd" ;" &&
ChgPolicyCmd=$ChgPolicyCmd"defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall -int 1"

# ChgPolicyItems: all Items extract from ChgPolicyCmd
ChgPolicyItems=$(
  echo "$ChgPolicyCmd" |
  sed -e 's/defaults write \/Library\/Preferences\/com.apple.commerce.plist //g' |
  sed -e 's/defaults write \/Library\/Preferences\/com.apple.SoftwareUpdate.plist //g' |
  sed -e 's/ -int 1//g' |
  sed -e 's/;/,/g'
)

# NumOfChgPolicyItems
NumOfChgPolicyItems=$( echo "$ChgPolicyItems" | awk -F ',' '{print NF}' ) 

#for debug
echo "Cmd : "$ChgPolicyCmd
echo "Items : "$ChgPolicyItems
echo "Num : "$NumOfChgPolicyItems

# FinderDialog's Message (CautionDialog)
MesCautionToChange="ITサポートチームです

ソフトウエアアップデート設定が自動設定になっていません
常にアップデートを行なわないと動作不良になることがあります
設定変更しますか？

不明な場合はITサポートチーム(tel.xxx-xxxx-xxxx)まで


"

############################### End of Set Variables ####################################





####################################### Progress #############################################

SendToLog "AppleSoftwareUpdate Check Started"

[ -z "$ChgPolicyCmd" ] &&
SendToLog "AppleSoftuareUpdate Policies seems good"

[ ! -z "$ChgPolicyCmd" ] &&
SendToLog "AppleSoftwareUpdate Policits to be changed are found" &&
SendToLog "Num of changes : ""$NumOfChgPolicyItems" &&
SendToLog "$ChgPolicyItems" &&

AnswerCautionReply=`osascript <<-EOD &>/dev/null && echo OK || echo Cancel 
tell application "System Events" to display dialog "$MesCautionToChange" with icon 0
EOD`

if [ "$AnswerCautionReply" = "OK" ] ; then
    AnswerAdminPriv=$(
        osascript <<-EOD &>/dev/null && echo OK || echo Cancel
        do shell script "$ChgPolicyCmd 2>/dev/null" with administrator privileges
EOD
)
    [ "$AnswerAdminPriv" = "OK" ] && SendToLog "AppleSoftwareUpdates Policies are Changed"
    [ "$AnswerAdminPriv" = "Cancel" ] && SendToLog "Cancel AppleSoftwareUpdates Policty change by User(AdminPriv. dialog)"

  elif [ "$AnswerCautionReply" = "Cancel" ] ; then
    SendToLog "Cancel AppleSoftwareUpdates Policites change by User"

fi 


