from flask import Flask, render_template
import requests
from datetime import datetime, timedelta

app = Flask(__name__)

jenkins_url = 'http://192.168.1.170:8080'  # Replace with your Jenkins URL

@app.route('/')
def home():
    jobs = get_jobs()
    return render_template('index.html', jobs=jobs)

def get_jobs():
    response = requests.get(f'{jenkins_url}/api/json?tree=jobs[name,lastBuild[result,timestamp,building]]')

    if response.status_code == 200:
        data = response.json()
        jobs = []

        if 'jobs' in data:
            for job in data['jobs']:
                last_build = job.get('lastBuild') if job.get('lastBuild') else {}

                if last_build.get('building', False):
                    status = 'RUNNING'
                else:
                    status = last_build.get('result', 'UNKNOWN')

                jobs.append({
                    'name': job.get('name', 'N/A'),
                    'status': status,
                    'timestamp': last_build.get('timestamp', 'N/A'),
                    'branches': get_branches(job.get('name'))
                })

        return jobs
    else:
        return [{'name': 'N/A', 'status': 'ERROR', 'timestamp': 'N/A', 'branches': []}]

def get_branches(job_name):
    response = requests.get(f'{jenkins_url}/job/{job_name}/api/json?tree=jobs[name,lastBuild[result,timestamp,building]]')

    if response.status_code == 200:
        data = response.json()
        branches = []

        if 'jobs' in data:
            for job in data['jobs']:
                branch_name = job.get('name', 'N/A')
                last_build = job.get('lastBuild') if job.get('lastBuild') else {}

                if last_build.get('building', False):
                    status = 'RUNNING'
                else:
                    status = last_build.get('result', 'UNKNOWN')

                build_time = last_build.get('timestamp', 0) / 1000  # Convert milliseconds to seconds
                build_datetime = datetime.fromtimestamp(build_time)
                elapsed_time = datetime.now() - build_datetime

                branches.append({
                    'name': branch_name,
                    'status': status,
                    'timestamp': build_datetime.strftime('%Y-%m-%d %H:%M:%S'),
                    'elapsed_time': str(timedelta(seconds=round(elapsed_time.total_seconds())))
                })

        return branches
    else:
        return []

if __name__ == '__main__':
    app.run(debug=True)
