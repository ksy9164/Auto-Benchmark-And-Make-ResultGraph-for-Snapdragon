#start benchmark shell

# $1 = device (cpu,gpu,dsp)         ex) cpu
# $2 = iteration (in benchmark)     ex) 10
# $3 = file path                    ex) ./result/bilateral/cpu_bilateral_Iter100.csv
# $4,5,6,7 freq                     ex) 1478400,1574400,414,144
# $8 check freq                     ex) 1478400
# $9 bench mark name                ex) bilateral
# $10 outer iteration               ex) 10

USER_NAME="sean"
DB_NAME="ttt.db"

LIB_PATH="/vendor/bin/$USER_NAME/lib"   #ex) /vendor/bin/alec/lib
RUN_FILE="/vendor/bin/$USER_NAME/$9"    #ex) /vendor/bin/alec/bilateral
INPUT_IMG_PATH="/sdcard/benchmark/input/image_VanHateren.iml"

#To start Trepn Profiler
adb shell am startservice com.quicinc.trepn/.TrepnService

#need check if trepn service started correctly
echo "Wait till TrepnService starts ..."

#Wait 1 second until trepn service open
sleep 3

#To start profiling and save the result to  sqlite3
adb shell am broadcast -a com.quicinc.trepn.start_profiling -e com.quicinc.trepn.database_file $DB_NAME


#TODO check Idle state of GPU

#bench example => adb shell LD_LIBRARY_PATH=/vendor/bin/sean/lib /vendor/bin/sean/bilateral -i /sdcard/benchmark/input/image_VanHateren.iml -I 10 -d cpu -f 1478400,1574400,414,144

PERFORMANCE=0
for (( i=0; i<${10}; i++));do
    T_PERFORMANCE=$(adb shell LD_LIBRARY_PATH=$LIB_PATH $RUN_FILE -i $INPUT_IMG_PATH -I $2 -d $1 -f $4,$5,$6,$7 | grep "Total-kernel-time"|cut -f2 -d '=' |cut -f2 -d ' ')
    PERFORMANCE=$[T_PERFORMANCE+PERFORMANCE]
done;
PERFORMANCE=$[PERFORMANCE/${10}]

adb shell am broadcast -a com.quicinc.trepn.stop_profiling

sleep 2;
#Get Info from database
TOTAL_BATTERY_POWER=$(adb shell "sqlite3 /sdcard/trepn/$DB_NAME \"select total from statistics where (name='Battery Power*');\"")

#TOTAL_BATTERY_POWER=$[TOTAL_BATTERY_POWER/${10}]

AVERAGE_POWER_T=$(adb shell "sqlite3 /sdcard/trepn/$DB_NAME \"select value from tuneupkit_statistics where (name='AVERAGE POWER');\"")
AVERAGE_POWER=$(echo "$AVERAGE_POWER_T"|cut -f1 -d ".")
echo "$8,$AVERAGE_POWER,$PERFORMANCE">>$3

