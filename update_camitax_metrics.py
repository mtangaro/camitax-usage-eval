#!/usr/bin/env python

import pandas as pd
import subprocess
import argparse
import os
import time

#______________________________________
def cli_options():

  parser = argparse.ArgumentParser(description='Get nextflow pid')

  parser.add_argument('-p', '--pid', dest='nxpid', help='nextflow pid')

  return parser.parse_args()

#________________________________
def run_command(cmd):
    """
    Run subprocess call redirecting stdout, stderr and the command exit code.
    """
    proc = subprocess.Popen( args=cmd, shell=True,  stdout=subprocess.PIPE, stderr=subprocess.PIPE )
    communicateRes = proc.communicate()
    stdout, stderr = communicateRes
    status = proc.wait()
    return stdout, stderr, status


#______________________________________
def get_values():

    cmd = '/usr/bin/bash /data/compute_docker_total_stats.sh'
    stdout, stderr, status = run_command(cmd)

    cpu = stdout.split(b'|')[0].decode("utf-8")
    memory = stdout.split(b'|')[1].decode("utf-8").rstrip()

    return cpu, memory
#______________________________________
def is_running(pid):        
    try:
        os.kill(pid, 0)
    except OSError:
        return False
    return True

#______________________________________
def update_camitax_metrics():

    # initialize data of lists.
    data = { 'sample_milliseconds': ['0'], 'cpu_percentages': ['0'], 'memory_bytes': ['0'] }

    # Create DataFrame
    df = pd.DataFrame(data, index=[0])

    options = cli_options()
    nxpid = int(options.nxpid)
    print(nxpid)

    # Get values
    start_time = time.time()
    while is_running(nxpid) == True:
        cpu, mem = get_values()
        now = time.time()
        deltat = (now - start_time)*1000
        print("sample_milliseconds: ", deltat)
        print("cpu_percentages: ", cpu)
        print("memory_bytes: ", mem)

        # Append Dict as row to DataFrame
        metrics = { 'sample_milliseconds': deltat, 'cpu_percentages': cpu, 'memory_bytes': mem }
        dftemp = pd.DataFrame(metrics, index=[0])
        df = pd.concat([df, dftemp], ignore_index=True)
        print(df)
        del dftemp

    # Save dataframe
    df.to_csv('camitax_metrics.csv')

#______________________________________
if __name__ == "__main__":
   update_camitax_metrics()
