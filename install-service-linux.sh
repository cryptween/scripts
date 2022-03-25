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
echo $ARTIFACT_URL

curl  -L $ARTIFACT_URL -o $CRYPTWEEN_BIN_DIR/$APP_NAME 

sudo chmod 775 $CRYPTWEEN_BIN_DIR/$APP_NAME

if [ -f /etc/systemd/system/cryptween.service ]; then
    sudo systemctl stop cryptween.service
    sudo systemctl disable cryptween.service
    sudo rm /etc/systemd/system/cryptween.service
fi
cat > cryptween.service <<EOL
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
WantedBy=multi-user.target
EOL

sudo \cp -f ./cryptween.service /etc/systemd/system/cryptween.service

sudo systemctl enable cryptween.service
sudo systemctl start cryptween.service