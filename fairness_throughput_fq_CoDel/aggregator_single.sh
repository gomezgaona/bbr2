#!/bin/bash
BDP=(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 2 3 4 5 6 7 8 9 10 20 30 40 50 60 70 80 90 100)
rm out_f
echo "Running aggregator"
i=0
while [ $i -lt "${#BDP[@]}" ]; do
	j=1
	echo "BDP = ${BDP[$i]}"
	while [ $j -le 10 ]; do
		echo -e "\tRun: $j"
		f1="/home/Test_Results/h1_${BDP[$i]}_${j}/out.json"
		f2="/home/Test_Results/h2_${BDP[$i]}_${j}/out.json"
		res1=`jq '.end.sum_sent.bits_per_second' $f1`	
		res2=`jq '.end.sum_sent.bits_per_second' $f2`	
		printf "$j,${BDP[$i]},$res1,$res2," >> out_f
		printf "\n" >> out_f
		j=`expr $j + 1`	
	done
	i=`expr $i + 1`
done
cp out_f /home/research/Desktop/out.csv
