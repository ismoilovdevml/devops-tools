#!/usr/bin/env bash
set -euo pipefail

# `wait -n` (used below to cap concurrency) needs bash 4.3+. macOS still ships
# bash 3.2, so point the shebang at whatever bash is first on PATH and fail
# loudly rather than silently ignoring the concurrency limit.
if ((BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3))); then
  echo "This script needs bash 4.3 or newer (found $BASH_VERSION)." >&2
  exit 1
fi

# Replace with the IP address or URL of the target server you want to stress test.
url="${1:-https://google.com/}"

# The total number of HTTP requests to be sent during the test.
number_of_requests="${2:-60000}"

# The number of requests kept in flight at any one time.
number_of_concurrent_requests="${3:-100}"

echo "Starting stress test on $url with $number_of_requests requests and $number_of_concurrent_requests concurrent requests."

start_time=$(date +%s)

# Keep exactly $number_of_concurrent_requests curls in flight.
#
# The previous version launched $number_of_concurrent_requests background
# workers that each launched $number_of_requests/$number_of_concurrent_requests
# background curls, so the real concurrency was $number_of_requests (60000
# processes), not $number_of_concurrent_requests.
in_flight=0
for ((i = 1; i <= number_of_requests; i++)); do
  curl -s -o /dev/null -w "%{http_code}\n" "$url" &

  in_flight=$((in_flight + 1))
  if ((in_flight >= number_of_concurrent_requests)); then
    wait -n
    in_flight=$((in_flight - 1))
  fi
done

wait

end_time=$(date +%s)

echo "Stress test completed in $((end_time - start_time)) seconds."
