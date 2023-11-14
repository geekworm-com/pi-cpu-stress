#!/bin/bash
# This script only monitor the Cpu temerature etc information.
# From Jeff Geerling: https://gist.github.com/geerlingguy/91d4736afe9321cbfc1062165188dda4
# Download this script (e.g. with wget) and give it execute permissions (chmod +x).
# Then run it with ./monitor-cpu.sh

# Variables.
test_run=1
# test_results_file="${HOME}/monitor_cpu_$test_run.log"
test_results_file="${HOME}/cpu_monitor.log"

printf "Logging temperature and throttling data to: $test_results_file\n"

printf "Press Ctrl+C to exit.\n"

# Start logging temperature data in the background.
# 当前的秒数；
seconds=0
while /bin/true; do
  # Print the date (e.g. "Wed 13 Nov 18:24:45 GMT 2019") and a tab.
  # 打印当前日期
  date | tr '\n' '\t' >> $test_results_file;  
  
  # 打印当前的秒数,  added by Geekworm
  printf '%d\t' $seconds >> $test_results_file;
  
  # Print the temperature (e.g. "39.0") and a tab.
  vcgencmd measure_temp | tr -d "temp=" | tr -d "'C" | tr '\n' '\t' >> $test_results_file;
  
  # Print the throttle status (e.g. "0x0") and a tab.
  # 检查是否出现欠压现象
  # 这个数字的第 0 位为 1 的话，表明当前发生了输入电压不足的情况；
  # 这个数字的第 16 位为 1 的话，表明启动之后曾经发生过输入电压不足的情况；
  vcgencmd get_throttled | tr -d "throttled=" | tr '\n' '\t' >> $test_results_file;

  # Print the current CPU frequency.
  # 打印当前CPU时钟
  vcgencmd measure_clock arm | sed 's/^.*=//' >> $test_results_file;

  # Aded by Geekworm
  let seconds=seconds+20;
  sleep 20;  
done 

# Store the logging pid.
PROC_ID=$!

# Stop the logging loop if script is interrupted or when it ends.
trap "kill $PROC_ID" EXIT
