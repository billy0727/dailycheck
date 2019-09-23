#! /bin/bash
for((i=22; i>=1;i--))
do
        sudo sed -i s/"d'1"/"d'${i}"/ dailycheck.sh
        sudo bash dailycheck.sh
        sudo sed -i s/"d'${i}"/"d'1"/ dailycheck.sh
done
