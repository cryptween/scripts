#! /bin/sh

if [ -z ${INFLUXDB_TOKEN+x} ]; 
then 
echo "INFLUXDB_TOKEN enviroment variable is unset. Please set it before start daemon"; 
exit 1
else 
echo "INFLUXDB_TOKEN enviroment variable is correctly set";
fi

APP_NAME=cryptween-daemon-linux

if [ $# -eq 0 ]; then
    LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/cryptween/scripts/releases/latest)
    # The releases are returned in the format {"id":3622206,"tag_name":"hello-1.0.0.11",...}, we have to extract the tag_name.
    VERSION=$(echo $LATEST_RELEASE | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
else
    VERSION=$1                                                                                                                                                                                                                                                                   
fi 
ARTIFACT_URL="https://github.com/cryptween/scripts/releases/download/$VERSION/$APP_NAME"

#  Local crypween binaries dir
# CRYPTWEEN_BIN_DIR="/usr/local/bin/cryptween"
CRYPTWEEN_BIN_DIR="/opt/cryptween/bin"
LAUNCHDAEMONS_DIR="/etc/systemd/user"
LAUNCHDAEMONS_ID="cryptween"
LAUNCHDAEMONS_FILE=$LAUNCHDAEMONS_ID".service"

ENV_DAEMONS_DIR="$HOME/.config/environment.d"
ENV_DAEMONS_FILENAME="90-cryptween.conf"
if [ -d $CRYPTWEEN_BIN_DIR ];
then
    echo "Installing config files in $CRYPTWEEN_BIN_DIR..."
else
    sudo mkdir -p $CRYPTWEEN_BIN_DIR
fi

if [ -f $CRYPTWEEN_BIN_DIR/$APP_NAME ];
then
    sudo rm $CRYPTWEEN_BIN_DIR/$APP_NAME
fi

# Enviroment conf files
if [ -d $ENV_DAEMONS_DIR ];
then
    echo "Configuration Directory in $ENV_DAEMONS_DIR..."
else
    echo "Creating $ENV_DAEMONS_DIR"
    mkdir -p $ENV_DAEMONS_DIR
fi

if [ -f $ENV_DAEMONS_DIR/$ENV_DAEMONS_FILENAME ];
then
    echo "Configuration file in $ENV_DAEMONS_DIR/$ENV_DAEMONS_FILENAME..."
else
cat > $ENV_DAEMONS_DIR/$ENV_DAEMONS_FILENAME <<EOL
INFLUXDB_TOKEN=$INFLUXDB_TOKEN
EOL
fi

echo $ARTIFACT_URL

sudo curl  -L $ARTIFACT_URL -o $CRYPTWEEN_BIN_DIR/$APP_NAME 

sudo chmod 775 $CRYPTWEEN_BIN_DIR/$APP_NAME

if [ -f $LAUNCHDAEMONS_DIR/$LAUNCHDAEMONS_FILE ]; then
    systemctl --user stop $LAUNCHDAEMONS_FILE
    systemctl --user disable $LAUNCHDAEMONS_FILE
    sudo rm $LAUNCHDAEMONS_DIR/$LAUNCHDAEMONS_FILE
fi
cat > $LAUNCHDAEMONS_FILE <<EOL
[Unit]
Description=Cryptween daemon service
After=systend-user-sessions.service

[Service]
Type=simple
WorkingDirectory=$CRYPTWEEN_BIN_DIR
ExecStart=$CRYPTWEEN_BIN_DIR/$APP_NAME
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=CttWBot_Console

[Install]
WantedBy=default.target
EOL

sudo \cp -f ./$LAUNCHDAEMONS_FILE $LAUNCHDAEMONS_DIR/$LAUNCHDAEMONS_FILE
rm $LAUNCHDAEMONS_FILE

systemctl --user enable $LAUNCHDAEMONS_FILE
systemctl --user start $LAUNCHDAEMONS_FILE