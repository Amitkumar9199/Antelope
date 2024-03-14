import socket
import argparse

def client(host, port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as client_socket:
        client_socket.connect((host, port))
        print(f"Connected to {host}:{port}")

        while True:
            data = client_socket.recv(1024)  # Receive data from the server
            if not data:
                break
            print(f"Received {len(data)} bytes of data from server")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--ip', '-ip', help='IP Address')
    parser.add_argument('--port', '-p', help='Port Number')
    arg = parser.parse_args()
    port = int(arg.port)
    ip = arg.ip
    client(ip, port)  # Use the IP address of h1 and the port used by the server