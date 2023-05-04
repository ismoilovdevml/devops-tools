# Stress Test Script Manual

This manual provides a guide on how to use a Bash script to perform a stress test on a given IP address. The script sends a specified number of HTTP requests, with a specified number of concurrent requests, to the target IP address and measures the time taken to complete the test.

>Remember to use this script responsibly and only target servers you have permission to test.

```bash
#!/bin/bash

# Replace 'ip_adress' with the IP address or URL of the target server you want to stress test.
url="ip_adress"

# The total number of HTTP requests to be sent during the test.
number_of_requests=60000

# The number of concurrent requests to be sent at once.
number_of_concurrent_requests=10

# This function sends multiple HTTP requests concurrently to the target URL.
send_requests() {
  for ((i=1; i<=number_of_requests/number_of_concurrent_requests; i++)); do
    curl -s -o /dev/null -w "%{http_code}\n" "$url" &
  done
  wait
}

# Display the start of the stress test with the target URL, total requests, and concurrent requests.
echo "Starting stress test on $url with $number_of_requests requests and $number_of_concurrent_requests concurrent requests."

# Record the start time of the stress test.
start_time=$(date +%s)

# Send concurrent requests using the send_requests function.
for ((i=1; i<=number_of_concurrent_requests; i++)); do
  send_requests &
done

# Wait for all requests to complete.
wait

# Record the end time of the stress test.
end_time=$(date +%s)

# Calculate the total time taken for the stress test and display it in seconds.
echo "Stress test completed in $(($end_time - $start_time)) seconds."
```