from flask import Flask, render_template
import requests
from datetime import datetime, timedelta

app = Flask(__name__)

jenkins_url = 'http://192.168.1.170:8080'  # Replace with your Jenkins URL


@app.route('/')
def home():
    folders = get_folders()
    return render_template('index.html', folders=folders)


def get_folders():
    response = requests.get(f'{jenkins_url}/api/json?tree=jobs[name,jobs[name,jobs[name,lastBuild[result,timestamp]]]]')

    if response.status_code == 200:
        data = response.json()
        folders = []

        if 'jobs' in data:
            for folder in data['jobs']:
                folder_name = folder.get('name', 'N/A')
                multibranches = get_multibranches(folder)

                folders.append({
                    'name': folder_name,
                    'multibranches': multibranches
                })

        return folders
    else:
        return [{'name': 'N/A', 'multibranches': []}]


def get_multibranches(folder):
    multibranches = []

    if 'jobs' in folder:
        for multibranch in folder['jobs']:
            multibranch_name = multibranch.get('name', 'N/A')
            branches = get_branches(multibranch)

            multibranches.append({
                'name': multibranch_name,
                'branches': branches
            })

    return multibranches


def get_branches(multibranch):
    branches = []

    if 'jobs' in multibranch:
        for branch in multibranch['jobs']:
            branch_name = branch.get('name', 'N/A')
            last_build = branch.get('lastBuild') if branch.get('lastBuild') else {}

            build_time = last_build.get('timestamp', 0) / 1000  # Convert milliseconds to seconds
            build_datetime = datetime.fromtimestamp(build_time)
            elapsed_time = datetime.now() - build_datetime

            branches.append({
                'name': branch_name,
                'status': last_build.get('result', 'UNKNOWN'),
                'timestamp': build_datetime.strftime('%Y-%m-%d %H:%M:%S'),
                'elapsed_time': str(timedelta(seconds=round(elapsed_time.total_seconds())))
            })

    return branches


if __name__ == '__main__':
    app.run(debug=True)
