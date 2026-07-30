import os
import shutil
import subprocess
import sys

# Keycloak parameters. Override any of these from the environment.
HOSTNAME = os.environ.get("KC_HOSTNAME", "localhost:8080")  # Keycloak server URL
REALM = os.environ.get("KC_REALM", "Test")
CLIENT_ID = os.environ.get("KC_CLIENT_ID", "test")
USER = os.environ.get("KC_USER", "username")
PASSWORD = os.environ.get("KC_PASSWORD", "password")

# JMeter parameters
JMETER_BIN = os.environ.get("JMETER_BIN", "/usr/bin/jmeter")
THREADS = int(os.environ.get("THREADS", "1000"))  # Number of threads (users)
RAMP_UP = int(os.environ.get("RAMP_UP", "60"))    # Ramp-up period (seconds)
DURATION = int(os.environ.get("DURATION", "300"))  # Test duration (seconds)

# JMeter test plan parameters
TEST_PLAN_NAME = os.environ.get("TEST_PLAN_NAME", "KeycloakStressTest")
JMETER_TEST_PLAN = os.environ.get(
    "JMETER_TEST_PLAN",
    os.path.join(os.path.dirname(os.path.abspath(__file__)), TEST_PLAN_NAME + ".jmx"),
)
JMETER_RESULTS = os.environ.get("JMETER_RESULTS", "result.jtl")
JMETER_REPORT_PATH = os.environ.get("JMETER_REPORT_PATH", "./report")

if not os.path.isfile(JMETER_TEST_PLAN):
    sys.exit(f"Test plan not found: {JMETER_TEST_PLAN}")

# JMeter refuses to overwrite an existing results file or write into a non-empty
# report directory, so clear both instead of creating the report dir up front.
if os.path.exists(JMETER_RESULTS):
    os.remove(JMETER_RESULTS)
if os.path.isdir(JMETER_REPORT_PATH):
    shutil.rmtree(JMETER_REPORT_PATH)

# Run the test plan once, with the parameters, capturing results.
#
# The previous version ran the plan twice: once with -J parameters but no -l (so
# those results were thrown away) and once with -l but no parameters (so the run
# that was actually measured used the plan defaults).
print("Starting stress test...")
subprocess.run(
    [
        JMETER_BIN, "-n",
        "-t", JMETER_TEST_PLAN,
        "-l", JMETER_RESULTS,
        f"-Jhostname={HOSTNAME}",
        f"-Jrealm={REALM}",
        f"-Jclient_id={CLIENT_ID}",
        f"-Juser={USER}",
        f"-Jpassword={PASSWORD}",
        f"-Jthreads={THREADS}",
        f"-Jrampup={RAMP_UP}",
        f"-Jduration={DURATION}",
    ],
    check=True,
)

# Generate the report
print("Generating report...")
subprocess.run(
    [JMETER_BIN, "-g", JMETER_RESULTS, "-o", JMETER_REPORT_PATH],
    check=True,
)

print("Stress test completed. Report generated at " + JMETER_REPORT_PATH)
