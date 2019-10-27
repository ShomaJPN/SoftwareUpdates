#!/bin/bash
##
## Name:
##  MSSoftwareUpdate.sh
##  Created by SHOMA on 4/29/2019. Last edited by SHOMA 9/4/2019
##
## Overview:
##  Check MSOffice Updates ,and if present, Display dialog to install
##
## Description:
##  This script is made to realize UserReminderService , and promote 
##  Education for users that is not enough with push-services(MDM)
##  Suitable for organizations that encourage users to act.
##
## Requirements:
##  -MS Office 365 for mac
##  -Test under mojave 10.14.4
##
## Install and Run:
##  - Copy this script to the appropriate directory (ex.~/Script),
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
##  ~/Library/Preferences/com.microsoft.autoupdate2.plist <- SettingPlist
##     HowToCheck
##       AutomaticDownload <-- Value to be set!
##
##  /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app\
##   /Contents/MacOS/msupdate <- Updater
##         -c  : Display current AutoUpdate configuration
##         -l  : List available updates for installed Microsoft applications
##         -i  : Download and install available updates
##
## Author: SHOMA Shimahara <shoma@yk.rim.or.jp>
##





####################### Set "Log" file and function ############################

LogPath=$HOME/log
LogFile="$LogPath/SoftwareUpdatesMS.log"

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

###################### End of set "Log" file and function ######################






############################### Set Variables ##################################
#
#  MS Office Update-commnad ---
#      1.UpdateCmdMS           : MS Office Update command
#      2.InstallCmdMS          : MS Office Update command to install
#
#  Variables by Update-command ---
#      4.ReplyOfUpdateMS       : raw command-reply data
#      5.InstallSoftwaresMS    : Install/Update Softwares
#   　 6.NumOfSoftwaresMS       : Number of Install/Update Softwares
#
#  Messages ---
#      7.MesCautionToInstallMS : Message when there is update
#
#

UpdateCmdMS="/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate"
InstallCmdMS="$UpdateCmdMS"" -i"

ReplyOfUpdateMS=$( echo "$UpdateCmdMS"" -l" | sh )

InstallSoftwaresMS=$(
 echo "$ReplyOfUpdateMS" |
 grep -v "Checking for updates" |
 grep -v "Updates available" |
 grep -v "No updates available" |
 sed 's/[[:space:]]*//'
)

NumOfSoftwaresMS=$( echo "$InstallSoftwaresMS" | grep -cv '^$' )


#for debug
echo "---"
echo "$InstallCmdMS"
echo "---"

echo -e "Reply of Update MS\n""$ReplyOfUpdateMS"
echo -e "Install Software(s) MS:\n" $InstallSoftwaresMS
echo "Num of Updates : " "$NumOfSoftwaresMS"


MesCautionToInstallMS="IT support team

There is an important update for MS Office.
If you don't always update, you may have a problem.
Is it okay to start the installation?


If you are unsure, please contact the IT support team
 (tel.xxx-xxxx-xxxx)


"

MesFinishInstall="Update finished !
If MS Office software is running, please close it once
Thank you for your cooperation
IT support team (tel.xxx-xxxx-xxxx)


"

########################### End of Set Variables ###############################





################################ Processing ####################################

SendToLog "MSOffice SoftwareUpdates check Started"

[ -z "$InstallSoftwaresMS" ]                                 && # No Need to Change -> exit
 SendToLog "MSOffice Softuare seems up to date"              &&
 exit 0

[ ! -z "$InstallSoftwaresMS" ]                               && # Need to Change
 SendToLog "MSOffice SoftwareUpdates are found"              &&
 SendToLog "Num of Updates: ""$NumOfSoftwaresMS"             &&
 SendToLog "$( echo -n "$InstallSoftwaresMS" | tr '\n' ';')" &&
 ReplyOfCautionDiag=$(
 osascript <<-EOD && echo "Success" || echo "NotSuccess" 
tell application "System Events"
 with timeout of 30 seconds
  button returned of ( display dialog "$MesCautionToInstallMS" buttons {"Yes","No"} default button 1 with title "Caution" with icon POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns" giving up after 20 )
 end timeout
end tell
EOD
)

[ "$( echo $ReplyOfCautionDiag | grep "NO Success" )" ]      && # Reply is Cancel -> exit
 SendToLog "Cancel MSOfficeSoftwareUpdates by User"          &&
 exit 0

[ "$(echo $ReplyOfCautionDiag | grep "YES Success")" ]       && # Reply is OK     -> Change
 echo $InstallCmdMS | sh                                     &&
 SendToLog "MSOffice SoftwareUpdates are Finished"           &&
 osascript <<-EOD &>/dev/null
 tell application "System Events" to display dialog "$MesFinishInstall" buttons {"OK"} with title "Thank you" with icon 2 giving up after 10
EOD



