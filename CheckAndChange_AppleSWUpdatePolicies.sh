#!/bin/bash
##
## CheckAndChange_AppleSWUpdatePolicies.sh
## Created by SHOMA on 4/22/2019. Last edited by SHOMA 4/23/2019
##
## -----
## Check & Chage AppleSoftware update policies (need Finder login)
## Please use with launchd/launchctl (ex. check Every xx hours while logged in)
##
## -----
## -Display FinderDialog
## -Touch ID compatible
##
##
## ref.
## Check and Change Updates-policies's plist
## /Library/Preferences/com.apple.commerce.plist <-- Mac App Store's Update Policy
##     AutoUpdate
## /Library/Preferences/com.apple.SoftwareUpdate.plist <-- macOS's SoftwareUpdate Policy
##     AutomaticCheckEnaled
##     AutomaticDownload
##     AutomaticallyInstallMacOSUpdtes
##     ConfigDataInstall
##     CriticalUpdateInstall
##
##



################### Set "Log" file and function  ######################

LogPath=$HOME/log
LogFile="$LogPath/CheckPolicySoftwareUpdates.log"

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
##
##  AppleSwUpdateCmd        : PolicyUpdate command (raw)
##  AppleSwUpdateItems      : All items to change
##  NumOfAppleSwUpdateItems : Number of all items to change
##  MesCautionToChange      : FinderDialog's messages (CautionDialog)
##

SendToLog "AppleSoftwareUpdate Check Started"

# AppleSwUpdateCmd 
[ "$( defaults read /Library/Preferences/com.apple.commerce.plist |grep "AutoUpdate =" |grep 0 )" ] &&
AppleSwUpdateCmd="defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdate -int 1" 

[ "$( defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist | grep AutomaticCheckEnabled |grep 0 )" ] &&
[ ! -z "$AppleSwUpdateCmd" ] && AppleSwUpdateCmd=$AppleSwUpdateCmd" ;" &&
AppleSwUpdateCmd=$AppleSwUpdateCmd"defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -int 1"

[ "$( defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist | grep AutomaticDownload |grep 0 )" ] &&
[ ! -z "$AppleSwUpdateCmd" ] && AppleSwUpdateCmd=$AppleSwUpdateCmd" ;" &&
AppleSwUpdateCmd=$AppleSwUpdateCmd"defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -int 1"

[ "$( defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist | grep AutomaticallyInstallMacOSUpdates |grep 0 )" ] &&
[ ! -z "$AppleSwUpdateCmd" ] && AppleSwUpdateCmd=$AppleSwUpdateCmd" ;" &&
AppleSwUpdateCmd=$AppleSwUpdateCmd"defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticallyInstallMacOSUpdates -int 1"

[ "$( defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist | grep ConfigDataInstal |grep 0 )" ] &&
[ ! -z "$AppleSwUpdateCmd" ] && AppleSwUpdateCmd=$AppleSwUpdateCmd" ;" &&
AppleSwUpdateCmd=$AppleSwUpdateCmd"defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist ConfigDataInstall -int 1"

[ "$( defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist | grep CriticalUpdateInstal |grep 0 )" ] &&
[ ! -z "$AppleSwUpdateCmd" ] && AppleSwUpdateCmd=$AppleSwUpdateCmd" ;" &&
AppleSwUpdateCmd=$AppleSwUpdateCmd"defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall -int 1"

# AppleSwUpdateItems
# Extract all Items to change from AppleSwUpdateCmd
AppleSwUpdateItems=$(
  echo "$AppleSwUpdateCmd" |
  sed -e 's/defaults write \/Library\/Preferences\/com.apple.commerce.plist //g' |
  sed -e 's/defaults write \/Library\/Preferences\/com.apple.SoftwareUpdate.plist //g' |
  sed -e 's/ -int 1//g' |
  sed -e 's/;/,/g'
)

# NumOfAppleSwUpdateItems
NumOfAppleSwUpdateItems=$( echo "$AppleSwUpdateItems" | awk -F ',' '{print NF}' ) 

#for debug
echo "Cmd : "$AppleSwUpdateCmd
echo "Items : "$AppleSwUpdateItems
echo "Num : "$NumOfAppleSwUpdateItems

# FinderDialog's Message (CautionDialog)
MesCautionToChange="ITサポートチームです

ソフトウエアアップデート設定が自動設定になっていません
常にアップデートを行なわないと動作不良になることがあります
設定変更しますか？

不明な場合はITサポートチーム(tel.xxx-xxxx-xxxx)まで


"

############################### End of Set Variables ####################################





####################################### Progress #############################################
####
#### Display FinderDialog and Change
####
#### -Check Setting of AppleSoftwareUpdate's Policy (<-Valuable-section)
####   *Not Need to Change
####     ->exit
####   *Need to Change
####     ->Display FinderDialog (CautionDialog)
####        *Cancel
####          ->exit
####        *OK
####          ->Display FinderDialog (AdminPriv.) /w Change comannd
####             *Cancel
####               ->exit
####             *OK /w AdminPriv.
####               ->Change Settings..
####
####

#### Not Need to Change
[ -z "$AppleSwUpdateCmd" ] &&
SendToLog "AppleSoftuareUpdate Policies seems good"

#### Need to Chagnge
[ ! -z "$AppleSwUpdateCmd" ] &&
SendToLog "AppleSoftwareUpdate Policits to be changed are found" &&
SendToLog "Num of changes : ""$NumOfAppleSwUpdateItems" &&
SendToLog "$AppleSwUpdateItems" &&


#### Display FinderDialog (CautionDialog)
AnswerCautionReply=`osascript <<-EOD &>/dev/null && echo OK || echo Cancel 
tell application "System Events" to display dialog "$MesCautionToChange" with icon 0
EOD`

#### OK or Cancel (CautionDialog)-----------------------------------------------------
#### *OK ......(CautionDialog)--------------------------------------------------------
####
####   ->Display FinderDialog (AdminPriv.) /w Change commnad
####
####
if [ "$AnswerCautionReply" = "OK" ] ; then
       AnswerAdminPriv=`osascript <<-EOD &>/dev/null && echo OK || echo Cancel
do shell script "$AppleSwUpdateCmd 2>/dev/null" with administrator privileges
EOD`

#### then OK or Cancel (AdminPriv.)========================================================
####  *OK ......(AdminPriv.)==============================================================
        [ "$AnswerAdminPriv" = "OK" ] &&
        SendToLog "AppleSoftwareUpdates Policies are Changed" ||

####  *Cancel ..(AdminPriv.)==============================================================
        SendToLog "Cancel AppleSoftwareUpdates Policty change by User(AdminPriv. dialog)"
#### End of then OK or Cancel (AdminPriv.)=================================================

#### *Cancel ..(CautionDialog)----------------------------------------------------------
####
    elif [ "$AnswerCautionReply" = "Cancel" ] ; then
        SendToLog "Cancel AppleSoftwareUpdates Policites change by User"
    else
    : 
fi 
#### End of OK or Cancel (CautionDialog) -----------------------------------------------



