import os
import subprocess
import sys
import shutil

def backup_databases():
    result = subprocess.run(['psql', '-U', 'postgres', '-lqt'], stdout=subprocess.PIPE)
    db_names = [row.split('|')[0].strip() for row in result.stdout.decode('utf-8').split('\n') if row]

    backup_folder = "/home/ismoilovdev/baza"
    os.makedirs(backup_folder, exist_ok=True)
    for db_name in db_names:
        if db_name not in ["template0", "template1", "postgres"]:
            print(f"Taking backup of {db_name}")
            subprocess.run(['pg_dump', '-U', 'postgres', '--no-owner', '--file', os.path.join(backup_folder, f'{db_name}.sql'), db_name])

def restore_databases():
    backup_folder = "/home/ismoilovdev/baza"
    backup_files = [f for f in os.listdir(backup_folder) if f.endswith('.sql')]
    db_names = [os.path.splitext(f)[0] for f in backup_files if os.path.splitext(f)[0] and not f.startswith('.')]

    for db_name in db_names:
        test_db_name = f'test_{db_name}'
        print(f"Creating database: {test_db_name}")
        subprocess.run(['createdb', '-U', 'postgres', test_db_name])
        
        print(f"Restoring: {db_name} from {os.path.join(backup_folder, f'{db_name}.sql')} to {test_db_name}")
        subprocess.run(['psql', '-U', 'postgres', '-d', test_db_name, '-f', os.path.join(backup_folder, f'{db_name}.sql')])

def drop_test_databases():
    result = subprocess.run(['psql', '-U', 'postgres', '-lqt'], stdout=subprocess.PIPE)
    db_names = [row.split('|')[0].strip() for row in result.stdout.decode('utf-8').split('\n') if row]

    for db_name in db_names:
        if db_name.startswith('test_'):
            print(f"Dropping database: {db_name}")
            subprocess.run(['dropdb', '-U', 'postgres', db_name])

    backup_folder = "/home/ismoilovdev/baza"
    print(f"Clearing backup folder: {backup_folder}")
    shutil.rmtree(backup_folder)

if __name__ == "__main__":
    if len(sys.argv) != 2 or sys.argv[1] not in ['start', 'stop']:
        print("Usage: script.py [start|stop]")
        sys.exit(1)
    
    if sys.argv[1] == 'start':
        backup_databases()
        restore_databases()
    elif sys.argv[1] == 'stop':
        drop_test_databases()
