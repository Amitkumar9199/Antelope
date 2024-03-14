import socket
import random
import time
import argparse

def generate_random_data(length):
    return bytes(random.randint(0, 255) for _ in range(length))

def server(host, port):
    # print the absolute ip address of the server
    # print(socket.gethostbyname(socket.gethostname()))

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server_socket:
        # print("hi")
        server_socket.bind((host, port))
        # print("Bye")
        server_socket.listen(1)
        print(f"Server listening on {host}:{port}")
        connection, address = server_socket.accept()
        print(f"Connection established from {address}")
        
        while True:
            # Generate random data of variable length (1 to 100 bytes)
            data_length = random.randint(1, 100)
            random_data = generate_random_data(data_length)
            connection.sendall(random_data)
            print(f"Sent {data_length} bytes of random data to client")
            time.sleep(1)  # Adjust the sending interval as needed

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--ip', '-ip', help='IP Address')
    parser.add_argument('--port', '-p', help='Port Number')
    arg = parser.parse_args()
    port = int(arg.port)
    ip = arg.ip
    server(ip, port)
    # server("localhost", port)  # Use the IP address of h1 and an available port

# ip addr