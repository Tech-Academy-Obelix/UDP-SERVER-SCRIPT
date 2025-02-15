import socket
import subprocess
import os

HOST = "0.0.0.0"
PORT = 12345
SCRIPT_PATH = os.path.join(os.path.dirname(__file__), "restart.sh")


def run_script():
    try:
        process = subprocess.Popen(
            [SCRIPT_PATH], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
        )

        # Stream script output
        for line in process.stdout:
            print(line, end="")

        process.wait()

        if process.returncode != 0:
            print(f"Грешка при изпълнение на скрипта: {process.stderr.read()}")

    except Exception as e:
        print(f"Грешка: {e}")


def udp_server():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((HOST, PORT))

    print(f"UDP сървър стартиран на порт {PORT}")

    try:
        while True:
            data, addr = sock.recvfrom(1024)
            message = data.decode().strip()
            print(f"Получено от {addr}: {message}")

            if message == "update":
                print("Изпълняване на скрипта за обновление...")
                run_script()
            else:
                print("Непозната команда!")

    except KeyboardInterrupt:
        print("\nСпиране на сървъра...")
    finally:
        sock.close()


if __name__ == "__main__":
    udp_server()

