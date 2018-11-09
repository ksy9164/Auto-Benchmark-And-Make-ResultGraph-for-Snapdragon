#!/bin/bash
#./run.sh lcpu 100 bilateral 4
# $1 = devuce ex) lcpu
# $2 = iteration ex) 100
# $3 = benchmark name ex) bilateral
# $4 = iteration (for program to get accurate result)

source env.sh

#file path & name
path="./result/$3"
file="$path/$1_$3_Iter$2.csv"   #ex) ./../result/bilateral/lcpu_bilateral_Iter100.csv

if [ -e "$path" ]
then
    echo "$path exist !! "
else
    echo "$path is not found"
    mkdir $path
fi

if [ -e "$file" ]
then
    echo " $file exist error!!"
    echo " if you want overwrite press 1"
    read overwrite
    if [ $overwrite = 1 ]
    then
        echo "good"
    else
        exit 1
    fi
else
    echo " run.sh running... !!"
fi

echo "freq,Average Power,Total-kernel-time">$file

#set governor
adb shell "echo "userspace"> /sys/devices/system/cpu/cpufreq/policy0/scaling_governor"
adb shell "echo "userspace"> /sys/devices/system/cpu/cpufreq/policy4/scaling_governor"
adb shell "echo "userspace"> /sys/class/kgsl/kgsl-3d0/devfreq/governor"

#start benchmarks
case $1 in
 bcpu) frq_target=$BCPU_FREQ
 num_freq=4
 for bcpu_frq in $frq_target;do
    ./start_bench.sh cpu $2 $file $bcpu_frq $DEFAULT_CPU4 $DEFAULT_GPU $DEFAULT_DSP $bcpu_frq $3 $4
 echo "freq $FREQ is end!!"
 FREQ=$(adb shell cat /sys/devices/system/cpu/cpufreq/policy0/cpuinfo_cur_freq)
 done;;
 
 lcpu) frq_target=$LCPU_FREQ
 num_freq=4
 for lcpu_frq in $frq_target;do
  ./start_bench.sh cpu $2 $file $DEFAULT_CPU0 $lcpu_frq $DEFAULT_GPU $DEFAULT_DSP $lcpu_frq $3 $4
 FREQ=$(adb shell cat /sys/devices/system/cpu/cpufreq/policy4/cpuinfo_cur_freq) 
 echo "freq $FREQ is end!!"
 done;;
 
 gpu) frq_target=$GPU_FREQ
 num_freq=4
 for gpu_frq in $frq_target;do
    ./start_bench.sh gpu $2 $file $DEFAULT_CPU0 $DEFAULT_CPU4 $gpu_frq $DEFAULT_DSP $gpu_frq $3 $4
 FREQ=$(adb shell cat /sys/class/kgsl/kgsl-3d0/devfreq/cur_freq)
 echo "freq $FREQ is end!!"
 done;;
 
 dsp) frq_target=$DSP_FREQ
 num_freq=4
 for dsp_frq in $frq_target;do
  ./start_bench.sh dsp $2 $file $DEFAULT_CPU0 $DEFAULT_CPU4 $DEFAULT_GPU $dsp_frq $dsp_frq $3 $4
 done;;
 *)echo "Invalid number !!";;
esac

python3 make_graph.py $file $num_freq
