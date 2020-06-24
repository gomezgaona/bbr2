#!/bin/bash
sudo tc qdisc del dev s1-eth1 root 2> /dev/null
sudo tc qdisc add dev s1-eth1 root handle 1: netem delay 20ms 

sudo tc qdisc del dev s2-eth2 root 2> /dev/null
sudo tc qdisc add dev s2-eth2 root handle 1: tbf rate 1gbit burst 500000 limit 2621440

rm -rf /home/Test_Results/
mkdir -p /home/Test_Results/ && cd /home/Test_Results/
sudo pkill iperf3
echo "Setting hosts"

i=1
while [ $i -le 100 ]; do
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
	sudo /home/research/mininet/util/m "h$i" tc qdisc del dev "h$i-eth0" root 2> /dev/null
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null
	i=`expr $i + 1`
done
i=101
while [ $i -le 200 ]; do
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null
	/home/research/mininet/util/m "h$i" iperf3 -s > /dev/null &
	i=`expr $i + 1`
done

limit=(26214 262144 2621440 26214400 262144000)
BDP=(0.01 0.1 1 10 100)
i=0

echo "Running main script"
while [ $i -lt "${#limit[@]}" ]; do
	j=1
	sudo tc qdisc change dev s2-eth2 root handle 1: tbf rate 1gbit burst 500000 limit ${limit[$i]}
	sleep 10
	echo "Buffer size = ${BDP[$i]}BDP"
	while [ $j -le 10 ]; do
		echo -e "\tRun: $j"
		k=1
		while [ $k -le 100 ]; do
			mkdir "h_${BDP[$i]}_${j}_${k}"
			/home/research/mininet/util/m "h$k" iperf3 -c "10.0.0.$(($k+100))" -t 120 -J > "h_${BDP[$i]}_${j}_${k}/out.json"&
			k=`expr $k + 1`
		done
		sleep 130
		j=`expr $j + 1`
	done
	i=`expr $i + 1`
done
sudo /home/research/BBR2_new/link_util/aggregator.sh
