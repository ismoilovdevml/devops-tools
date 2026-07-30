#!/bin/bash
set -euo pipefail

# Keycloak parameters. Override any of these from the environment.
HOSTNAME="${HOSTNAME:-localhost:8080}"    # Change this to your Keycloak server URL
REALM="${REALM:-Test}"
CLIENT_ID="${CLIENT_ID:-test}"
KC_USER="${KC_USER:-username}"
KC_PASSWORD="${KC_PASSWORD:-password}"

# JMeter parameters
JMETER_BIN="${JMETER_BIN:-/usr/bin/jmeter}"
THREADS="${THREADS:-1000}"   # Number of threads (users)
RAMP_UP="${RAMP_UP:-60}"     # Ramp-up period (in seconds)
DURATION="${DURATION:-300}"  # Test duration (in seconds)

# JMeter test plan parameters
TEST_PLAN_NAME="${TEST_PLAN_NAME:-KeycloakStressTest}"
JMETER_TEST_PLAN="${JMETER_TEST_PLAN:-$(dirname "$0")/${TEST_PLAN_NAME}.jmx}"
JMETER_RESULTS="${JMETER_RESULTS:-result.jtl}"
JMETER_REPORT_PATH="${JMETER_REPORT_PATH:-./report}"

if [ ! -f "$JMETER_TEST_PLAN" ]; then
  echo "Test plan not found: $JMETER_TEST_PLAN" >&2
  exit 1
fi

# JMeter refuses to write into an existing results file or a non-empty report
# directory, so clear both before starting instead of creating them up front.
rm -f "$JMETER_RESULTS"
rm -rf "$JMETER_REPORT_PATH"

# Run the test plan once, with the parameters, capturing results.
#
# The previous version ran the plan twice: once with -J parameters but no -l (so
# those results were thrown away) and once with -l but no parameters (so the run
# that was actually measured used the plan defaults).
echo "Starting stress test..."
"$JMETER_BIN" -n \
  -t "$JMETER_TEST_PLAN" \
  -l "$JMETER_RESULTS" \
  "-Jhostname=$HOSTNAME" \
  "-Jrealm=$REALM" \
  "-Jclient_id=$CLIENT_ID" \
  "-Juser=$KC_USER" \
  "-Jpassword=$KC_PASSWORD" \
  "-Jthreads=$THREADS" \
  "-Jrampup=$RAMP_UP" \
  "-Jduration=$DURATION"

# Generate the report
echo "Generating report..."
"$JMETER_BIN" -g "$JMETER_RESULTS" -o "$JMETER_REPORT_PATH"

echo "Stress test completed. Report generated at ${JMETER_REPORT_PATH}"
