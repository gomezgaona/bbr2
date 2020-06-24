#!/bin/bash
BDP=(0.01 0.1 1 10 100)
rm out_f
echo "Running aggregator"
i=0
while [ $i -lt "${#BDP[@]}" ]; do
	j=1
	echo "Buffer size = ${BDP[$i]}BDP"
	while [ $j -le 10 ]; do
		echo -e "\tRun: $j"
		k=1
		while [ $k -le 100 ]; do
			f1="/home/Test_Results/h_${BDP[$i]}_${j}_${k}/out.json"
			res1=`jq '.end.sum_sent.bits_per_second' $f1`	
			printf "${BDP[$i]},$j,$k,$res1" >> out_f
			printf "\n" >> out_f
			k=`expr $k + 1`
		done
		j=`expr $j + 1`	
	done
	i=`expr $i + 1`
done
cp out_f /home/research/Desktop/out.csv
