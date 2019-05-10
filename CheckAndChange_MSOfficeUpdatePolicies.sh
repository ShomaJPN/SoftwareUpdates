#!/bin/bash
##
## Name:
##  CheckAndChange_MSOfficeUpdatePolicies.sh
##  Created by SHOMA on 4/27/2019. Last edited by SHOMA 5/9/2019
##
## Overview:
##  Check MSOffice Update Polity ,Show FinderDialog to change if necessary
##
## Description:
##  This script is made to realize UserReminderService , and promote 
##  Education for users that is not enough with push-services(MDM)
##  Suitable for organizations that encourage users to act.
##
## Requirement:
##  -MS Office 365 for mac
##  -Test under mojave
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
##   ~/Library/Preferences/com.microsoft.autoupdate2.plist  <-- MSOffice Update Policy
##     HowToCheck           <-- check this key
##       Maunal
##       AutomaticCheck
##       AutomaticDownload  <-- set this value
##
## Author: SHOMA Shimahara <shoma@yk.rim.or.jp>
##



######################## Set "Log" file and function ###########################

LogPath=$HOME/log
LogFile="$LogPath/CheckPolicySoftwareUpdateMS.log"

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
#  1. MSOfficeUpdatePolicyCmd : MSOffice-UpdatePolicy Update command (raw)
#  2. MesCautionToChgPolicyMS : FinderDialog's messages (CautionDialog)
#


[ "$( defaults read ~/Library/Preferences/com.microsoft.autoupdate2.plist |grep HowToCheck |grep -v AutomaticDownload )" ] &&
MSOfficeUpdatePolicyCmd="defaults write ~/Library/Preferences/com.microsoft.autoupdate2.plist HowToCheck AutomaticDownload"

#for debug
echo "MSOfficeUpdatePolicyCmd : ""$MSOfficeUpdatePolicyCmd"

MesCautionToChgPolicyMS="ITサポートチームです

MS Officeソフトウエアアップデート設定が自動設定になっていません
常にアップデートを行なわないと動作不良になることがあります
設定変更しますか？

不明な場合はITサポートチーム(tel.xxx-xxxx-xxxx)まで


"

########################### End of Set Variables ###############################





############################### Processing #####################################

SendToLog "MSOfficeSoftwareUpdate policy check Started"

[ -z "$MSOfficeUpdatePolicyCmd" ]               && # No Need to Change -> exit
SendToLog "MSOfficeSoftuareUpdate Policy seems good" &&
exit 0

[ ! -z "$MSOfficeUpdatePolicyCmd" ]             && # Need to Change
SendToLog "MSOfficeSoftwareUpdate Policy to be changed is found" &&
ReplyOfCaution=$(                                  # Set Reply and Display dialog
osascript <<-EOD &>/dev/null && echo OK || echo Cancel 
tell application "System Events" to display dialog "$MesCautionToChgPolicyMS" with icon 0
EOD
)

[ "$ReplyOfCaution" = "Cancel" ]                && # Reply is Cancel -> exit
SendToLog "Cancel MSOfficeSoftwareUpdates Policites change by User" &&
exit 0

[ "$ReplyOfCaution" = "OK" ]                    && # Reply is OK -> Change
osascript <<-EOD &>/dev/null && 
do shell script "$MSOfficeUpdatePolicyCmd 2>/dev/null"
EOD
SendToLog "MSOfficeSoftwareUpdate Policies are Changed" 

