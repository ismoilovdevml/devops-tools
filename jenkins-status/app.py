import os

import requests
from flask import Flask, render_template
from datetime import datetime, timedelta

app = Flask(__name__)

# Point at your Jenkins controller. 0.0.0.0 is a bind address, not a routable
# destination, so it is only a sensible default when Jenkins is on localhost.
jenkins_url = os.environ.get('JENKINS_URL', 'http://localhost:8080')
jenkins_user = os.environ.get('JENKINS_USER')
jenkins_token = os.environ.get('JENKINS_TOKEN')

# Without a timeout a hung Jenkins wedges the Flask worker forever.
REQUEST_TIMEOUT = float(os.environ.get('JENKINS_TIMEOUT', '10'))


def _auth():
    if jenkins_user and jenkins_token:
        return (jenkins_user, jenkins_token)
    return None


def _get_json(url):
    """Fetch JSON from Jenkins, returning None instead of raising.

    The previous version let connection errors bubble up, so a Jenkins outage
    turned every page load into a 500 with a stack trace.
    """
    try:
        response = requests.get(url, timeout=REQUEST_TIMEOUT, auth=_auth())
        response.raise_for_status()
        return response.json()
    except (requests.RequestException, ValueError) as exc:
        app.logger.warning('Jenkins request failed for %s: %s', url, exc)
        return None


def _status_of(job):
    last_build = job.get('lastBuild') or {}
    if last_build.get('building', False):
        return 'RUNNING', last_build
    return last_build.get('result') or 'UNKNOWN', last_build


@app.route('/')
def home():
    jobs = get_jobs(jenkins_url)
    return render_template('index.html', jobs=jobs)


def get_jobs(url):
    data = _get_json(
        f'{url}/api/json?tree=jobs[name,_class,url,lastBuild[result,timestamp,building]]'
    )
    jobs = []

    if not data:
        return jobs

    for job in data.get('jobs', []):
        if job.get('_class') == 'com.cloudbees.hudson.plugins.folder.Folder':
            jobs.extend(get_jobs(job.get('url')))
            continue

        status, last_build = _status_of(job)
        jobs.append({
            'name': job.get('name', 'N/A'),
            'status': status,
            'timestamp': last_build.get('timestamp', 'N/A'),
            'branches': get_branches(job.get('name'), job.get('url')),
        })

    return jobs


def get_branches(job_name, job_url):
    if not job_url:
        return []

    data = _get_json(
        f'{job_url}/api/json?tree=jobs[name,lastBuild[result,timestamp,building]]'
    )
    branches = []

    if not data:
        return branches

    for job in data.get('jobs', []):
        status, last_build = _status_of(job)

        timestamp_ms = last_build.get('timestamp')
        if timestamp_ms:
            build_datetime = datetime.fromtimestamp(timestamp_ms / 1000)
            elapsed = datetime.now() - build_datetime
            timestamp = build_datetime.strftime('%Y-%m-%d %H:%M:%S')
            elapsed_time = str(timedelta(seconds=round(elapsed.total_seconds())))
        else:
            # A job that has never run has no lastBuild; the old code divided
            # the default 0 and reported every such branch as 1970-01-01.
            timestamp = 'N/A'
            elapsed_time = 'N/A'

        branches.append({
            'name': job.get('name', 'N/A'),
            'status': status,
            'timestamp': timestamp,
            'elapsed_time': elapsed_time,
        })

    return branches


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', '5000')))
