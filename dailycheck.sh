#! /bin/bash
# dailycheck.sh (/home/mwg/dailycheck/temp.txt, /home/mwg/dailycheck/node_temp.txt /tmp/ must exist)
# All nodes check by sensor_engine.log and set in the crontab 
# Billy Hsia
# fuction: calulate yesterday u3(avg,sd), u4(avg,sd), LQI(avg,sd), n2(avg,sd)
# add command as follow in /etc/crontab 
# 1 7 * * *       root     /bin/bash /home/mwg/dailycheck/dailycheck.sh

# clean temp files
mkdir -p /home/mwg/dailycheck/tmp
> /home/mwg/dailycheck/tmp/lqi_avg_temp.tmp
> /home/mwg/dailycheck/tmp/lqi_sd_temp.tmp
> /home/mwg/dailycheck/tmp/dataloss_temp.tmp
> /home/mwg/dailycheck/tmp/u3_temp.tmp
> /home/mwg/dailycheck/tmp/u4_temp.tmp
> /home/mwg/dailycheck/tmp/u22_temp.tmp
> /home/mwg/dailycheck/tmp/mac.tmp

today=$(date -d'1 days ago' '+%m-%d')
echo "${today}" >> /home/mwg/dailycheck/temp.txt


#u3
#cat sensor_engine.log |grep -a Debug |grep -a ${today} |grep -a u3, |wc -l >> /home/mwg/dailycheck/temp.txt
#u4
#cat sensor_engine.log |grep -a Debug |grep -a ${today} |grep -a u4, |wc -l >> /home/mwg/dailycheck/temp.txt


# clean temp files
#> lqi_avg_temp.txt
#> lqi_sd_temp.txt
#> dataloss_temp.txt

# AVG(nodes), SD(nodes)
#macstxt=$(cat /opt/mwg/macs.txt |grep -a Add |awk '{$1=null ;print}')
#macstxt="0109D641 0109D625"

echo "select pad_mac from beds where resident_id is not NULL" |mysql -u root -pbds316 gv > /home/mwg/dailycheck/macs.txt
sed -i '1d' /home/mwg/dailycheck/macs.txt
macstxt=$(cat /home/mwg/dailycheck/macs.txt)


for node in $macstxt 
do
  echo "${node}" >> /home/mwg/dailycheck/tmp/mac.tmp
  echo "${node}" >> /home/mwg/dailycheck/node_temp.txt
  echo "${today}" >> /home/mwg/dailycheck/node_temp.txt
  #u3
  u3=$(cat /var/log/sensor_engine.log |grep -a Debug |grep -a ${today} |grep -a u3,${node} |wc -l)
  echo ${u3} >> /home/mwg/dailycheck/tmp/u3_temp.tmp
  echo ${u3} >> /home/mwg/dailycheck/node_temp.txt
  #u4
  u4=$(cat /var/log/sensor_engine.log |grep -a Debug |grep -a ${today} |grep -a u4,${node} |wc -l)
  echo ${u4} >> /home/mwg/dailycheck/tmp/u4_temp.tmp
  echo ${u4} >> /home/mwg/dailycheck/node_temp.txt
  #u22
  u22=$(cat /var/log/sensor_engine.log |grep -a Debug |grep -a ${today} |grep -a u22,${node} |wc -l)
  echo ${u22} >> /home/mwg/dailycheck/tmp/u22_temp.tmp
  echo ${u22} >> /home/mwg/dailycheck/node_temp.txt
  #lqi avg,sd
  cat /var/log/sensor_engine.log |grep -a Debug |grep -a ${today} |grep -a n2,${node} |cut -d , -f 4 > /home/mwg/dailycheck/tmp/lqi_data.tmp
  lqi_avg=$(cat /home/mwg/dailycheck/tmp/lqi_data.tmp | awk '{sum+=$1} END {print sum/NR}')
  echo ${lqi_avg} >> /home/mwg/dailycheck/tmp/lqi_avg_temp.tmp
  echo ${lqi_avg} >> /home/mwg/dailycheck/node_temp.txt
  lqi_sd=$(cat /home/mwg/dailycheck/tmp/lqi_data.tmp | awk '{x[NR]=$0; s+=$0; n++} END{a=s/n; for (i in x){ss += (x[i]-a)^2} sd = sqrt(ss/n); print sd}')
  echo ${lqi_sd} >> /home/mwg/dailycheck/tmp/lqi_sd_temp.tmp
  echo ${lqi_sd} >> /home/mwg/dailycheck/node_temp.txt
  #n2(dataloss)
  n2=$(cat /home/mwg/dailycheck/tmp/lqi_data.tmp | wc -l)
  echo ${n2} >> /home/mwg/dailycheck/tmp/dataloss_temp.tmp
  echo ${n2} >> /home/mwg/dailycheck/node_temp.txt
done

# AVG,SD(u3,u4)
cat /home/mwg/dailycheck/tmp/u3_temp.tmp | awk '{sum+=$1} END {print sum/NR}' >> /home/mwg/dailycheck/temp.txt
cat /home/mwg/dailycheck/tmp/u3_temp.tmp | awk '{x[NR]=$0; s+=$0; n++} END{a=s/n; for (i in x){ss += (x[i]-a)^2} sd = sqrt(ss/n); print sd}' >> /home/mwg/dailycheck/temp.txt
cat /home/mwg/dailycheck/tmp/u4_temp.tmp | awk '{sum+=$1} END {print sum/NR}' >> /home/mwg/dailycheck/temp.txt
cat /home/mwg/dailycheck/tmp/u4_temp.tmp | awk '{x[NR]=$0; s+=$0; n++} END{a=s/n; for (i in x){ss += (x[i]-a)^2} sd = sqrt(ss/n); print sd}' >> /home/mwg/dailycheck/temp.txt
cat /home/mwg/dailycheck/tmp/u22_temp.tmp | awk '{sum+=$1} END {print sum/NR}' >> /home/mwg/dailycheck/temp.txt
cat /home/mwg/dailycheck/tmp/u22_temp.tmp | awk '{x[NR]=$0; s+=$0; n++} END{a=s/n; for (i in x){ss += (x[i]-a)^2} sd = sqrt(ss/n); print sd}' >> /home/mwg/dailycheck/temp.txt

# AVG(nodes avg and sd) 
cat /home/mwg/dailycheck/tmp/lqi_avg_temp.tmp | awk '{sum+=$1} END {print sum/NR}' >> /home/mwg/dailycheck/temp.txt
cat /home/mwg/dailycheck/tmp/lqi_sd_temp.tmp | awk '{sum+=$1} END {print sum/NR}' >> /home/mwg/dailycheck/temp.txt

# n2() and dataloss%()
cat /home/mwg/dailycheck/tmp/dataloss_temp.tmp | awk '{sum+=$1} END {print sum/NR}' >> /home/mwg/dailycheck/temp.txt
cat /home/mwg/dailycheck/tmp/dataloss_temp.tmp | awk '{x[NR]=$0; s+=$0; n++} END{a=s/n; for (i in x){ss += (x[i]-a)^2} sd = sqrt(ss/n); print sd}' >> /home/mwg/dailycheck/temp.txt

#Reports Collection
printf '%2s\t %8s\t %8s\t %8s\t %8s\t %8s\t %8s\t %8s\t %8s\t %8s\t %8s\t \n' $(cat /home/mwg/dailycheck/temp.txt) > /home/mwg/dailycheck/report
printf '%8s\t %8s\t %8s\t %8s\t %8s\t %8s\t %8s\t %8s\t \n' $(cat /home/mwg/dailycheck/node_temp.txt) > /home/mwg/dailycheck/nodereport
cp /home/mwg/dailycheck/report /home/mwg/gv-admin/public
cp /home/mwg/dailycheck/nodereport /home/mwg/gv-admin/public
#cat report.txt
#echo ""
#cat node_report.txt

#each_node_report_by node_report.txt
file=/home/mwg/dailycheck/tmp/mac.tmp
seq=1
while read line;
do
    cat /home/mwg/dailycheck/nodereport |grep -a -e Node -e ${line} > /home/mwg/dailycheck/${line}
    cp /home/mwg/dailycheck/${line} /home/mwg/gv-admin/public
done < $file
