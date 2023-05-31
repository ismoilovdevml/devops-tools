import os
import subprocess

# Keycloak parameters
HOSTNAME = "192.168.1.205:8080"    # Change this to your Keycloak server URL
REALM = "Apex"
CLIENT_ID = "identity"
USER = "admin"
PASSWORD = "Vj8FG4MCym"

# JMeter parameters
JMETER_PATH = "/usr/bin/"  # Update this to your JMeter path
THREADS = 1000  # Number of threads (users). Change as per your needs
RAMP_UP = 60  # Ramp-up period (in seconds). Change as per your needs
DURATION = 300  # Test duration (in seconds). Change as per your needs

# JMeter test plan parameters
TEST_PLAN_NAME = "KeycloakStressTest"
JMETER_TEST_PLAN = "/home/ismoilovdev/Documents/" + TEST_PLAN_NAME + ".jmx"  # Update this to the path of your JMeter test plan
JMETER_REPORT_PATH = "/home/ismoilovdev/Documents/report"  # Update this to the path where you want to store the report

# Check if the report directory exists, create it if it doesn't
if not os.path.exists(JMETER_REPORT_PATH):
    os.makedirs(JMETER_REPORT_PATH)

# Create JMeter test plan for Keycloak
print("Creating JMeter test plan...")
subprocess.call([JMETER_PATH + "jmeter", "-n", "-t", JMETER_TEST_PLAN,
                 "-Jhostname=" + HOSTNAME, "-Jrealm=" + REALM, "-Jclient_id=" + CLIENT_ID,
                 "-Juser=" + USER, "-Jpassword=" + PASSWORD, "-Jthreads=" + str(THREADS),
                 "-Jrampup=" + str(RAMP_UP), "-Jduration=" + str(DURATION)])

# Run the test plan
print("Starting stress test...")
subprocess.call([JMETER_PATH + "jmeter", "-n", "-t", JMETER_TEST_PLAN, "-l", "result.jtl"])

# Generate the report
print("Generating report...")
subprocess.call([JMETER_PATH + "jmeter", "-g", "result.jtl", "-o", JMETER_REPORT_PATH])

print("Stress test completed. Report generated at " + JMETER_REPORT_PATH)
