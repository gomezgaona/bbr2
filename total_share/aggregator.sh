#!/bin/bash

cubic_flows=(1 2 3 4 5 6 7 8 9 10)
bbr2_flows=(1 2 3 5 10)
cd "/home/Test_Results/"
rm out_f
echo "Running aggregator"
i=0
while [ $i -lt "${#cubic_flows[@]}" ]; do
	j=0
	while [ $j -lt "${#bbr2_flows[@]}" ]; do
		k=1
		total_tput_1=0
		total_rtts_1=0
		total_retrs_1=0
		total_cwnds_1=0
		total_tput_2=0
		total_rtts_2=0
		total_retrs_2=0
		total_cwnds_2=0
		while [ $k -le 10 ]; do
			echo "Cubic Flows: ${cubic_flows[$i]}, BBRv2 Flows: ${bbr2_flows[$j]}, Run: $k"
			m=1
			while [ $m -le 20 ]; do
				if [ $m -le "${cubic_flows[$i]}" ]; then
					f="/home/Test_Results/h1_${cubic_flows[$i]}_${bbr2_flows[j]}_${k}_${m}/results/1.dat"
					tputs=`cut -d " " -f 5 $f | paste -sd+ -| bc`
					rtts=`cut -d " " -f 8 $f | paste -sd+ - | bc`
					retrs=`cut -d " " -f 6 $f | paste -sd+ - | bc`
					cwnds=`cut -d " " -f 7 $f | paste -sd+ - | bc`
					total_tput_1=`echo "scale=2;$total_tput_1+$tputs" | bc` 
					total_rtts_1=`echo "scale=2;$total_rtts_1+$rtts" | bc`
					total_retrs_1=`echo "scale=2;$total_retrs_1+$retrs" | bc`
					total_cwnds_1=`echo "scale=2;$total_cwnds_1+$cwnds" | bc`
				fi
				if [ $m -le "${bbr2_flows[$j]}" ]; then
					f="/home/Test_Results/h2_${cubic_flows[$i]}_${bbr2_flows[j]}_${k}_${m}/results/1.dat"
					tputs=`cut -d " " -f 5 $f | paste -sd+ -| bc`
					rtts=`cut -d " " -f 8 $f | paste -sd+ - | bc`
					retrs=`cut -d " " -f 6 $f | paste -sd+ - | bc`
					cwnds=`cut -d " " -f 7 $f | paste -sd+ - | bc`
					total_tput_2=`echo "scale=2;$total_tput_2+$tputs" | bc` 
					total_rtts_2=`echo "scale=2;$total_rtts_2+$rtts" | bc`
					total_retrs_2=`echo "scale=2;$total_retrs_2+$retrs" | bc`
					total_cwnds_2=`echo "scale=2;$total_cwnds_2+$cwnds" | bc`
				fi
				m=`expr $m + 1`
			done
			k=`expr $k + 1`
		done
		avg_tput_1=`echo "scale=2;$total_tput_1 / 1200.0" | bc` 
		avg_rtts_1=`echo "scale=2;$total_rtts_1 / 1200.0" | bc`
		avg_retrs_1=`echo "scale=2;$total_retrs_1 / 1200.0" | bc`
		avg_cwnds_1=`echo "scale=2;$total_cwnds_1 / 1200.0" | bc`
		avg_tput_2=`echo "scale=2;$total_tput_2 / 1200.0" | bc` 
		avg_rtts_2=`echo "scale=2;$total_rtts_2 / 1200.0" | bc`
		avg_retrs_2=`echo "scale=2;$total_retrs_2 / 1200.0" | bc`
		avg_cwnds_2=`echo "scale=2;$total_cwnds_2 / 1200.0" | bc`
		printf "${cubic_flows[$i]},${bbr2_flows[$j]},$avg_tput_1,$avg_tput_2,$avg_rtts_1,$avg_rtts_2,$avg_retrs_1,$avg_retrs_2,$avg_cwnds_1,$avg_cwnds_2" >> out_f
		printf "\n" >> out_f
		echo "${cubic_flows[$i]},${bbr2_flows[$j]},$avg_tput_1,$avg_tput_2,$avg_rtts_1,$avg_rtts_2,$avg_retrs_1,$avg_retrs_2,$avg_cwnds_1,$avg_cwnds_2"
		j=`expr $j + 1`
	done
	i=`expr $i + 1`
done
cp out_f /home/research/Desktop/out.csv
