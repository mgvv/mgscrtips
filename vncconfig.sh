#!/bin/bash
userNum=1

#Step1: Find the available port(s) for VNC service
port=5901
session=1
count=0
ports=()
sessions=()
currentTimestamp=`date +%y-%m-%d-%H:%M:%S`
while [ "$count" -lt "$userNum" ]; do
    netstat -a | grep ":$port\s" >> /dev/null
    if [ $? -ne 0 ]; then
        ports[$count]=$port
        sessions[$count]=$session
        count=`expr $count + 1`
        echo $port" is available for VNC service"
    fi
    session=`expr $session + 1`
    port=`expr $port + 1`
done

#Step2: Set the VNC password

echo "Please set the VNC password for user mgw"

su - mgw -c vncpasswd



#Step3: Write the VNC configuration
#Backup configuration file

vnc_conf="/etc/systemd/system/vncserver@:"${sessions[0]}".service"
vnc_conf_backup=$vnc_conf.vncconfig.$currentTimestamp
if [ -f "$vnc_conf" ]; then
    echo backup $vnc_conf to $vnc_conf_backup
    cp $vnc_conf $vnc_conf_backup
fi
echo "
[Unit]
Description=Remote desktop service (VNC)
After=syslog.target network.target

[Service]
Type=forking
# Clean any existing files in /tmp/.X11-unix environment
ExecStartPre=/bin/sh -c '/usr/bin/vncserver -kill %i > /dev/null 2>&1 || :'
ExecStart=/sbin/runuser -l mgw -c \"/usr/bin/vncserver %i -extension RANDR -geometry 1366x768\"
PIDFile=~mgw/.vnc/%H%i.pid
ExecStop=/bin/sh -c '/usr/bin/vncserver -kill %i > /dev/null 2>&1 || :'

[Install]
WantedBy=multi-user.target
" > $vnc_conf
chmod a+x $vnc_conf


#Step 4: Set the desktop enviroment

xstartupContent='#!/bin/sh
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
vncconfig -iconic &
xterm -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
twm &
'


#Write configuration to files and backup files

vnc_desktop_conf=~mgw/.vnc/xstartup
vnc_desktop_conf_backup=$vnc_desktop_conf.vncconfig.$currentTimestamp
if [ -f "$vnc_desktop_conf" ]; then
    echo backup $vnc_desktop_conf to $vnc_desktop_conf_backup
    cp $vnc_desktop_conf $vnc_desktop_conf_backup
fi
echo "$xstartupContent" > $vnc_desktop_conf
chmod 755 $vnc_desktop_conf



#Step5:Start the VNC service
#Start the VNC service
systemctl daemon-reload

systemctl enable vncserver@:${sessions[0]}.service
systemctl start vncserver@:${sessions[0]}.service


#Step6: If default firewall is used, we will open the VNC ports

echo "Open the ports in firewall"
currentZone=`firewall-cmd --get-active-zone|head -1`

firewall-cmd --permanent --zone=$currentZone --add-port=${ports[0]}/tcp

firewall-cmd --reload


#Step7: Echo the information that VNC client can connect to

red='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${red}Display number for user mgw is ${sessions[0]}${NC}"
