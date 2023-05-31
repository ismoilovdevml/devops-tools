#!/bin/bash

# Keycloak parameters
HOSTNAME="192.168.1.205:8080"    # Change this to your Keycloak server URL
REALM="Apex"
CLIENT_ID="identity"
USER="admin"
PASSWORD="Vj8FG4MCym"

# JMeter parameters
JMETER_PATH="/usr/bin/"  # Update this to your JMeter path
THREADS=1000  # Number of threads (users). Change as per your needs
RAMP_UP=60  # Ramp-up period (in seconds). Change as per your needs
DURATION=300  # Test duration (in seconds). Change as per your needs

# JMeter test plan parameters
TEST_PLAN_NAME="KeycloakStressTest"
JMETER_TEST_PLAN="/home/ismoilovdev/Documents/${TEST_PLAN_NAME}.jmx"  # Include slash between Documents and ${TEST_PLAN_NAME}
JMETER_REPORT_PATH="/home/ismoilovdev/Documents/report"  # Include slash between Documents and report


# Check if the report directory exists, create it if it doesn't
if [ ! -d "$JMETER_REPORT_PATH" ]; then
  mkdir -p $JMETER_REPORT_PATH
fi

# Create JMeter test plan for Keycloak
echo "Creating JMeter test plan..."
jmeter -n -t ${JMETER_TEST_PLAN} -Jhostname=${HOSTNAME} -Jrealm=${REALM} -Jclient_id=${CLIENT_ID} -Juser=${USER} -Jpassword=${PASSWORD} -Jthreads=${THREADS} -Jrampup=${RAMP_UP} -Jduration=${DURATION}

# Run the test plan
echo "Starting stress test..."
${JMETER_PATH}/jmeter -n -t ${JMETER_TEST_PLAN} -l result.jtl

# Generate the report
echo "Generating report..."
${JMETER_PATH}/jmeter -g result.jtl -o ${JMETER_REPORT_PATH}

echo "Stress test completed. Report generated at ${JMETER_REPORT_PATH}"
