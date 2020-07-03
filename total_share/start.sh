#!/bin/bash
i=0

sudo tc qdisc del dev s1-eth1 root 2> /dev/null
sudo tc qdisc add dev s1-eth1 root handle 1: netem delay 20ms 

sudo tc qdisc del dev s2-eth2 root 2> /dev/null
sudo tc qdisc add dev s2-eth2 root handle 1: tbf rate 1gbit burst 500000 limit 2621440
#sudo tc qdisc add dev s2-eth2 parent 1: handle 2: fq_codel

rm -rf /home/Test_Results/
mkdir -p /home/Test_Results/ && cd /home/Test_Results/

i=1
while [ $i -le 20 ]; do
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
	sudo /home/research/mininet/util/m "h$i" tc qdisc del dev "h$i-eth0" root 2> /dev/null
	if [ $i -le 10 ]; then
		/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null
	else
		/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=bbr2 > /dev/null
	fi
	i=`expr $i + 1`
done
i=21
while [ $i -le 40 ]; do
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null
	if [ $i -le 30 ]; then
		/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null
	else
		/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=bbr2 > /dev/null
	fi
	/home/research/mininet/util/m "h$i" iperf3 -s > /dev/null &
	i=`expr $i + 1`
done

echo "Running main script"
#echo "Buffer size = ${BDP[$i]}BDP"
cubic_flows=(1 2 3 4 5 6 7 8 9 10)
bbr2_flows=(1 2 3 5 10)
i=0
while [ $i -lt "${#cubic_flows[@]}" ]; do
	j=0
	while [ $j -lt "${#bbr2_flows[@]}" ]; do
		k=1
		while [ $k -le 10 ]; do
			echo "Cubic Flows: ${cubic_flows[$i]}, BBRv2 Flows: ${bbr2_flows[$j]}, Run: $k"
			m=1
			while [ $m -le 20 ]; do
				if [ $m -le "${cubic_flows[$i]}" ]; then
					mkdir "h1_${cubic_flows[$i]}_${bbr2_flows[j]}_${k}_${m}"
					/home/research/mininet/util/m "h$m" iperf3 -c "10.0.0.$(($m+20))" -t 120 -J > "h1_${cubic_flows[$i]}_${bbr2_flows[j]}_${k}_${m}/out.json"&
				fi
				if [ $m -le "${bbr2_flows[$j]}" ]; then
					mkdir "h2_${cubic_flows[$i]}_${bbr2_flows[j]}_${k}_${m}"
					/home/research/mininet/util/m "h$m" iperf3 -c "10.0.0.$(($m+30))" -t 120 -J > "h2_${cubic_flows[$i]}_${bbr2_flows[j]}_${k}_${m}/out.json"&
				fi
				m=`expr $m + 1`
			done
			sleep 130
			k=`expr $k + 1`
		done
		
		k=1
		while [ $k -le 10 ]; do
			m=1
			while [ $m -le 20 ]; do
				if [ $m -le "${cubic_flows[$i]}" ]; then
					cd "h1_${cubic_flows[$i]}_${bbr2_flows[j]}_${k}_${m}"
					plot_iperf.sh "out.json"
					cd ../
				fi
				if [ $m -le "${bbr2_flows[$j]}" ]; then
					cd "h2_${cubic_flows[$i]}_${bbr2_flows[j]}_${k}_${m}"
					plot_iperf.sh "out.json"
					cd ../
				fi
				m=`expr $m + 1`
			done
			k=`expr $k + 1`
		done
		j=`expr $j + 1`
	done
	i=`expr $i + 1`
done
sudo /home/research/pacing/Total_Share/aggregator.sh
