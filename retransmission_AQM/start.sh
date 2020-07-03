#!/bin/bash
i=0

sudo tc qdisc del dev s1-eth1 root 2> /dev/null
#sudo tc qdisc add dev s1-eth1 root handle 1: netem delay 20ms 

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

/home/research/mininet/util/m h1 sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
/home/research/mininet/util/m h1 sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
sudo /home/research/mininet/util/m h1 tc qdisc del dev h1-eth0 root 2> /dev/null
/home/research/mininet/util/m h1 sysctl -w net.ipv4.tcp_congestion_control=bbr2 > /dev/null
sudo /home/research/mininet/util/m h1 tc qdisc add dev h1-eth0 root netem delay 10ms


/home/research/mininet/util/m h2 sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
/home/research/mininet/util/m h2 sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
sudo /home/research/mininet/util/m h2 tc qdisc del dev h2-eth0 root 2> /dev/null
/home/research/mininet/util/m h2 sysctl -w net.ipv4.tcp_congestion_control=bbr2 > /dev/null
sudo /home/research/mininet/util/m h2 tc qdisc add dev h2-eth0 root netem delay 50ms

/home/research/mininet/util/m h3 sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
/home/research/mininet/util/m h3 sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
/home/research/mininet/util/m h3 sysctl -w net.ipv4.tcp_congestion_control=bbr2 > /dev/null
/home/research/mininet/util/m h3 iperf3 -s > /dev/null &

/home/research/mininet/util/m h4 sysctl -w net.ipv4.tcp_wmem=\"10240 87380 1310720000\" > /dev/null
/home/research/mininet/util/m h4 sysctl -w net.ipv4.tcp_rmem=\"10240 87380 1310720000\" > /dev/null
/home/research/mininet/util/m h4 sysctl -w net.ipv4.tcp_congestion_control=bbr2 > /dev/null
/home/research/mininet/util/m h4 iperf3 -s > /dev/null &

echo "Running main script"
#limit=(262144 524288 786432 1048576 1310720 1572864 1835008 2097152 2359296 2621440 5242880 7864320 10485760 13107200 15728640 18350080 20971520 23592960 26214400 52428800 78643200 104857600 131072000 157286400 183500800 209715200 235929600 262144000)
limit=(625000 1250000 1875000 2500000 3125000 3750000 4375000 5000000 5625000 6250000 12500000 18750000 25000000 31250000 37500000 43750000 50000000 56250000 62500000 125000000 187500000 250000000 312500000 375000000 437500000 500000000 562500000 625000000)
i=0
while [ $i -lt "${#limit[@]}" ]; do
	j=1
	sudo tc qdisc change dev s2-eth2 root handle 1: tbf rate 1gbit burst 500000 limit "${limit[$i]}"
	echo "Buffer size: ${limit[$i]}[bytes]"
	while [ $j -le 1 ]; do
	
		/home/research/mininet/util/m h1 netstat -s | grep 'segments retransmitted' | awk '{print $1}' > "before_seg_retr_${limit[$i]}_1"
		/home/research/mininet/util/m h1 netstat -s | grep 'segments sent out' | awk '{print $1}' > "before_seg_sent_${limit[$i]}_1"
		
		/home/research/mininet/util/m h2 netstat -s | grep 'segments retransmitted' | awk '{print $1}' > "before_seg_retr_${limit[$i]}_2"
		/home/research/mininet/util/m h2 netstat -s | grep 'segments sent out' | awk '{print $1}' > "before_seg_sent_${limit[$i]}_2"

		
		echo -e "\tRunlimit=(6250000): $j"
		mkdir "h_${limit[$i]}_${j}_1"
		mkdir "h_${limit[$i]}_${j}_2"
		/home/research/mininet/util/m h1 iperf3 -c 10.0.0.3 -t 120 -J > "h_${limit[$i]}_${j}_1/out.json"&
		/home/research/mininet/util/m h2 iperf3 -c 10.0.0.4 -t 120 -J > "h_${limit[$i]}_${j}_2/out.json"

		j=`expr $j + 1`
	done
	
	/home/research/mininet/util/m h1 netstat -s | grep 'segments retransmitted' | awk '{print $1}' > "after_seg_retr_${limit[$i]}_1"
	/home/research/mininet/util/m h1 netstat -s | grep 'segments sent out' | awk '{print $1}' > "after_seg_sent_${limit[$i]}_1"
	bef_ret=`cat "before_seg_retr_${limit[$i]}_1"`
	bef_sent=`cat "before_seg_sent_${limit[$i]}_1"`
	after_ret=`cat "after_seg_retr_${limit[$i]}_1"`
	after_sent=`cat "after_seg_sent_${limit[$i]}_1"`
	echo "($after_ret - $bef_ret) / ($after_sent - $bef_sent) * 100" | bc -l >> "retr_rate_${limit[$i]}_1"
	
	/home/research/mininet/util/m h2 netstat -s | grep 'segments retransmitted' | awk '{print $1}' > "after_seg_retr_${limit[$i]}_2"
	/home/research/mininet/util/m h2 netstat -s | grep 'segments sent out' | awk '{print $1}' > "after_seg_sent_${limit[$i]}_2"
	bef_ret=`cat "before_seg_retr_${limit[$i]}_2"`
	bef_sent=`cat "before_seg_sent_${limit[$i]}_2"`
	after_ret=`cat "after_seg_retr_${limit[$i]}_2"`
	after_sent=`cat "after_seg_sent_${limit[$i]}_2"`
	echo "($after_ret - $bef_ret) / ($after_sent - $bef_sent) * 100" | bc -l >> "retr_rate_${limit[$i]}_2"
	echo "(`cat retr_rate_${limit[$i]}_1` + `cat retr_rate_${limit[$i]}_2`)/2.0" | bc -l >> "avg_retr_rate_${limit[$i]}"
	i=`expr $i + 1`
done
echo "Done"
#i=`expr $i - 1`
#cp "avg_retr_rate_${limit[$i]}"  /home/research/Desktop/"bbr_${limit[$i]}"
sudo /home/research/BBR2_new/Figure_11/aggregator.sh
