#!/bin/bash
i=0
#0.1BDP
#limit=(26214 52429 78643 104858 131072 52429 104858 157286 209715 262144 78643 157286 235930 314573 393216 104858 209715 314573 419430 524288 131072 262144 393216 524288 655360 262144 524288 786432 1048576 1310720 524288 1048576 1572864 2097152 2621440 786432 1572864 2359296 3145728 3932160 1048576 2097152 3145728 4194304 5242880 1310720 2621440 3932160 5242880 6553600 2621440 5242880 7864320 10485760 13107200 5242880 10485760 15728640 20971520 26214400 7864320 15728640 23592960 31457280 39321600 10485760 20971520 31457280 41943040 52428800 13107200 26214400 39321600 52428800 65536000)
#1BDP
#limit=(262144 524288 786432 1048576 1310720 524288 1048576 1572864 2097152 2621440 786432 1572864 2359296 3145728 3932160 1048576 2097152 3145728 4194304 5242880 1310720 2621440 3932160 5242880 6553600 2621440 5242880 7864320 10485760 13107200 5242880 10485760 15728640 20971520 26214400 7864320 15728640 23592960 31457280 39321600 10485760 20971520 31457280 41943040 52428800 13107200 26214400 39321600 52428800 65536000 26214400 52428800 78643200 104857600 131072000 52428800 104857600 157286400 209715200 262144000 78643200 157286400 235929600 314572800 393216000 104857600 209715200 314572800 419430400 524288000 131072000 262144000 393216000 524288000 655360000)
#10BDP
#limit=(2621440 5242880 7864320 10485760 13107200 5242880 10485760 15728640 20971520 26214400 7864320 15728640 23592960 31457280 39321600 10485760 20971520 31457280 41943040 52428800 13107200 26214400 39321600 52428800 65536000 26214400 52428800 78643200 104857600 131072000 52428800 104857600 157286400 209715200 262144000 78643200 157286400 235929600 314572800 393216000 104857600 209715200 314572800 419430400 524288000 131072000 262144000 393216000 524288000 655360000 262144000 524288000 786432000 1048576000 1310720000 524288000 1048576000 1572864000 2097152000 2621440000 786432000 1572864000 2359296000 3145728000 3932160000 1048576000 2097152000 3145728000 4194304000 5242880000 1310720000 2621440000 3932160000 5242880000 6553600000)

burst=(10000 20000 30000 40000 50000 100000 200000 300000 400000 500000 1000000 2000000 3000000 4000000 5000000)
x_RTT=(100 200 300 400 500)
y_BW=(20 40 60 80 100 200 400 600 800 1000 2000 4000 6000 8000 10000)

sudo tc qdisc del dev s1-eth1 root 2> /dev/null
sudo tc qdisc add dev s1-eth1 root handle 1: netem delay "${x_RTT[1]}"ms #loss 1%

sudo tc qdisc del dev s2-eth2 root 2> /dev/null
sudo tc qdisc add dev s2-eth2 root handle 1: tbf rate 1gbit burst 500000 limit "${limit[1]}"
#sudo tc qdisc add dev s2-eth2 parent 1: handle 2: fq_codel

rm -rf /home/Test_Results/
mkdir -p /home/Test_Results/ && cd /home/Test_Results/

i=1
while [ $i -le 2 ]; do
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
	sudo /home/research/mininet/util/m "h$i" tc qdisc del dev "h$i-eth0" root 2> /dev/null
	#sudo /home/research/mininet/util/m "h$i" tc qdisc add dev "h$i-eth0" root fq pacing maxrate 9.4mbit

	if [ $i -le 1 ]; then
		/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null
		#sudo /home/research/mininet/util/m "h$i" tc qdisc add dev h"$i"-eth0 root netem delay 10ms
	elif [ $i -le 2 ]; then
		/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=bbr2 > /dev/null
		#sudo /home/research/mininet/util/m "h$i" tc qdisc add dev h"$i"-eth0 root netem delay 50ms
	fi
	i=`expr $i + 1`
done
i=101
while [ $i -le 102 ]; do
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
	/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
	if [ $i -le 101 ]; then
		/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null
	elif [ $i -le 102 ]; then
		/home/research/mininet/util/m "h$i" sysctl -w net.ipv4.tcp_congestion_control=bbr2 > /dev/null
	fi
	/home/research/mininet/util/m "h$i" iperf3 -s > /dev/null &

	i=`expr $i + 1`
done

echo "Running main script"
i=0
m=0
while [ $m -lt "${#y_BW[@]}" ]; do
	n=0
	while [ $n -lt "${#x_RTT[@]}" ]; do
		echo "RTT = ${y_BW[$m]}Mbps"
		echo "BW = ${x_RTT[$n]}ms"
		sudo tc qdisc change dev s1-eth1 root handle 1: netem delay "${x_RTT[$n]}ms" #loss 1%
		sudo tc qdisc change dev s2-eth2 root handle 1: tbf rate "${y_BW[$m]}mbit" burst "${burst[$m]}" limit "${limit[$i]}"
		sleep 10
		j=1
		while [ $j -le 5 ]; do
			k=1
			echo -e "\t Run #: $j"
			while [ $k -le 2 ]; do
				mkdir "h_${m}_${n}_${j}_${k}"
				/home/research/mininet/util/m "h$k" iperf3 -c "10.0.0.$(($k+100))" -t 120 -J > "h_${m}_${n}_${j}_${k}/out.json"&
				k=`expr $k + 1`
			done
			sleep 140
			j=`expr $j + 1`
		done
		i=`expr $i + 1`
		echo -e "\tLimit index=$i"
		n=`expr $n + 1`
	done
	m=`expr $m + 1`
done
sudo /home/research/BBR2_new/heat_map_complementary_script/2flows/aggregator.sh