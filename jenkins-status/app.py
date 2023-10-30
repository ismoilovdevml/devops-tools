from flask import Flask, render_template
import requests
from datetime import datetime, timedelta

app = Flask(__name__)

jenkins_url = 'http://0.0.0.0:8080'  # Replace with your Jenkins URL

@app.route('/')
def home():
    jobs = get_jobs(jenkins_url)
    return render_template('index.html', jobs=jobs)

def get_jobs(url):
    response = requests.get(f'{url}/api/json?tree=jobs[name,_class,url,lastBuild[result,timestamp,building]]')
    jobs = []

    if response.status_code == 200:
        data = response.json()

        if 'jobs' in data:
            for job in data['jobs']:
                if job.get('_class') == 'com.cloudbees.hudson.plugins.folder.Folder':
                    jobs.extend(get_jobs(job.get('url')))
                else:
                    last_build = job.get('lastBuild') if job.get('lastBuild') else {}

                    if last_build.get('building', False):
                        status = 'RUNNING'
                    else:
                        status = last_build.get('result', 'UNKNOWN')

                    jobs.append({
                        'name': job.get('name', 'N/A'),
                        'status': status,
                        'timestamp': last_build.get('timestamp', 'N/A'),
                        'branches': get_branches(job.get('name'), job.get('url'))
                    })

    return jobs

def get_branches(job_name, job_url):
    response = requests.get(f'{job_url}/api/json?tree=jobs[name,lastBuild[result,timestamp,building]]')
    branches = []

    if response.status_code == 200:
        data = response.json()

        if 'jobs' in data:
            for job in data['jobs']:
                last_build = job.get('lastBuild') if job.get('lastBuild') else {}

                if last_build.get('building', False):
                    status = 'RUNNING'
                else:
                    status = last_build.get('result', 'UNKNOWN')

                build_time = last_build.get('timestamp', 0) / 1000  # Convert milliseconds to seconds
                build_datetime = datetime.fromtimestamp(build_time)
                elapsed_time = datetime.now() - build_datetime

                branches.append({
                    'name': job.get('name', 'N/A'),
                    'status': status,
                    'timestamp': build_datetime.strftime('%Y-%m-%d %H:%M:%S'),
                    'elapsed_time': str(timedelta(seconds=round(elapsed_time.total_seconds())))
                })

    return branches

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
