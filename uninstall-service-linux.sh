#! /bin/sh

APP_NAME=cryptween-daemon-linux


#  Local crypween binaries dir
# CRYPTWEEN_BIN_DIR="/usr/local/bin/cryptween"
CRYPTWEEN_BIN_DIR="/opt/cryptween/bin"
LAUNCHDAEMONS_DIR="/etc/systemd/user"
LAUNCHDAEMONS_ID="cryptween"
LAUNCHDAEMONS_FILE=$LAUNCHDAEMONS_ID".service"

ENV_DAEMONS_DIR="$HOME/.config/environment.d"
ENV_DAEMONS_FILENAME="90-cryptween.conf"

if [ -f $LAUNCHDAEMONS_DIR/$LAUNCHDAEMONS_FILE ]; then
    echo "Stopping service .."
    systemctl --user stop $LAUNCHDAEMONS_FILE
    systemctl --user disable $LAUNCHDAEMONS_FILE
    echo "deleting service file .. $LAUNCHDAEMONS_DIR/$LAUNCHDAEMONS_FILE"
    sudo rm $LAUNCHDAEMONS_DIR/$LAUNCHDAEMONS_FILE
fi

if [ -f $CRYPTWEEN_BIN_DIR/$APP_NAME ];
then
    echo "Removing app .. $CRYPTWEEN_BIN_DIR/$APP_NAME"
    sudo rm -r "/opt/cryptween"
fi

# Enviroment conf files


if [ -f $ENV_DAEMONS_DIR/$ENV_DAEMONS_FILENAME ];
then
    echo "removing config file .. $ENV_DAEMONS_DIR/$ENV_DAEMONS_FILENAME"
    rm $ENV_DAEMONS_DIR/$ENV_DAEMONS_FILENAME
fi
systemctl --user daemon-reload
echo "Crypteen service it's been removed"
