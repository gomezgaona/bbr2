#!/bin/bash
limit=(250000 2500000 25000000 250000000)
rm out_f
echo "Running aggregator"
i=0
while [ $i -lt "${#limit[@]}" ]; do
	j=1
	echo "BDP = ${limit[$i]}"
	while [ $j -le 10 ]; do
		echo -e "\tRun: $j"
		k=1
		while [ $k -le 10 ]; do
			f1="/home/Test_Results/h1_${limit[$i]}_${j}_${k}/out.json"
			f2="/home/Test_Results/h2_${limit[$i]}_${j}/out.json"
			res1=`jq '.end.sum_sent.bits_per_second' $f1`	
			res2=`jq '.end.sum_sent.bits_per_second' $f2`	
			printf "$j,${limit[$i]},$res1,$res2," >> out_f
			printf "\n" >> out_f
			k=`expr $k + 1`
		done
		j=`expr $j + 1`	
	done
	i=`expr $i + 1`
done
cp out_f /home/research/Desktop/out.csv
