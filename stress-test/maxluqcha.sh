#!/bin/bash

url="ip_adress_yozing"
number_of_requests=60000
number_of_concurrent_requests=10

send_requests() {
  for ((i=1; i<=number_of_requests/number_of_concurrent_requests; i++)); do
    curl -s -o /dev/null -w "%{http_code}\n" "$url" &
  done
  wait
}

echo "Starting stress test on $url with $number_of_requests requests and $number_of_concurrent_requests concurrent requests."
start_time=$(date +%s)

for ((i=1; i<=number_of_concurrent_requests; i++)); do
  send_requests &
done

wait
end_time=$(date +%s)

echo "Stress test completed in $(($end_time - $start_time)) seconds."
