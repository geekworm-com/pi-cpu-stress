#!/bin/bash
# Raspberry Pi stress CPU temperature measurement script.
# From Jeff Geerling: https://gist.github.com/geerlingguy/91d4736afe9321cbfc1062165188dda4
# Download this script (e.g. with wget) and give it execute permissions (chmod +x).
# Then run it with ./pi-cpu-stress.sh

# Variables.
test_run=1
test_results_file="${HOME}/cpu_temp_$test_run.log"
stress_length="10m"

# Verify stress-ng is installed.
if ! [ -x "$(command -v stress-ng)" ]; then
  printf "Error: stress-ng not installed.\n"
  printf "To install: sudo apt install -y stress-ng\n" >&2
  exit 1
fi

printf "Logging temperature and throttling data to: $test_results_file\n"

# Start logging temperature data in the background.
# 当前的秒数；
current_second=0
while /bin/true; do
  # Print the date (e.g. "Wed 13 Nov 18:24:45 GMT 2019") and a tab.
  # 打印当前日期
  # date | tr '\n' '\t' >> $test_results_file;  
  
  # 打印当前的秒数,  by Geekworm
  printf '%d\t' $current_second >> $test_results_file;
  
  # Print the temperature (e.g. "39.0") and a tab.
  # vcgencmd measure_temp | tr -d "temp=" | tr -d "'C" | tr '\n' '\t' >> $test_results_file;
  
  # 打印CPU的温度 by Geekworm
  # vcgencmd measure_temp | tr -d "temp=" | tr '\n' '\t' >> $test_results_file;
  vcgencmd measure_temp | tr -d "temp="  >> $test_results_file;

  # Print the throttle status (e.g. "0x0") and a tab.
  # 检查是否出现欠压现象
  # 这个数字的第 0 位为 1 的话，表明当前发生了输入电压不足的情况；
  # 这个数字的第 16 位为 1 的话，表明启动之后曾经发生过输入电压不足的情况；
  # vcgencmd get_throttled | tr -d "throttled=" | tr '\n' '\t' >> $test_results_file;

  # Print the current CPU frequency.
  # 打印当前CPU时钟
  # vcgencmd measure_clock arm | sed 's/^.*=//' >> $test_results_file;

  # Aded by Geekworm
  let current_second=current_second+30;
  sleep 30;  
done &

# Store the logging pid.
PROC_ID=$!

# Stop the logging loop if script is interrupted or when it ends.
trap "kill $PROC_ID" EXIT

# After 5 minutes, run stress.
printf "Waiting 5 minutes for stable idle temperature...\n"
sleep 300
printf "Beginning $stress_length stress test...\n"
stress-ng -c 4 --timeout $stress_length

# Keep logging for 5 more minutes.
printf "Waiting 5 minutes to return to idle temperature...\n"
sleep 300

printf "Test complete.\n"
