#!/bin/bash

i=0
flows=(1 10 25 50 75 100)
cd "/home/Test_Results/"
rm retrans_out
while [ $i -lt "${#flows[@]}" ]; do
	retrans_out=0	
	j=1
	echo "# of flows = ${flows[$i]}flows "
	while [ $j -le 10 ]; do
		k=1
		echo -e "\tRun: $j"
		while [ $k -le "${flows[$i]}" ]; do
			printf "${flows[$i]},$j,$k," >> retrans_out
			f1="/home/Test_Results/h_${flows[$i]}_${j}_${k}/out.json"
			res1=`jq '.end.sum_sent.retransmits' $f1`
			res2=`jq '.end.sum_sent.bytes' $f1`
			printf "$res1,$res2" >> retrans_out	
			printf "\n" >> retrans_out
			k=`expr $k + 1`
		done
		j=`expr $j + 1`
	done
	i=`expr $i + 1`
done
echo "Done!"
cp retrans_out /home/research/Desktop/retrans_out.csv
