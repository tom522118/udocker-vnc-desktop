#!/bin/bash
# Command to run inside the udocker container
export PATH=/root/udocker_bin/udocker-1.3.17/udocker:$PATH
udocker --allow-root run --user=root --publish 6080:6080 vnc-desktop bash -c 'vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE && openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out self.pem -keyout self.pem && websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && tail -f /dev/null'
