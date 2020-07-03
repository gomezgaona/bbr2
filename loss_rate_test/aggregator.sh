#!/bin/bash

i=0
loss=(0.0001 0.001 0.01 0.1 1 10 20)
cd "/home/Test_Results/"
rm retrans_out
echo "RUnning aggregator"
while [ $i -lt "${#loss[@]}" ]; do
	retrans_out=0	
	j=1
	echo "Loss Rate = ${loss[$i]}% "
	while [ $j -le 10 ]; do
		echo -e "\tRun: $j"
		printf "${loss[$i]},$j," >> retrans_out
		f1="/home/Test_Results/h_${loss[$i]}_${j}/out.json"
		res1=`jq '.end.sum_sent.retransmits' $f1`
		res2=`jq '.end.sum_sent.bits_per_second' $f1`
		res3=`jq '.end.sum_sent.bytes' $f1`
		printf "$res1,$res2,$res3" >> retrans_out	
		printf "\n" >> retrans_out
		j=`expr $j + 1`
	done
	i=`expr $i + 1`
done
echo "Done!"
cp retrans_out /home/research/Desktop/retrans_out.csv
