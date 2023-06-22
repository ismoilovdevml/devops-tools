import psutil
import socket
import time
import requests

TOKEN = "TOKEN"
CHAT_ID = "chat-ID"
CPU_THRESHOLD = 80
RAM_THRESHOLD = 80
DISK_THRESHOLD = 80
URL = f"https://api.telegram.org/bot{TOKEN}/sendMessage"

def send_message(message):
    payload = {
        'chat_id': CHAT_ID,
        'text': message,
        'parse_mode': 'HTML'
    }
    response = requests.post(URL, data=payload)
    return response

def format_size(size):
    units = ['B', 'KB', 'MB', 'GB', 'TB']
    index = 0
    while size >= 1024 and index < len(units) - 1:
        size /= 1024
        index += 1
    return f"{size:.2f} {units[index]}"

def main():
    while True:
        cpu_percent = psutil.cpu_percent()
        ram = psutil.virtual_memory()
        disk = psutil.disk_usage('/')

        if cpu_percent > CPU_THRESHOLD or ram.percent > RAM_THRESHOLD or disk.percent > DISK_THRESHOLD:
            message = f"⚠️ <b>Server Status Warning</b> ⚠️\n\n" \
                      f"🖥️ <b>Server Name:</b> {socket.gethostname()}\n" \
                      f"🌐 <b>Server IP Address:</b> {socket.gethostbyname(socket.gethostname())}\n"

            if cpu_percent > CPU_THRESHOLD:
                message += f"💻 <b>CPU Usage:</b> {cpu_percent}% (Threshold: {CPU_THRESHOLD}%)\n"

            if ram.percent > RAM_THRESHOLD:
                message += f"📈 <b>RAM Usage:</b> {ram.percent}% (Threshold: {RAM_THRESHOLD}%)\n"

            if disk.percent > DISK_THRESHOLD:
                message += f"💾 <b>Disk Usage:</b> {disk.percent}% (Threshold: {DISK_THRESHOLD}%)\n"

            message += f"\n<b>System Details:</b>\n" \
                       f"🔄 <b>CPU Cores:</b> {psutil.cpu_count()}\n" \
                       f"📊 <b>RAM:</b> {format_size(ram.used)} / {format_size(ram.total)} ({ram.percent}%)\n" \
                       f"💿 <b>Disk:</b> {format_size(disk.used)} / {format_size(disk.total)} ({disk.percent}%)"

            send_message(message)
        
        time.sleep(300)  # Wait for 5 minutes

if __name__ == "__main__":
    main()