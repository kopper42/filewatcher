#/bin/bash

SERVICE_USER="pisync"
SERVICE_USER_HOME="/opt/$SERVICE_USER"
FILEWATCHER_CONFIG_DIR="/etc/filewatcher"


ensure_service_user() {
    echo "Checking for $SERVICE_USER user..."
    if( id $SERVICE_USER > /dev/null 2>&1 ); then
        echo "User $SERVICE_USER exists."
    else
        useradd -r -s /sbin/nologin -c "PiSync Service User" -m -d $SERVICE_USER_HOME $SERVICE_USER
        echo "User $SERVICE_USER created."
    fi
}

echo "PiSync Setup"
echo "--------------------------------------"
echo "This script will set up the PiSync configuration for the Filewatcher service."
echo "The Filewatcher service is expected to be installed on the server."
echo ""
echo "Which Pihole would you like to set up?"
echo "--------------------------------------"
echo "p) Primary Pihole"
echo "s) Secondary Pihole"
echo "*) Exit"
read -p "Enter your choice (p/s/*): " choice

case $choice in
    p)
        echo "Installing pisync-push..."
        ensure_service_user

        # Copy the pisync push config to the filewatcher directory
        cp ./pisync-push.conf $FILEWATCHER_CONFIG_DIR/

        # Copy the pisync ssh push script to the service user home directory
        cp ./pisync-ssh-push.sh $SERVICE_USER_HOME/

        mkdir -p $SERVICE_USER_HOME/.ssh

        echo "The public key from the secondary PiHole will need to be added to:"
        echo "${SERVICE_USER_HOME}/.ssh/authorized_keys"

        ;;
    s)
        echo "Installing pisync-receiver..."
        ensure_service_user


        # Copy the pisync push config to the filewatcher directory
        cp ./pisync-reciever.conf $FILEWATCHER_CONFIG_DIR/

        # Copy the pisync ssh push script to the service user home directory
        cp ./pisync-receiver.sh $SERVICE_USER_HOME/

        mkdir -p $SERVICE_USER_HOME/.ssh

        # Create the pisync ssh key if this is for the receiver
        ssh-keygen -t rsa -b 4096 -C "PiSync Service" -N "" -f $SERVICE_USER_HOME/.ssh/id_rsa_service

        echo ""
        echo ===============================================================
        echo " Public key ($SERVICE_USER_HOME/.ssh/id_rsa_service.pub)"
        echo " This will be needed for installation on the secondary PiHole."
        echo ===============================================================
        echo ""
        # Add the public key to the pisync
        cat $SERVICE_USER_HOME/.ssh/id_rsa_service.pub
        echo ""

        # pisync-receiver installation
        ;;
    *)
        echo "Exiting."
        exit 0
        ;;
esac




