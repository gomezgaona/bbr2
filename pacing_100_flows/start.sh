#!/bin/bash

limit=(2500000 25000000 1250000000 2500000000)

BDP=(1 10 50 100)

sudo pkill iperf3 2> /dev/null

sudo tc qdisc del dev s1-eth1 root 2> /dev/null
sudo tc qdisc add dev s1-eth1 root handle 1: netem delay 20ms 2> /dev/null

sudo tc qdisc del dev s2-eth2 root 2> /dev/null
sudo tc qdisc add dev s2-eth2 root handle 1: tbf rate 1gbit burst 500000 limit 250000
#sudo tc qdisc add dev s2-eth2 parent 1: handle 2: fq_codel


rm -rf /home/Test_Results/
mkdir -p /home/Test_Results/ && cd /home/Test_Results/

i=1

echo "Starting Test"
while [ $i -le 100 ]; do
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
	sudo /home/research/mininet/util/m "h$i" tc qdisc del dev "h$i-eth0" root 2> /dev/null

	if [ $i -le 50 ]; then
		/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null
	elif [ $i -le 100 ]; then
		/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null
	fi
	i=`expr $i + 1`
done
i=101
while [ $i -le 200 ]; do
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
	if [ $i -le 150 ]; then
		/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null
	elif [ $i -le 200 ]; then
		/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null
	fi
	/home/research/mininet/util/m "h$i" iperf3 -s > /dev/null &

	i=`expr $i + 1`
done
echo "Congestion Control: CUBIC"
i=0
while [ $i -lt "${#limit[@]}" ]; do
	echo "Buffer Size = ${BDP[$i]}BDP = ${limit[$i]} Bytes"
	sudo tc qdisc change dev s2-eth2 root handle 1: tbf rate 1gbit burst 500000 limit "${limit[$i]}"
	j=1
	while [ $j -le 10 ]; do
		echo -e "\tRun: $j"
		k=1
		while [ $k -le 100 ]; do
			mkdir "h_${BDP[$i]}_${j}_${k}"
			/home/research/mininet/util/m "h$k" iperf3 -c "10.0.0.$(($k+100))" -t 120 -J > "h_${BDP[$i]}_${j}_${k}/out.json" &
			k=`expr $k + 1`
		done
	sleep 130
	j=`expr $j + 1`
	done
	j=1
	while [ $j -le 10 ]; do
		k=1
		while [ $k -le 100 ]; do
			cd "h_${BDP[$i]}_${j}_${k}"
			plot_iperf.sh "out.json"
			cd ../
			k=`expr $k + 1`
		done
		j=`expr $j + 1`
	done
	sleep 5
	i=`expr $i + 1`
done
echo "Done!"
sudo /home/research/pacing/RTT_BBR2_new/100_Flows_Individual_Hosts/aggregator.sh
