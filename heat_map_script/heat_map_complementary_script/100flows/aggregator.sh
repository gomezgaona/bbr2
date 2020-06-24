#!/bin/bash
cd "/home/Test_Results/"
rm tput_out
echo "Running aggregator"
x_RTT=(100 200 300 400 500)
y_BW=(20 40 60 80 100 200 400 600 800 1000 2000 4000 6000 8000 10000)
m=0
i=0
while [ $m -lt "${#y_BW[@]}" ]; do
	n=0
	while [ $n -lt "${#x_RTT[@]}" ]; do
		echo "RTT = ${y_BW[$m]}ms"
		echo "BW = ${x_RTT[$n]}Mbps"
		j=1
		while [ $j -le 5 ]; do
			k=1
			echo -e "\t Run #: $j"
			while [ $k -le 100 ]; do
				f1="/home/Test_Results/h_${m}_${n}_${j}_${k}/out.json"
				tput=`jq '.end.sum_sent.bits_per_second' $f1`
				printf "$i,$m,$n,$j,$k,$tput" >> tput_out	
				printf "\n" >> tput_out
				k=`expr $k + 1`
			done
			j=`expr $j + 1`
		done
		i=`expr $i + 1`
		echo -e "\tLimit index=$i"
		n=`expr $n + 1`
	done
	m=`expr $m + 1`
done
echo "Done!"
cp tput_out /home/research/Desktop/tput_out.csv
