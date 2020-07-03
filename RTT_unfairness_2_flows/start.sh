#!/bin/bash

limit=(262144 524288 786432 1048576 1310720 1572864 1835008 2097152 2359296 2621440 5242880 7864320 10485760 13107200 15728640 18350080 20971520 23592960 26214400 52428800 78643200 104857600 131072000 157286400 183500800 209715200 235929600 262144000)

BDP=(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 2 3 4 5 6 7 8 9 10 20 30 40 50 60 70 80 90 100)

sudo tc qdisc del dev s1-eth1 root 2> /dev/null
sudo tc qdisc add dev s1-eth1 root handle 1: netem delay 20ms 

sudo tc qdisc del dev s2-eth2 root 2> /dev/null
sudo tc qdisc add dev s2-eth2 root handle 1: tbf rate 1gbit burst 500000 limit 2621440
#sudo tc qdisc add dev s2-eth2 parent 1: handle 2: fq_codel

rm -rf /home/Test_Results/
mkdir -p /home/Test_Results/ && cd /home/Test_Results/

sudo /home/research/mininet/util/m h1 tc qdisc del dev h1-eth0 root 2> /dev/null
sudo /home/research/mininet/util/m h2 tc qdisc del dev h2-eth0 root 2> /dev/null
sudo /home/research/mininet/util/m h3 tc qdisc del dev h1-eth0 root 2> /dev/null
sudo /home/research/mininet/util/m h4 tc qdisc del dev h2-eth0 root 2> /dev/null

/home/research/mininet/util/m h1 sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
/home/research/mininet/util/m h1 sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
/home/research/mininet/util/m h2 sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
/home/research/mininet/util/m h2 sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
/home/research/mininet/util/m h3 sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
/home/research/mininet/util/m h3 sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
/home/research/mininet/util/m h4 sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
/home/research/mininet/util/m h4 sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null

/home/research/mininet/util/m h1 sysctl -w net.ipv4.tcp_congestion_control=bbr > /dev/null
/home/research/mininet/util/m h2 sysctl -w net.ipv4.tcp_congestion_control=bbr > /dev/null
/home/research/mininet/util/m h3 sysctl -w net.ipv4.tcp_congestion_control=bbr > /dev/null
/home/research/mininet/util/m h4 sysctl -w net.ipv4.tcp_congestion_control=bbr > /dev/null

sudo /home/research/mininet/util/m h1 tc qdisc add dev h1-eth0 root netem delay 10ms
sudo /home/research/mininet/util/m h2 tc qdisc add dev h2-eth0 root netem delay 50ms

sudo pkill iperf3
/home/research/mininet/util/m h3 iperf3 -s > /dev/null &
/home/research/mininet/util/m h4 iperf3 -s > /dev/null &

echo "Running iperf3 tests"
i=0
while [ $i -lt "${#limit[@]}" ]; do
	echo "Buffer size = ${BDP[$i]} BDP"
	sudo tc qdisc change dev s2-eth2 root handle 1: tbf rate 1gbit burst 500000 limit "${limit[$i]}"
	j=1
	while [ $j -le 10 ]; do
		mkdir "h1_${BDP[$i]}_${j}"
		mkdir "h2_${BDP[$i]}_${j}"
		/home/research/mininet/util/m h1 iperf3 -c 10.0.0.3 -t 120 -J > "h1_${BDP[$i]}_${j}/out.json"&
		/home/research/mininet/util/m h2 iperf3 -c 10.0.0.4 -t 120 -J > "h2_${BDP[$i]}_${j}/out.json"
		j=`expr $j + 1`
	done
	i=`expr $i + 1`
done
sudo /home/research/