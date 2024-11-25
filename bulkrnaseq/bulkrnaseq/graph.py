#!/usr/bin/env python3

import argparse
import os
import pathlib
import pprint
import re
import string
import sys
import logging

from dateutil import parser
import matplotlib.pyplot as plt

def get_step_times(cwl_stderr):
    step_times = dict()
    with open(cwl_stderr, 'r') as f_open:
        for line in f_open:
            if ' [step ' in line and line.endswith('start\n'):
                step_name = line.split(' [step ')[1].split(']')[0].strip()
                next_line = f_open.readline()
                if '[job ' + step_name + ']' in next_line:
                    date_str = line.split(']')[0].split('[')[-1]
                    dt = parser.parse(date_str)
                    step_times[step_name] = dict()
                    step_times[step_name]['start'] = dt
            if ' [step ' in line and line.endswith('] completed success\n'):
                step_names = sorted(list(step_times.keys()))
                if any('[step ' + sn + '] ' in line for sn in step_names):
                    step_name = line.split(' [step ')[1].split(']')[0].strip()
                    date_str = line.split(']')[0].split('[')[-1]
                    dt = parser.parse(date_str)
                    step_times[step_name]['finish'] = dt
    return step_times

def get_objs(f_open):
    obj_str = '{'
    for line in f_open:
        filtered_line = strip_ansi_codes(line)
        if filtered_line.startswith('['):
            break
        obj_str += filtered_line #.strip('\n')
    obj_str = obj_str.replace(': null', ': False')
    obj_str = obj_str.replace(': false', ': False')
    obj_str = obj_str.replace(': true', ': True')
    # print('obj_str')
    # pprint.pprint(obj_str)
    obj = eval(obj_str)
    return obj

def strip_ansi_codes(s):
    """
    >>> import blessings
    >>> term = blessings.Terminal()
    >>> foo = 'hidden'+term.clear_bol+'foo'+term.color(5)+'bar'+term.color(255)+'baz'
    >>> repr(strip_ansi_codes(foo))
    u'hiddenfoobarbaz'
    """
    return re.sub(r'\x1b\[([0-9,A-Z]{1,2}(;[0-9]{1,2})?(;[0-9]{3})?)?[m|K]?', '', s)

def get_is_file(item):
    is_file = False
    required_items = {
        'class',
        'location',
        'size',
        'basename'
    }
    keys = set(sorted(list(item.keys())))
    if required_items.issubset(set(keys)):
        if item['class'] == 'File':
            is_file = True
    return is_file
            


def get_cwl_size(item):
    total_size = 0
    # print('\nget_cwl_size()')
    # print(f'\titem')
    # pprint.pprint(item)
    if isinstance(item, dict) and get_is_file(item):
        total_size += int(item['size'])
        if 'secondaryFiles' in item:
            for secondaryFile in item['secondaryFiles']:
                if 'size' in secondaryFile:
                    total_size += int(secondaryFile['size'])
    else:
        if isinstance(item, list):
            for subitem in item:
                # print(f'\t\tsubitem: {subitem}')
                total_size += get_cwl_size(subitem)
        elif isinstance(item, dict):
            for key in sorted(list(item.keys())):
                # print(f'\t\tkey: {key}')
                # print(f'\t\tval: {item[key]}')
                if isinstance(item[key], (dict, list)):
                    total_size += get_cwl_size(item[key])
    # print('\n\n\n')
    return total_size

def get_step_storage(cwl_stderr):
    step_storage = dict()
    with open(cwl_stderr, 'r') as f_open:
        for line in f_open:
            filtered_line = strip_ansi_codes(line)
            if ' [step ' in filtered_line and filtered_line.endswith('evaluated job input to {\n'):
                step_name = filtered_line.split(' [step ')[1].split(']')[0].strip()
                if not step_name in step_storage:
                    step_storage[step_name] = dict()
                input_obj = get_objs(f_open)
                input_size = 0
                for key in sorted(list(input_obj)):
                    item = input_obj[key] 
                    if isinstance(item, (dict, list)):
                        item_size = get_cwl_size(item)
                        input_size += item_size
                step_storage[step_name]['input_size'] = input_size
            if ' [step ' in filtered_line and filtered_line.endswith('produced output {\n'):
                step_name = filtered_line.split(' [step ')[1].split(']')[0].strip()
                output_obj = get_objs(f_open)
                output_size = 0
                for key in sorted(list(output_obj)):
                    item = output_obj[key] 
                    if isinstance(item, (dict, list)):
                        item_size = get_cwl_size(item)
                        output_size += item_size
                if step_name in step_storage:
                    step_storage[step_name]['output_size'] = output_size
            if filtered_line.endswith(' [workflow ] inputs {\n'):
                step_name = 'workflow'
                if step_name == 'workflow':
                    continue
                if not step_name in step_storage:
                    step_storage[step_name] = dict()
                input_obj = get_objs(f_open)
                input_size = 0
                for key in sorted(list(input_obj)):
                    item = input_obj[key] 
                    if isinstance(item, (dict, list)):
                        item_size = get_cwl_size(item)
                        input_size += item_size
                step_storage[step_name]['input_size'] = input_size
            if filtered_line.endswith(' [workflow ] outputs {\n'):
                step_name = 'workflow'
                if step_name == 'workflow':
                    continue
                output_obj = get_objs(f_open)
                output_size = 0
                for key in sorted(list(output_obj)):
                    item = output_obj[key] 
                    if isinstance(item, (dict, list)):
                        item_size = get_cwl_size(item)
                        output_size += item_size
                step_storage[step_name]['output_size'] = output_size
            
    pprint.pformat(step_storage)
    total_input = 0
    total_output = 0
    for step_name in step_storage:
        logging.info(f'step_name: {step_name}')
        total_input += step_storage[step_name]['input_size']
        total_output += step_storage[step_name]['output_size']
    logging.info(f'total_input: {total_input}')
    logging.info(f'total_output: {total_output}')
    
    return step_storage

def get_steps_tdelta(step_times):
    steps_tdelta = dict()
    total_time = 0
    for step_name in sorted(list(step_times.keys())):
        time_delta = step_times[step_name]['finish'] - step_times[step_name]['start']
        total_time += time_delta.total_seconds()
        steps_tdelta[step_name] = time_delta
    logging.info(pprint.pformat(steps_tdelta))
    logging.info(f'total_time: {total_time}')
    return steps_tdelta

def plot(steps_tdelta, sample):
    fig, ax = plt.subplots()
    ax.bar(steps_tdelta.keys(), [x.seconds for x in steps_tdelta.values()])
    plt.xticks(fontsize=4, rotation=90)
    plt.xlabel('step')
    plt.ylabel('time (sec)')
    plt.tight_layout()
    plt.savefig(sample+'.pdf')
    return

def main():
    parser = argparse.ArgumentParser(description='create star alignment jobs')
    parser.add_argument('--cwl-stderr',
                        required=True)

    args = parser.parse_args()
    cwl_stderr = args.cwl_stderr
    sample,_ = os.path.splitext(cwl_stderr)

    step_times = get_step_times(cwl_stderr)
    steps_tdelta = get_steps_tdelta(step_times)
    plot(steps_tdelta, sample)
    steps_storage = get_step_storage(cwl_stderr)
    #pprint(steps_tdelta)
    return

if __name__ == '__main__':
    main()
