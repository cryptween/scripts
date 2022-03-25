#! /bin/sh

if [ -z ${INFLUXDB_TOKEN+x} ]; 
then 
echo "INFLUXDB_TOKEN enviroment variable is unset. Please set it before start daemon"; 
exit 1
else 
echo "INFLUXDB_TOKEN enviroment variable is correctly set";
fi

APP_NAME=cryptween-daemon-macos

if [ $# -eq 0 ]; then
    LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/cryptween/scripts/releases/latest)
    # The releases are returned in the format {"id":3622206,"tag_name":"hello-1.0.0.11",...}, we have to extract the tag_name.
    VERSION=$(echo $LATEST_RELEASE | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
else
    VERSION=$1                                                                                                                                                                                                                                                                   
fi 
ARTIFACT_URL="https://github.com/cryptween/scripts/releases/download/$VERSION/$APP_NAME"

#  Local crypween binaries dir
CRYPTWEEN_BIN_DIR="/Applications/cryptween.app/Daemon"
LAUNCHDAEMONS_DIR="/Library/LaunchAgents"
LAUNCHDAEMONS_ID="com.cryptween"
LAUNCHDAEMONS_FILE=$LAUNCHDAEMONS_ID".plist"


if [ -d $CRYPTWEEN_BIN_DIR ];
then
    echo "Installing config files in $CRYPTWEEN_BIN_DIR..."
else
    echo "Creating dir $CRYPTWEEN_BIN_DIR..."
    sudo mkdir -p $CRYPTWEEN_BIN_DIR
fi

if [ -f $CRYPTWEEN_BIN_DIR/$APP_NAME ];
then
    sudo rm $CRYPTWEEN_BIN_DIR/$APP_NAME
echo ""
fi
echo $ARTIFACT_URL

sudo curl  -L $ARTIFACT_URL -o $CRYPTWEEN_BIN_DIR/$APP_NAME 

sudo chmod 775 $CRYPTWEEN_BIN_DIR/$APP_NAME

if [ -f $LAUNCHDAEMONS_DIR/$LAUNCHDAEMONS_FILE ]; then
   launchctl unload -w $LAUNCHDAEMONS_DIR/$LAUNCHDAEMONS_FILE
   sudo rm $LAUNCHDAEMONS_DIR/$LAUNCHDAEMONS_FILE
fi
#else
#echo -n "Type something and press enter: ";
#read;
#INFLUXDB_TOKEN=${REPLY}
cat > $LAUNCHDAEMONS_FILE <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>EnvironmentVariables</key>
  <dict>
    <key>INFLUXDB_TOKEN</key>
    <string>$INFLUXDB_TOKEN</string>
  </dict>
  <key>Label</key>
  <string>$LAUNCHDAEMONS_ID</string>
  <key>Program</key>
  <string>$CRYPTWEEN_BIN_DIR/$APP_NAME</string>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <!--
  <key>StandardOutPath</key>
  <string>~/startup.stdout</string>
  <key>StandardErrorPath</key>
  <string>~/startup.stderr</string>
  -->
</dict>
</plist>
EOL
   sudo \cp -f ./$LAUNCHDAEMONS_FILE $LAUNCHDAEMONS_DIR/$LAUNCHDAEMONS_FILE
   rm $LAUNCHDAEMONS_FILE
#fi

launchctl load -w $LAUNCHDAEMONS_DIR/$LAUNCHDAEMONS_FILE

#You can stop the launchctl process by
#sudo launchctl stop /Library/LaunchDaemons/com.cryptween.plist
#You can start the launchctl process by
#sudo launchctl start -w /Library/LaunchDaemons/com.cryptween.plist
# sudo launchctl print /Library/LaunchDaemons/com.cryptween.plist

#You can stop the launchctl process by
#sudo launchctl stop /Library/LaunchAgents/com.cryptween.plist
#You can start the launchctl process by
#sudo launchctl start -w /Library/LaunchAgents/com.cryptween.plist
# sudo launchctl print /Library/LaunchAgents/com.cryptween.plist
