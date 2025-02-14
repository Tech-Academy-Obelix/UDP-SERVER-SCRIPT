import socket
import subprocess
import os

HOST = "0.0.0.0"
PORT = 12345
script = os.path.join(os.path.dirname(__file__), "restart.sh")

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((HOST, PORT))

print(f"UDP сървър стартиран на порт {PORT}")

while True:
    data, addr = sock.recvfrom(1024)
    print(f"Получено от {addr}: {data.decode()}")

    try:
        process = subprocess.Popen(
            [script], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
        )

        for line in process.stdout:
            print(line, end="")

        process.wait()

        if process.returncode != 0:
            print(f"Грешка при изпълнение на скрипта: {process.stderr.read()}")

    except Exception as e:
        print(f"Грешка: {e}")
