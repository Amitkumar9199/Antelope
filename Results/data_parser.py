import re
import os
import argparse
import matplotlib.pyplot as plt

def parse_data(file_path):
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as file:
        data = file.read()
        data = data.split('\n')
        result = []
        for line in data:
            if 'result:' in line:
                result.append(line.split(':')[1].strip())
    return result


def write_data(file_path, data):
    with open(file_path, 'w') as file:
        for line in data:
            file.write(line + '\n')

def plot_congestion_control(result):
    num_timestamps = len(result)
    timestamps = list(range(num_timestamps))

    plt.figure(figsize=(10, 6))
    
    # map<string, vector<int>> congestion_control_map;
    # input: cubic, westwood, bbr, cubic, bbr, cubic, bbr, bbr, bbr, bbr, westwood ...
    
    cc_map = {}

    for i, algorithm in enumerate(result):
        if algorithm not in cc_map:
            cc_map[algorithm] = [i]
        else:
            cc_map[algorithm].append(i)

    # output: {'cubic': [0, 3, 5], 'westwood': [1, 10], 'bbr': [2, 4, 6, 7, 8, 9]}
    line = []
    color = ['r', 'g', 'b', 'y', 'm', 'c', 'k']
    cc_map_color = {}
    ctr = 0
    for algorithm in result:
        if algorithm not in cc_map_color:
            cc_map_color[algorithm] = color[ctr]
            ctr += 1

    for i, algorithm in enumerate(result):
        line.append(cc_map_color[algorithm])

    #print (len(line), len(timestamps))

    # just plot the points
    # reduce the size of the points
    plt.scatter(timestamps, result, c=line, s=1)
    # plt.scatter(timestamps, result, c=line)
    plt.xlabel('Timestamp')
    plt.ylabel('Congestion Control Algorithm')
    plt.title('Congestion Control Algorithm vs Timestamp')
    plt.savefig('congestion_control.png')
    # plt.show()

def main():
    # file_path = 'sample_result.txt'
    # result = parse_data(file_path)
    # write_data('parsed_result.txt', result)

    parser = argparse.ArgumentParser(description='Parse data from a file')
    parser.add_argument('file_path', type=str, help='Path to the file to parse')
    args = parser.parse_args()
    file_path = args.file_path

    path=os.path.dirname(file_path)
    file_name=os.path.basename(file_path)

    result = parse_data(file_path)
    write_data(os.path.join(path, 'parsed_' + file_name), result)


    print('Data parsed and stored successfully')
    #print(result)
    plot_congestion_control(result)
    print('Plot generated successfully')


if __name__ == '__main__':
    main()
