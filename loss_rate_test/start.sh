#!/bin/bash
i=0

sudo tc qdisc del dev s1-eth1 root 2> /dev/null
sudo tc qdisc add dev s1-eth1 root handle 1: netem delay 20ms 

sudo tc qdisc del dev s2-eth2 root 2> /dev/null
sudo tc qdisc add dev s2-eth2 root handle 1: tbf rate 1gbit burst 500000 limit 250000

rm -rf /home/Test_Results/
mkdir -p /home/Test_Results/ && cd /home/Test_Results/
sudo pkill iperf3
#Disabling GRO
sudo ethtool -K s1-eth1 gro off

echo "Setting hosts"

/home/research/mininet/util/m h1 sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
/home/research/mininet/util/m h1 sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
sudo /home/research/mininet/util/m h1 tc qdisc del dev h1-eth0 root 2> /dev/null
/home/research/mininet/util/m h1 sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null

/home/research/mininet/util/m h2 sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
/home/research/mininet/util/m h2 sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
/home/research/mininet/util/m h2 sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null
/home/research/mininet/util/m h2 iperf3 -s > /dev/null &

echo "Running main script"
loss=(0.0001 0.001 0.01 0.1 1 10 20)
i=0
while [ $i -lt "${#loss[@]}" ]; do
	j=1
	sudo tc qdisc change dev s1-eth1 root handle 1: netem delay 20ms loss "${loss[$i]}"
	echo "Loss rate: ${loss[$i]}%"
	while [ $j -le 10 ]; do
		echo -e "\tRun: $j"
		mkdir "h_${loss[$i]}_${j}"
		/home/research/mininet/util/m h1 iperf3 -c 10.0.0.2 -t 120 -J > "h_${loss[$i]}_${j}/out.json"
		j=`expr $j + 1`
		sleep 10
	done
	i=`expr $i + 1`
done
sudo /home/research/BBR2_new/Figure_8/aggregator.sh
