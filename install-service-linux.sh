#! /bin/sh

if [ -z ${INFLUXDB_TOKEN+x} ]; 
then 
echo "INFLUXDB_TOKEN enviroment variable is unset. Please set it before start daemon"; 
exit 1
else 
echo "INFLUXDB_TOKEN enviroment variable is correctly set";
fi

if [ $# -eq 0 ]; then
    LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/cryptween/scripts/releases/latest)
    # The releases are returned in the format {"id":3622206,"tag_name":"hello-1.0.0.11",...}, we have to extract the tag_name.
    VERSION=$(echo $LATEST_RELEASE | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
else
    VERSION=$1                                                                                                                                                                                                                                                                   
fi 
ARTIFACT_URL="https://github.com/cryptween/scripts/releases/download/$VERSION/cryptween-daemon-linux"

#  Local crypween binaries dir
# CRYPTWEEN_BIN_DIR="/usr/local/bin/cryptween"
CRYPTWEEN_BIN_DIR="/opt/cryptween/bin"

if [ -d $CRYPTWEEN_BIN_DIR ];
then
    sudo mkdir -p $CRYPTWEEN_BIN_DIR
fi

if [ -f $CRYPTWEEN_BIN_DIR/cryptween-daemon-linux ];
then
    rm $CRYPTWEEN_BIN_DIR/cryptween-daemon-linux
fi
echo $ARTIFACT_URL

sudo wget $ARTIFACT_URL -P $CRYPTWEEN_BIN_DIR

if [ -f /etc/systemd/system/cryptween.service ]; then
    sudo systemctl stop cryptween.service
    sudo systemctl disable cryptween.service
else
cat > cryptween.service <<EOL
[Unit]
Description=Cryptween daemon service
After=systend-user-sessions.service

[Service]
Type=simple
ExecStart=$CRYPTWEEN_BIN_DIR/cryptween-daemon-linux
EOL
    sudo \cp -f ./cryptween.service /etc/systemd/system/cryptween.service
fi

sudo systemctl enable cryptween.service
sudo systemctl start cryptween.service