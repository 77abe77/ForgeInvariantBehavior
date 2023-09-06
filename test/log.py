import argparse
import os

def create_or_empty_file(filename):
    with open(filename, 'w') as f:
        pass

def append_to_file(filename, text):
    with open(filename, 'a') as f:
        f.write(text + '\n')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='CLI tool for managing reports.txt file.')
    parser.add_argument('--new', action='store_true', help='Create a new or empty reports.txt file.')
    parser.add_argument('--append', metavar='text', type=str, help='Append a string to the new line of the reports.txt file.')

    args = parser.parse_args()

    if args.new:
        create_or_empty_file('reports.txt')
        print('Created or emptied reports.txt.')

    if args.append:
        if not os.path.exists('reports.txt'):
            print('Error: reports.txt does not exist. Create it using --new first.')
        else:
            append_to_file('reports.txt', args.append)
            print(f'Appended "{args.append}" to reports.txt.')
