#!/bin/bash
##
## AppleSoftwareUpdate.sh
## Created by SHOMA on 4/18/2019. Last edited by SHOMA 4/26/2019
##
## -----
## Display FinderDialog for LoginUser ,and update macOS (need Finder login)
## Use with launchd/launchctl (ex. check Every xx hours while logged in)
##
## -Touch ID compatible
##
## -----
## remark.
## softwareupdate's "--include-config-data" option for GateKeeper & XProtect
## in ONLY use after macOS 10.13.x
##
## -----
## ref.
##  If want to add support
##    -"Mac App Store" software, work with "mas-cli".
##    -"MS Office" software, work with "msupdate -i|l"(MS official tool) 
##
##


################### Set "Log" file and function  ######################

LogPath=$HOME/log
LogFile="$LogPath/SoftwareUpdates.log"

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





##################### Set Functions /InstallSoftware() ########################
##
## function InstallSoftware ()
##
## -----
## Display FinderDialog (to enter UserAuth/AdminPriv.) and install
##
## -----
## argument is one of 
##   -'with administrator privileges' : Install /w  AdminPriv.
##   -''                              : Install /wo AdminPriv.
##
## ex.
##  InstallSoftware ('with administrator privileges')
##                     - Need to Restart/AdminPriv. to Install
##  InstallSoftware () - Not Need to Restart to Install
##
##

function InstallSoftware ()
{
MesReqRestart="ITサポートチームです

重要なソフトウエアアップデートがあります
この処理は管理者権限が必要で自動的に再起動されます
許可しますか？

不明な場合はITサポートチーム(tel.xxx-xxxx-xxxx)まで


"
MesNoRestart="ITサポートチームです

重要なソフトウエアアップデートがあります
この処理には再起動の必要がありません
インストールを始めても宜しいですか？

不明な場合はITサポートチーム(tel.xxx-xxxx-xxxx)まで


"
MesFinishInstall="アップデートが終了しました

ご協力ありがとうございました
ITサポートチーム(tel.xxx-xxxx-xxxx)


"

## Change messages by argument
[ -z "$1" ] && Mes="$MesNoRestart" || Mes="$MesReqRestart"


## Display FinderDialog (Caution Dialog)
AnswerOfCautionDiag=`osascript <<-EOD &>/dev/null && echo OK || echo Cancel
tell application "System Events" to display dialog "$Mes" with icon 0
EOD`


## OK or Cancel (Caution Dialog)
## Cancel 
[ "$AnswerOfCautionDiag" = "Cancel" ] &&
SendToLog "Cancel AppleSoftwareUpdates by User" ||

## OK
## Restart or Not
## Need to Restart
if [ "$1" = "with administrator privileges" ]; then
    SendToLog "Start Updates with Restart"
    AnswerOfAdminDiag=`osascript <<-EOD &>/dev/null && echo OK || echo Cancel
do shell script "softwareupdate -ia --include-config-data && shutdown -r now 2>/dev/null" $@
EOD`

## Cancel  (AdminPriv.)
    [ "$AnswerOfAdminDiag" = "Cancel" ] && SendToLog "Cancel AppleSoftwareUpdates by User (AdminPriv.)"
## OK  (AdminPriv.) and Finish install
    [ "$AnswerOfAdminDiag" = "OK" ] && SendToLog "Finish AppleSoftwareUpdates (and restart)"



## Not Need to Restart
  elif [ "$1" = "" ]; then
    SendToLog "Start Updates WITHOUT Restart"
    osascript <<-EOD &>/dev/null && echo OK || echo Cancel
do shell script "softwareupdate -ia --include-config-data 2>/dev/null"
EOD

    SendToLog "Finish AppleSoftwareUpdates" &&
    osascript <<-EOD &>/dev/null && echo OK || echo Cancel
tell application "System Events" to display dialog "$MesFinishInstall" buttons {"OK"} with icon 2
EOD



else
    echo "something wrong!"
fi

}
##################### End of Set Functions / InstallSotware() ######################





#########################  Set Variables  ##############################
##
## UpdatesReply :           Reply of softwareupdate -l --include-config-data
## InstallReqSoftwares :    List of SoftwareNames /all Requested
## RecommendedSoftwares :   List of SoftwareNames etc./Recommended
## NeedToRestartSoftwares : List of SoftwareNames etc./Need to Restart
## NumOfSoftwares:          Number of Software to install /all Requested
##
## -----
## ref.
##  UpdatesFlag : Yes or No - Is there Updater or not
##  RestartFlag : Yes or No - Neet to Restart or not
##
##

#UpdatesReply=$(softwareupdate -l)
UpdatesReply=$(softwareupdate -l --include-config-data)


# for debug
echo "$UpdatesReply" 


# Extract SoftwareName from softwareupdate -l --include-config-data
InstallReqSoftwares=$(
  echo "$UpdatesReply" |
  grep -v "^$" |
  grep -v "Software Update Tool" |
  grep -v "Finding available software" |
  grep -v "Software Update found the following new or updated software:" |
  grep -v "*" |
  sed -e 's/^.//g'
)

NumOfSoftwares=$( echo "$InstallReqSoftwares" |grep -cv '^$' )


RecommendSoftwares=$(echo "$UpdatesReply" | grep recommended)
NeedToRestartSoftwares=$(echo "$UpdatesReply" | grep restart)

[ -z "$RecommendSoftwares" ] && UpdatesFlag="No" || UpdatesFlag="Yes"
[ -z "$NeedToRestartSoftwares" ] && RestartFlag="No" || RestartFlag="Yes"

#for debug
echo "UpdatesFlag: " $UpdatesFlag
echo "RestartFlag: " $RestartFlag
echo "Num of Updates: " $NumOfSoftwares
echo -e "Install Software(s):\n" $InstallReqSoftwares

########################  End Variables Set  #########################





########################    Processing     ##########################
##

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
    SendToLog "$( echo "$InstallReqSoftwares" | tr '\n' '; ')"
#    SendToLog "$InstallReqSoftwares"
    InstallSoftware

  else
    echo "something wrong!"

fi



