#!/bin/bash
##
## Name:
##  CheckAndChange_MSOfficeUpdatePolicies.sh
##  Created by SHOMA on 4/27/2019. Last edited by SHOMA 10/6/2019
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
echo $(date +"%Y-%m-%d %T") : $@ | tee -a "$LogFile"
}

##################### End of set "Log" file and function #######################





############################## Set Variables ###################################
#
#  1. ChgPolicyCmdMS : MSOffice-UpdatePolicy Update command (raw)
#  2. MesCautionToChgPolicyMS : FinderDialog's messages (CautionDialog)
#


[ "$( defaults read ~/Library/Preferences/com.microsoft.autoupdate2.plist |grep HowToCheck |grep -v AutomaticDownload )" ] &&
ChgPolicyCmdMS="defaults write ~/Library/Preferences/com.microsoft.autoupdate2.plist HowToCheck AutomaticDownload"

#for debug
echo "ChgPolicyCmdMS : ""$ChgPolicyCmdMS"

MesCautionToChgPolicyMS="IT support team

MS Office Software update setting is not set to 'Automatically'
You have a security risk and it may malfunction.
Is it okay to change this setting?

If you are unsure, contact the IT support team (tel.xxx-xxxx-xxxx)


"

MesFinishChangesMS="Change finished !
Thank you for your cooperation
IT support team (tel.xxx-xxxx-xxxx)


"


########################### End of Set Variables ###############################





############################### Processing #####################################

SendToLog "MSOfficeUpdate policy check Started"

[ -z "$ChgPolicyCmdMS" ]                            && # No Need to Change -> exit
 SendToLog "MSOfficeUpdate Policy seems good"       &&
 exit 0

[ ! -z "$ChgPolicyCmdMS" ]                          && # Need to Change
 SendToLog "MSOfficeUpdate Policy shuld be changed" && # Set Reply and display dialog
 ReplyOfCaution=$( osascript <<-EOD && echo "Success" || echo "NotSuccess"
  tell application "System Events"
   with timeout of 40 seconds
    button returned of ( display dialog "$MesCautionToChgPolicyMS" buttons {"Yes","No"} default button 1 with title "Caution" with icon 0 giving up after 30 )
   end timeout
  end tell
EOD
)

echo '$Reply of Caution is : '"$ReplyOfCaution"

[ "$( echo $ReplyOfCaution | grep "No Success" )" ]          && # Reply is No -> exit
 SendToLog "Cancel MSOfficeUpdates Policites change by User" &&
 exit 0

[ "$( echo $ReplyOfCaution |grep "Yes Success" )" ]          && # Reply is Yes -> Change
 echo $ChgPolicyCmdMS | sh                                   &&
 SendToLog "MSOfficeUpdate Policies are Changed"             &&
 osascript <<-EOD &>/dev/null                                && # Display thanks Message
  tell application "System Events" to display dialog "$MesFinishChangesMS" buttons {"OK"} with title "Thank you" with icon 2 giving up after 10
EOD
 exit 0

[ "$( echo $ReplyOfCaution |grep "Success" )" ]              && # Reply is "" -> Timeout
 SendToLog "MSOfficeUpdate Policies Change is Timeout"

