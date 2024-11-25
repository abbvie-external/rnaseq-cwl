import argparse
from pathlib import Path
import csv

def convert_yml_csv(input_yml: Path, output_csv: Path):
    """ Convert yml file to csv file
    Args:
        input_yml: yaml file with comments
        output_csv:  csv file with comments extracted from yml file
    """

    with open(input_yml) as input_f:
        lines = [line.strip() for line in input_f]

    option = d_type = description = default = required = None
    csv_table = []
    for line in lines:
        content = ''.join(filter(str.isalnum, line)).lower()
        if line.startswith('###'):
            if option is not None:
                parameter = {'Option': option, 'Type': d_type, 'Description': description, 'Default': default, 'Required': required}
                csv_table.append(parameter)
            option = d_type = description = default = required = None
            start_index = 0
        elif line.lstrip('#').strip().startswith('[') and line.endswith(']'):
            start_index = 1
            if content == 'required':
                required = True
            elif content == 'optional':
                required = False
            elif content != 'optional' or 'required':
                raise ValueError('Not specify Optional or required inside []')
        elif start_index == 1:
            if len(line.split(',')) < 2:
                raise ValueError('Type and Default line are separated by , and have two items')
            else:
                d_type = line.split(',')[0].lstrip('#').strip()
                default = line.split(',')[1].split('=')[1]
            start_index = start_index + 1
        elif line.startswith('#'):
            description = (description if description else '') + '\n' + line.lstrip('#')
        elif not line.startswith('#') and content != '' and line.strip()[0].isalnum() :
            option = line.split(':')[0]

    headers = ['Option', 'Required', 'Type', 'Default', 'Description']
    with open(output_csv, 'w', newline='') as output_file:
        writer = csv.writer(output_file)
        writer.writerow(headers)
        for i in range(len(csv_table)):
            writer.writerow([csv_table[i][x] for x in headers])




def arg_parser() -> argparse.ArgumentParser:
    """Parse arguments

    Returns:
        parser: ArgumentParser object
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input_yml', type=Path, help='input yml file', required=True)
    parser.add_argument('-o', '--output_csv', type=Path, help='output csv file', required=True)
    return parser


def run(input_yml: Path, output_csv: Path):
    """Launch conversion for yaml file to csv table so the csv table can be loaded by sphinx as a html table

    Args:
        input_yml: baseline result directory
        output_csv:  testing result directory

    """
    convert_yml_csv(input_yml, output_csv)

# Launch yml to csv table conversion
if __name__ == '__main__':
    args = arg_parser().parse_args()
    run(Path(args.input_yml), Path(args.output_csv))
