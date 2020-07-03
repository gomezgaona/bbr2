#!/bin/bash
i=0

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
		/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=bbr2 > /dev/null
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
		/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=bbr2 > /dev/null
	fi
	/home/research/mininet/util/m "h$i" iperf3 -s > /dev/null &
	i=`expr $i + 1`
done

echo "Running main script"
limit=(250000 2500000 25000000 250000000)
cubic_flows=(1 10 10 50)
bbr2_flows=(1 1 10 50)
i=0
while [ $i -lt "${#limit[@]}" ]; do
	j=1
	sudo tc qdisc change dev s2-eth2 root handle 1: tbf rate 1gbit burst 500000 limit ${limit[$i]}
	echo "BDP = ${limit[$i]}"
	while [ $j -le 10 ]; do
		echo -e "\tRun: $j"
		k=1
		while [ $k -le 10 ]; do
			mkdir "h1_${limit[$i]}_${j}_${k}"
			/home/research/mininet/util/m h1 iperf3 -c "10.0.0.$(($k+100))" -t 120 -J > "h1_${limit[$i]}_${j}_${k}/out.json"&
			k=`expr $k + 1`
		done
		mkdir "h2_${limit[$i]}_${j}"
		/home/research/mininet/util/m h51 iperf3 -c 10.0.0.151 -t 120-J > "h2_${limit[$i]}_${j}/out.json"&
		sleep 150
		j=`expr $j + 1`
	done
	i=`expr $i + 1`
done
sudo /home/research/BBR2_new/Figure_15/aggregator.sh
