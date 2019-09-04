#!/bin/bash
##
## Name:
##  AppleSoftwareUpdate.sh
##  Created by SHOMA on 4/18/2019. Last edited by SHOMA 9/4/2019
##
## Overview:
##  Check AppleSystem Updates ,and if present, Display Dialog to install
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
##  /usr/sbin/softwareupdate
##   -l　                    : List all available updates
##   -ia                     : Install all updates /WO GateKeeper & XProtectData
##     --include-config-data : ..including GateKeeper & XProtect data
##
##  "--include-config-data" is using ONLY after macOS 10.13.x
##
##
## Author: SHOMA Shimahara <shoma@yk.rim.or.jp>
##





######################## Set "Log" file and function ###########################

LogPath=$HOME/log
LogFile="$LogPath/SoftwareUpdatesApple.log"

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





##################### Set Functions /InstallSoftware() #########################
#
# Name:
#   function InstallSoftware ()
#
# Discription:
#   Display FinderDialog (Caution & enter UserAuth/AdminPriv.) and install
#
# Usage:
#   InstallSoftware ('with administrator privileges')
#                                   - when Need to Restart/AdminPriv. to install
#   InstallSoftware ()              - when Not Need to Restart to install
#
# Should be implemented in the future:
#  -Timeout processing (when user do nothing)
#    - OnlyIn "System Events" tell block
#      - close dialog time (giving up after xx)
#      - then kill process script (with timeout of 500 seconds) 
#
#

function InstallSoftware ()
{

# Change Message by argument
[ -z "$1" ] && Mes="$MesNoRestart" || Mes="$MesReqRestart"

# Set Reply and display dialog 
ReplyOfCautionDiag=$(
osascript <<-EOD &>/dev/null && echo OK || echo Cancel
tell application "System Events"
 with timeout of 30 seconds
  display dialog "$Mes" with title "Caution" with icon POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns" giving up after 20
 end timeout
end tell
EOD
)

# Reply is Cancel
[ "$ReplyOfCautionDiag" = "Cancel" ] && SendToLog "Cancel AppleSoftwareUpdates by User"


# Reply is OK
[ "$ReplyOfCautionDiag" = "OK" ]     &&

if [ "$1" = "with administrator privileges" ] ; then # Need to Restart
    SendToLog "Start Updates with Restart"           # Set Reply and display dialog
    ReplyOfAdminDiag=$(                              # to install /w AdminPriv
    osascript <<-EOD &>/dev/null && echo OK || echo Cancel
    do shell script "softwareupdate -ia --include-config-data && shutdown -r now 2>/dev/null" $1
EOD
)
    [ "$ReplyOfAdminDiag" = "OK" ] && SendToLog "Finish AppleSoftwareUpdates (and restart)"
    [ "$ReplyOfAdminDiag" = "Cancel" ] && SendToLog "Cancel AppleSoftwareUpdates by User (AdminPriv.)"

  elif [ -z "$1" ] ; then                            # No Need to Restart
    SendToLog "Start Updates WITHOUT Restart"
    softwareupdate -ia --include-config-data
    SendToLog "Finish AppleSoftwareUpdates"
    osascript <<-EOD &>/dev/null
    tell application "System Events" to display dialog "$MesFinishInstall" buttons {"OK"} with title "Thank you" with icon 2 giving up after 10
EOD

fi

}

################# End of Set Functions / InstallSotware() ######################





############################### Set Variables ##################################
#
#  Variables by Update-command ---
#   1.ReplyOfUpdate           : raw commnd-reply data
#   2.InstallReqSoftwares    : All Install/Update Software
#   3.RecommendedSoftwares   : Recommended Install/Update Software
#   4.NeedToRestartSoftwares : Need to Restart Install/Update Software
#   5.NumOfSoftwares:          Number of All Install/Update Software
#   6.UpdatesFlag [Yes/No]   : Is there Updater or not
#   7,RestartFlag [Yes/No]   : Neet to Restart or not
#
#  Messages --- 
#   1.MesReqRestart    : Message when there is update that needs to restart
#   2.MesNoRestart     : Message when there is update htat Not needs to restart
#   3.MesFinishInstall : Message when finished install
#
#

#ReplyOfUpdate=$(softwareupdate -l)  # before macOS 10.13.x
ReplyOfUpdate=$(softwareupdate -l --include-config-data)

# Extract SoftwareName from softwareupdate -l --include-config-data
InstallReqSoftwares=$(
  echo "$ReplyOfUpdate" |
  grep -v "^$" |
  grep -v "Software Update Tool" |
  grep -v "Finding available software" |
  grep -v "Software Update found the following new or updated software:" |
  grep -v "*" |
  sed 's/^[[:space:]]*//'
)
RecommendSoftwares=$(echo "$ReplyOfUpdate" | grep recommended)
NeedToRestartSoftwares=$(echo "$ReplyOfUpdate" | grep restart)
NumOfSoftwares=$( echo "$InstallReqSoftwares" |grep -cv '^$' )

[ -z "$RecommendSoftwares" ] && UpdatesFlag="No" || UpdatesFlag="Yes"
[ -z "$NeedToRestartSoftwares" ] && RestartFlag="No" || RestartFlag="Yes"

#for debug
echo -e "ReplyOfUpdate:\n""$ReplyOfUpdate" 
echo "UpdatesFlag: " $UpdatesFlag
echo "RestartFlag: " $RestartFlag
echo "Num of Updates: " $NumOfSoftwares
echo -e "Install Software(s):\n" $InstallReqSoftwares


MesReqRestart="IT support team

There are important software updates
This process requires administrator privileges and will restart automatically
Do you want to allow it?

If you are unsure, contact the IT support team (tel.xxx-xxxx-xxxx)


"

MesNoRestart=i"IT support team

There are important software updates
This process does not require a restart
Is it okay to start the installation?

If you are unsure, contact the IT support team (tel.xxx-xxxx-xxxx)


"

MesFinishInstall="Update finished !
Thank you for your cooperation
IT support team (tel.xxx-xxxx-xxxx)


"


############################  End of Set Variables #############################





################################# Processing ###################################

SendToLog "AppleSoftwareUpdate Check Started"

if [ -z "$InstallReqSoftwares" ]; then
    echo "No AppleSoftwareUpdaters"
    SendToLog "No Update found"

  elif [ "$RestartFlag" = "Yes" ]; then
    echo "After Updates, Need to Restart"
    SendToLog "AppleSoftwareUpdaters need to restart are found"
    SendToLog "Num of Updates: ""$NumOfSoftwares"
    SendToLog "$( echo "$InstallReqSoftwares" | tr '\n' '; ')"
    InstallSoftware 'with administrator privileges'

  elif [ "$UpdatesFlag" = "Yes" ]; then
    echo "Need to Updates"
    SendToLog "AppleSoftwareUpdaters are found"
    SendToLog "Num of Updates: ""$NumOfSoftwares"
    SendToLog "$( echo "$InstallReqSoftwares" | tr '\n' ';')"
    InstallSoftware

  else
    echo "something wrong!"

fi



