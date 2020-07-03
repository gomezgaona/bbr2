#!/bin/bash
sudo tc qdisc del dev s1-eth1 root 2> /dev/null
sudo tc qdisc add dev s1-eth1 root handle 1: netem delay 20ms 

sudo tc qdisc del dev s2-eth2 root 2> /dev/null
sudo tc qdisc add dev s2-eth2 root handle 1: tbf rate 1gbit burst 500000 limit 2500000
sudo tc qdisc add dev s2-eth2 parent 1: handle 2: fq_codel

rm -rf /home/Test_Results/
mkdir -p /home/Test_Results/ && cd /home/Test_Results/
sudo pkill iperf3
#Disabling GRO
sudo ethtool -K s1-eth1 gro off
sudo ethtool -K s1-eth2 gro on
sudo ethtool -K s2-eth1 gro on
sudo ethtool -K s2-eth2 gro on
sudo ethtool -K s3-eth1 gro on
sudo ethtool -K s3-eth2 gro on
sudo /home/research/mininet/util/m h1 ethtool -K h1-eth0 gro on
sudo /home/research/mininet/util/m h2 ethtool -K h2-eth0 gro on

echo "Setting hosts"

i=1
while [ $i -le 100 ]; do
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
	sudo /home/research/mininet/util/m "h$i" tc qdisc del dev "h$i-eth0" root 2> /dev/null
	if [ $i -le 50 ]; then
		/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null
	else
		/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=bbr > /dev/null
	fi
	i=`expr $i + 1`
done
i=101
while [ $i -le 200 ]; do
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
	if [ $i -le 150 ]; then
		/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null
	else
		/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=bbr > /dev/null
	fi
	/home/research/mininet/util/m "h$i" iperf3 -s > /dev/null &
	i=`expr $i + 1`
done

echo "Running main script"
limit=(262144 524288 786432 1048576 1310720 1572864 1835008 2097152 2359296 2621440 5242880 7864320 10485760 13107200 15728640 18350080 20971520 23592960 26214400 52428800 78643200 104857600 131072000 157286400 183500800 209715200 235929600 262144000)
BDP=(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 2 3 4 5 6 7 8 9 10 20 30 40 50 60 70 80 90 100)
i=0
while [ $i -lt "${#limit[@]}" ]; do
	j=1
	sudo tc qdisc change dev s2-eth2 root handle 1: tbf rate 1gbit burst 500000 limit ${limit[$i]}
	echo "Buffer size = ${BDP[$i]}BDP"
	while [ $j -le 10 ]; do
		echo -e "\tRun: $j"
		k=1
		while [ $k -le 50 ]; do
			mkdir "h1_${BDP[$i]}_${j}_${k}"
			mkdir "h2_${BDP[$i]}_${j}_${k}"
			/home/research/mininet/util/m "h$k" iperf3 -c "10.0.0.$(($k+100))" -t 120 -J > "h1_${BDP[$i]}_${j}_${k}/out.json"&
			/home/research/mininet/util/m "h$(($k+50))" iperf3 -c "10.0.0.$(($k+150))" -t 120 -J > "h2_${BDP[$i]}_${j}_${k}/out.json"&
			k=`expr $k + 1`
		done
		sleep 150
		j=`expr $j + 1`
	done
	i=`expr $i + 1`
done
sudo /home/research/BBR2_new/Figure_9/aggregator.sh
