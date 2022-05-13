import subprocess
import os

def generate_hex(mars_path, asm_file_path):
    '''
    uses mars to generate:
        - temp/imem.hex
        - temp/dmem.hex

    accepts path to assembly file as input and does no error checking because the simulation
    should have been run first guarenteeing the program will assemble.
    '''

    # Use check_output instead of call to supress output
    subprocess.check_output(
        ['java','-jar',mars_path,'a','dump','.text','HexText','temp/imem.hex',asm_file_path],
        )

    # create the dump file in case no data mem dump is generated
    open('temp/dmem.hex','w').close()

    # Use check_output instead of call to supress output
    subprocess.check_output(
        ['java','-jar',mars_path,'a','dump','.data','HexText','temp/dmem.hex',asm_file_path],
        )

    # I am not concerned with error codes since we have a guarentee the simulation runs from run_mars_sim()

    
def run_sim(mars_path, asm_file, timeout=30):
    '''
    Simulates Assembly file in MARS. Guarentees that a valid assembly file is given or else it
    will call continue to prompt user.

    Returns the path to the correct assembly file.
    '''

    # Try again if invalid file was provided
    if not os.path.isfile(asm_file):
        print(f'Invalid path to assembly file: {asm_file}\n')
        exit(1)

    # open in write mode
    with open('temp/mars_dump.txt','w') as f:
        exit_code = subprocess.call(
            ['timeout', str(timeout), 'java','-jar',mars_path,'nc', 'ar',asm_file],
            stdout=f
            )

    if exit_code == 124:
        print("Mars simulation timed out. Please check code for infinite loops")
        return None

    # Re-opens temp/mars_dump.txt to check for errors
    mars_err = check_mars_dump()

    if mars_err:
        # if there is an issue, with the sim, we should call this method again recursively

        print('\nAssembly file did not correctly simulate in Mars:')
        print(mars_err)
        return None

    else:
        return asm_file


def check_mars_dump():
    '''
    Checks the Mars Dump to ensure that no errors occourred
    Returns None if no error occourred, a string otherwise
    '''

    # Mars does not seem provide non-zero error codes, so we need to look at the dump to check for errors
    # We defensively check for the assembly file not existing, so an invalid argument should not be possible
    # This method scans the dump and checks for lines starting with 'Error '

    # for each line, check if it starts with error
    with open('temp/mars_dump.txt') as f:
        for line in f:
            if line.startswith('Error '):
                return line.rstrip()

    return None
