#!/bin/bash
##
## Name:
##  MSSoftwareUpdate.sh
##  Created by SHOMA on 4/29/2019. Last edited by SHOMA 4/29/2019
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
echo `date +"%Y-%m-%d %T"` : $@ | tee -a "$LogFile"
}

###################### End of set "Log" file and function ######################






############################### Set Variables ##################################
#
#  Variables by Update-command ---
#      1.ReplyOfUpdateMS       : raw command-reply data
#      2.InstallSoftwaresMS    : Install/Update Softwares
#   　 3.NumOfSoftwareMS       : Number of Install/Update Softwares
#
#  Messages ---
#      4.MesCautionToInstallMS : Message when there is update
#
#

UpMSCmd="/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate"
ReplyOfUpdateMS=$( echo "$UpMSCmd"" -l" | sh )

InstallSoftwaresMS=$(
 echo "$ReplyOfUpdateMS" |
 grep -v "Checking for updates" |
 grep -v "Updates available" |
 grep -v "No updates available" |
 sed -e 's/^..//g'
)

NumOfSoftwareMS=$( echo "$InstallSoftwaresMS" | grep -cv '^$' )

MSOfficeSwUpdateCmd=$( echo "$UpMSCmd"" -i" )

#for debug
echo "ReplyOfUpdateMS : " "$ReplyOfUpdateMS"
echo "InstallSoftwaresMS :"
echo "$InstallSoftwaresMS"
echo "NumOfSoftwareMS : " "$NumOfSoftwareMS"
echo "MSOfficeSwUpdateCmd: " "$MSOfficeSwUpdateCmd"


MesCautionToInstallMS="ITサポートチームです

MS Officeの重要なソフトウエアアップデートがあります
常にアップデートを行なわないと動作不良になることがあります
インストールを始めても宜しいですか？


不明な場合はITサポートチーム(tel.xxx-xxxx-xxxx)まで


"
MesFinishInstall="アップデートが終了しました
MS Officeソフトウエアを起動中の場合は一度終了させてください
ご協力ありがとうございました
ITサポートチーム(tel.xxx-xxxx-xxxx)


"

########################### End of Set Variables ###############################





################################ Processing ####################################

SendToLog "MSOffice SoftwareUpdates check Started"

# No Need to Change
[ -z "$InstallSoftwaresMS" ]                       &&
SendToLog "MSOffice Softuare seems up to date"     &&
exit 0

# Need to Change
[ ! -z "$InstallSoftwaresMS" ]                     &&
SendToLog "MSOffice SoftwareUpdates are found"     &&
ReplyOfCautionDiag=$(
osascript <<-EOD &>/dev/null && echo OK || echo Cancel 
tell application "System Events" to display dialog "$MesCautionToInstallMS" with icon 0
EOD
)

# Reply is Cancel
[ "$ReplyOfCautionDiag" = "Cancel" ]               &&
SendToLog "Cancel MSOfficeSoftwareUpdates by User" &&
exit 0

# Reply is OK
[ "$ReplyOfCautionDiag" = "OK" ]                   &&
echo $MSOfficeSwUpdateCmd | sh                     &&
SendToLog "MSOffice SoftwareUpdates are Finished"  &&
osascript <<-EOD &>/dev/null
tell application "System Events" to display dialog "$MesFinishInstall" buttons {"OK"} with icon 2
EOD



