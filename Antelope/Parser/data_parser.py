# write a python script that will parse the sample_result.txt and store the result row in a separate file

# countIndex: 0 rtt: 8834.142857142857
# npData [[4.00000000e+02 9.22000000e+02 8.83414286e+03 0.00000000e+00
#   2.25000000e+02 0.00000000e+00 2.96358724e+07]]
# cc::0
# cc::1
# cc::2
# predic: [0.0005832406459376216] cc:0
# predic: [0.00013927592954132706] cc:2
# predic: [0.009714688174426556] cc:1
# result:cubic
# ipKey: 4254509248 ip predic: 1
# {4254509248: [0.0, 1.0, 0.0, 0.0]}
# Updated 'cong_map' and 'ip_cong_map' successfully
# countIndex: 1 rtt: 4726.714285714285
#  meanRTT: 4726.714285714285 minRTT: 338 rtt: 4726.714285714285 max: 225.0
# npData [[3.38000000e+02 5.64000000e+02 4.72671429e+03 0.00000000e+00
#   1.80000000e+00 0.00000000e+00 5.44496605e+07]]
# cc::0
# cc::1
# cc::2
# predic: [5.650308958138339e-05] cc:0
# predic: [8.838403300615028e-05] cc:2
# predic: [3.641456351033412e-05] cc:1
# result:westwood

# output: cubic, westwood, ...

import re
import os
import argparse

def parse_data(file_path):
    with open(file_path, 'r') as file:
        data = file.read()
        data = data.split('\n')
        result = []
        for line in data:
            if 'result:' in line:
                result.append(line.split(':')[1])
    return result

def write_data(file_path, data):
    with open(file_path, 'w') as file:
        for line in data:
            file.write(line + '\n')

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

if __name__ == '__main__':
    main()