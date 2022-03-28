#! /bin/sh

APP_NAME=cryptween-daemon-macos


#  Local crypween binaries dir
CRYPTWEEN_BIN_DIR="/Applications/cryptween.app"
LAUNCHDAEMONS_DIR="/Library/LaunchAgents"
LAUNCHDAEMONS_ID="com.cryptween"
LAUNCHDAEMONS_FILE=$LAUNCHDAEMONS_ID".plist"

if [ -f $LAUNCHDAEMONS_DIR/$LAUNCHDAEMONS_FILE ]; then
    echo "Stopping Crypteen service"
   launchctl unload -w $LAUNCHDAEMONS_DIR/$LAUNCHDAEMONS_FILE
   echo "removing config file $LAUNCHDAEMONS_DIR/$LAUNCHDAEMONS_FILE"
   sudo rm $LAUNCHDAEMONS_DIR/$LAUNCHDAEMONS_FILE
fi

if [ -d $CRYPTWEEN_BIN_DIR ];
then
    echo "Delating Directory $CRYPTWEEN_BIN_DIR..."
    sudo rm -r $CRYPTWEEN_BIN_DIR
fi
echo "Crypteen service it's been removed"