#!/bin/sh
echo "
1 7 * * *       root     /bin/bash /home/mwg/dailycheck/dailycheck.sh
" >> /etc/crontab
