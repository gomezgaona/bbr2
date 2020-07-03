#!/bin/bash

i=0
#limit=(262144 524288 786432 1048576 1310720 1572864 1835008 2097152 2359296 2621440 5242880 7864320 10485760 13107200 15728640 18350080 20971520 23592960 26214400 52428800 78643200 104857600 131072000 157286400 183500800 209715200 235929600 262144000)
limit=(625000 1250000 1875000 2500000 3125000 3750000 4375000 5000000 5625000 6250000 12500000 18750000 25000000 31250000 37500000 43750000 50000000 56250000 62500000 125000000 187500000 250000000 312500000 375000000 437500000 500000000 562500000 625000000)
cd "/home/Test_Results/"
rm retrans_out
echo "Running aggregator"
while [ $i -lt "${#limit[@]}" ]; do
	retrans_out=0	
	j=1
	echo "Buffer size = ${limit[$i]}[bytes] "
	while [ $j -le 1 ]; do
		echo -e "\tRun: $j"
		#printf "${limit[$i]},$j," >> retrans_out
		f1="/home/Test_Results/avg_retr_rate_${limit[$i]}"
		retrans1=`cat $f1`
		printf "$retrans1" >> retrans_out
		printf "\n" >> retrans_out
		j=`expr $j + 1`
	done
	i=`expr $i + 1`
done
echo "Done!"
cp retrans_out /home/research/Desktop/retrans_out.csv
