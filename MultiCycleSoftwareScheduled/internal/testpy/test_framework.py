#!/usr/bin/python
import argparse
import pathlib
import sys
import re
import os
import traceback
import glob
import shutil
import datetime
import hashlib
import mars, modelsim
from dump_compare import DumpCompare
import config_parser
from pathlib import Path
from updater import Updater

def main():
    '''
    Main method for the test framework
    '''
    # Algorithm:
    # 1) parse arguments
    # 2) vaidate what we can
    # 3) run MARS sim
    # 4) compile student vhdl
    # 5) generate hex with MARS
    # 6) sim student vhdl
    # 7) compare output

    # 1) parse arguments
    options = parse_args()
    config, env = config_parser.read_config(options['config'])

    Updater();

    if options['run-file'] is not None:
        to_run = list()
        with open (options['run-file'], 'r') as run_file:
            for line in run_file:
                if pathlib.Path(line.strip()).is_file():
                    to_run.append(line.strip())

    try:
        if os.path.exists('output'):
            shutil.rmtree('output')
        if os.path.exists('temp'):
            shutil.rmtree('temp')
    except PermissionError:
        printf('Please close all windows / files that are accessing output or temp directory')
        exit(1)

    os.makedirs('temp',exist_ok=True)
    os.makedirs('output',exist_ok=True)


    # 2) validate what we can
    missing_file = check_project_files_exist()
    if missing_file:
        print(f'\nCould not find {missing_file}')
        print('\nprogram is exiting\n')
        exit()

    if not modelsim.is_installed(config, env):
        print('\nModelsim does not seem to be installed in the expected location')
        print('\nProgram is exiting\n')
        exit()

    if not check_vhdl_present():
        print('\nOops! It doesn\'t look like you\'ve copied your processor into src')
        return


    warn_tb_checksum()

    with open('output/test_failures.txt', 'w+') as fail_list:
        if options['asm-dir'] is not None:
            for subdir, dirs, files in os.walk(options['asm-dir']):
                for f in files:
                    if f.endswith('.s'):
                        test_fail = not run_test(os.path.join(subdir, f), options, config, env)
                        print(" ")
                        if test_fail:
                            fail_list.write('{}\n'.format(os.path.join(subdir, f)))
                        if options['output-all'] or test_fail:
                            shutil.make_archive('output/{}'.format(pathlib.Path(f).name), 'zip', 'temp')
        elif options['asm-path'] is not None:
            f = options['asm-path']
            test_fail = not run_test(f, options, config, env)
            if test_fail:
                fail_list.write('{}\n'.format(f))
            if options['output-all'] or test_fail:
                shutil.make_archive('output/{}'.format(pathlib.Path(f).name), 'zip', 'temp')
        elif options['run-file'] is not None:
            for f in to_run:
                test_fail = not run_test(f, options, config, env)
                print(" ")
                if test_fail:
                    fail_list.write('{}\n'.format(f))
                if options['output-all'] or test_fail:
                    shutil.make_archive('output/{}'.format(pathlib.Path(f).name), 'zip', 'temp')
        else:
            print("No assembly file")
            exit(0)
       
    pass
        

def run_test(asm_Path, options, config, env):

    shutil.rmtree('temp')
    os.makedirs('temp')
    print("Running: {}".format(asm_Path))

    # 3) run MARS sim
    print("Starting Mars Simulation for :",asm_Path)
    options['asm-path'] = mars.run_sim(config.mars_path, asm_file=asm_Path)
    if options['asm-path'] is None:
        return False
    

    # 4) compile student vhdl
    if options['compile']:
        compile_success = modelsim.compile(config, env)
        options['compile'] = False # Don't recompile after the first compilation
        if not compile_success:
            print("Compile Failed")
            sys.exit(1)
    else:
        print('Skipping compilation')

    # 5) generate hex with MARS
    mars.generate_hex(config.mars_path, options['asm-path'] )
    
    # 6) sim student vhdl
    sim_success = modelsim.sim(config, env, timeout=options['sim-timeout'])
    if not sim_success:
        return False


    # 7) compare output
    return compare_dumps(options)

def check_vhdl_present():
    '''
    Checks if there are any VHDL files present in the src folder other than the provided
    top-level design. prints a warning if there is a file without the .vhd extension

    Returns True if other files exist
    '''
    
    src_dir = glob.glob("proj/src/**/*.vhd", recursive=True)

    expected = {'tb.vhd','mem.vhd','MIPS_Processor.vhd'}

    # return True if at least 1 new .vhd file exists
    is_student_vhd = lambda f: f.endswith('.vhd') and f not in expected
    return any((True for x in src_dir if is_student_vhd(x)))

def parse_args():
    '''
    Parse commnd line arguments into a dictionary, and return that dictionary.

    The returned dictionary has the following keys and types:
    - 'asm-path': str
    - 'max-mismatches': int > 0 
    - 'compile': bool
    '''
   
    if (os.path.exists("internal/version.txt")): 
        with open("internal/version.txt") as f:
            version = f.readlines()[0].strip()
    else:
        version="sp22.0.0"

    parser = argparse.ArgumentParser()
    parser.add_argument('--asm-file', help='Relative path from project directory to assembly file to simulate using unix style paths.')
    parser.add_argument('--asm-dir', help='Relative path from project directory to assembly directory to simulate using unix style paths.', type=check_asm_dir)
    parser.add_argument('--run-file', help='File containing one mips source path per line. All files in this set will be tested.', type=check_run_file)
    parser.add_argument('--max-mismatches', type=check_max_mismatches ,default=3, help='Number of incorrect instructions to print before the program claims failure, default=3')
    parser.add_argument('--nocompile', action='store_false',  help='flag used to disable compilation in order to save time')
    parser.add_argument('--sim-timeout',type=check_sim_timeout, default=30, help='change the ammount of time before simulation is forcefully stopped')
    parser.add_argument('--output-all', action='store_true', help='This flag only has an effect on a batch job. This will save all output, regardless of pass or fail')
    parser.add_argument('--version', action='version', version=version)
    parser.add_argument('-c', '--config', help='Which config to use. Default=Lab', default="Lab")
    args = parser.parse_args()

    options = {
        'asm-path': args.asm_file,
        'asm-dir': args.asm_dir,
        'run-file': args.run_file,
        'max-mismatches': args.max_mismatches,
        'compile': args.nocompile,
        'sim-timeout': args.sim_timeout,
        'sim-timeout': args.sim_timeout,
        'output-all' : args.output_all,
        'config'     : args.config
    }


    return options

def check_asm_dir(v):
    if not os.path.exists(v):
        raise argparse.ArgumentTypeError(f'{v} is an invalid directory')
    return v

def check_run_file(v):
    if not os.path.exists(v):
        raise argparse.ArgumentTypeError(f'{v} is an invalid file')
    return v

def check_sim_timeout(v):
    ivalue = int(v)
    if ivalue <= 0:
        raise argparse.ArgumentTypeError('--sim-timeout should be a positive integer')
    return ivalue

def check_max_mismatches(v):
    ivalue = int(v)
    if ivalue <= 0:
        raise argparse.ArgumentTypeError('--max-mismatches should be a positive integer')
    return ivalue

def check_project_files_exist():
    '''
    Returns None if all required files exist, otherwise returns path to missing file
    '''
    expected_files = [
        'internal/Mars/MARS_CPRE381.jar',
        'internal/testpy/modelsim_framework.do',
        'internal/testpy/tb.vhd',
    ]
    for path in expected_files:
        if not os.path.isfile(path):
            return path

    return None

def warn_tb_checksum():
    ''' 
    Prints a warning if the testbench has been modified according to a md5 checksum .
    Assumes file exists. Allows both LF and CRLF line endings.
    '''
    expected = {
        b'\xfd\xa8h HjQ\xc7\xc9\x19\xadt\x00\xcb\x18\xff'
        }

    # copy these lines to generate new expected checksums
    with open('internal/testpy/tb.vhd','rb') as f:
        observed = hashlib.md5(f.read()).digest()

    if observed not in expected:
        print('\n** Warning: It looks like src/tb.vhd has been modified. It will be graded using the version from the release **')
        print(f'\n ** Expected: {str(expected)} **')
        print(f'\n ** Observed: {observed} **')


def compare_dumps(options):
    '''
    Compares dumps ans prints the results to the console
    '''

    student_dump = 'temp/modelsim_dump.txt'
    mars_dump = 'temp/mars_dump.txt'

    # use user mismatches if the option was specified
    mismatches = options['max-mismatches']
    if not mismatches:
        mismatches = 3

    compare_output = [] # accumulator for dump output
    def compare_out_function(compare_line): # accepts each line of compare output and saves it to an array 
        compare_output.append(compare_line)

    dc = DumpCompare(student_dump, mars_dump, mismatches, outfunc=compare_out_function)
    compare_passed = dc.compare()
    dc.print_cpi()

    with open('temp/cpi.txt', 'w') as f:
        dc.write_cpi(f)

    # print compare to console
    for line in compare_output:
        print(line)

    # print compare to file
    try:
        with open('temp/compare.txt','w') as f:
            f.writelines((f'{x}\n' for x in compare_output)) # map each line to itself + line endings
    except:
        print('** Warning: failed to write comparison file temp/compare.txt **')

    return compare_passed


def log_exception():
    ''' Writes the last exception thrown to the error log file'''
    
    with open('temp/errors.log','a+') as f:
        f.write(f'\nException caught at {datetime.datetime.now()}:\n')
        traceback.print_exc(file=f)

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt: #exit gracefully since this is common
        exit(1)
    except Exception:
        log_exception()
        print('Program exited with unexpected exception.')
        print('Please post to the Project Testing Framework discussion, and attach temp/errors.log')


