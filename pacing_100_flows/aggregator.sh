#!/bin/bash
i=0
BDP=(1 10 50 100)
tputs=0
rtts=0
retrs=0
cwnds=0
#cd "/home/Test_Results/"
rm out_f
echo "Running Aggregator"
while [ $i -lt "${#BDP[@]}" ]; do
	echo "Buffer Size = ${BDP[$i]}BDP"
	j=1
	while [ $j -le 10 ]; do
		echo -e "\tRun: $j"
		k=1
		while [ $k -le 100 ]; do
			f="/home/Test_Results/h_${BDP[$i]}_${j}_${k}/results/1.dat"
			tputs=`cut -d " " -f 5 $f | paste -sd+ -| bc`
			rtts=`cut -d " " -f 8 $f | paste -sd+ - | bc`
			retrs=`cut -d " " -f 6 $f | paste -sd+ - | bc`
			cwnds=`cut -d " " -f 7 $f | paste -sd+ - | bc`
			avg_tput=0
			avg_rtts=0
			avg_retrs=0
			avg_cwnds=0
			avg_tput=`echo "scale=2;$tputs / 120.0" | bc` 
			avg_rtts=`echo "scale=2;$rtts / 120.0" | bc`
			avg_retrs=`echo "scale=2;$retrs / 120.0" | bc`
			avg_cwnds=`echo "scale=2;$cwnds / 120.0" | bc` 
			printf "${BDP[$i]},$k,$j,$avg_tput,$avg_rtts,$avg_retrs,$avg_cwnds" >> out_f
			printf "\n" >> out_f
			k=`expr $k + 1`
		done
		j=`expr $j + 1`
	done
	i=`expr $i + 1`
done

cp out_f /home/research/Desktop/out.csv
echo "Done!"
