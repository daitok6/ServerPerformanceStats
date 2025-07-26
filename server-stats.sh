# Styling
BLUE_BOLD="\033[1;38;5;33m"
BLACK_BOLD_UNDERLINE=$'\e[1;4;30m'
RESET=$'\e[0m'


# Total CPU usage
top -l 1 | grep "CPU usage" | sed -E "s/(CPU usage:)/${BLACK_BOLD_UNDERLINE}\1${RESET}/"
echo ""

# Total memory usage (Free vs Used including percentage)
pagesize=$(sysctl -n hw.pagesize)
vm_stat=$(vm_stat)

free=$(echo "$vm_stat" | awk '/Pages free/ {print $3}' | tr -d '.')
inactive=$(echo "$vm_stat" | awk '/Pages inactive/ {print $3}' | tr -d '.')
speculative=$(echo "$vm_stat" | awk '/Pages speculative/ {print $3}' | tr -d '.')
used=$(echo "$vm_stat" | awk '/Pages wired down/ {print $4}' | tr -d '.')

total_mem=$(sysctl -n hw.memsize)

free_bytes=$(( (free + inactive + speculative) * pagesize ))
used_bytes=$(( total_mem - free_bytes ))

memory_usage_percent=$(( used_bytes * 100 / total_mem ))

echo "${BLACK_BOLD_UNDERLINE}Memory Usage:${RESET} $((used_bytes / 1024 / 1024)) MB / $((total_mem / 1024 / 1024)) MB ($memory_usage_percent%)"
echo ""


# Total disk usage (Free vs Used including percentage)
disk_size_kb=$(diskutil info / \
  | awk -F'[()]' '/Disk Size/ {gsub(/[^0-9]/,"",$2); print $2}' \
  | awk '{print $1/1024}')
total_used_kb=$(df -k | awk 'NR>1 {sum += $3} END {print sum}')
total_available_kb=$((disk_size_kb - total_used_kb))

disk_size=$(echo "scale=2; $disk_size_kb / 1024 / 1024" | bc)
used=$(echo "scale=2; $total_used_kb / 1024 / 1024" | bc)
available=$(echo "scale=2; $total_available_kb / 1024 / 1024" | bc)
used_percent=$(echo "scale=2; ($total_used_kb * 100) / $disk_size_kb" | bc | awk '{printf "%.1f", $1}')
free_percent=$(echo "scale=2; ($available * 100) / $disk_size" | bc | awk '{printf "%.1f", $1}')

echo "${BLACK_BOLD_UNDERLINE}Disk Usage on /:${RESET}"
echo "  Physical Size: $disk_size GB"
echo "  Used:  $used GB ($used_percent%)"
echo "  Free:  $available GB ($free_percent%)"
echo ""


# Top 5 processes by CPU usage
  echo "${BLACK_BOLD_UNDERLINE}Top 5 processes(CPU Usage):${RESET}"
  echo "   ${BLUE_BOLD}PID    Usage(%)${RESET}"
  ps aux | sort -nrk 3 | head -5 | \
  awk '{
    pid=$2;
    usage=$3;
    printf "   %-6s %7s%%\n", pid, usage;
  }'
  echo ""


# Top 5 processes by memory usage
  echo "${BLACK_BOLD_UNDERLINE}Top 5 processes(Memory Usage):${RESET}"
  echo "   ${BLUE_BOLD}PID    Usage(%)${RESET}"
  ps aux | sort -nrk 4 | head -5 | \
  awk '{
    pid=$2;
    usage=$4;
    printf "   %-6s %7s%%\n", pid, usage;
  }'
