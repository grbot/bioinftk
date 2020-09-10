#!/usr/bin/env python3
# Reads a Nextflow trace log and pulls out the command executed and also the total execution time
# Output is printed to stdout

from optparse import OptionParser
from datetime import datetime
import re

def main():
    parser = OptionParser(usage="usage: %prog -l nextflow.log")
    parser.add_option("-l", "--log", dest="log_file", help="Path to Nextflow log file.")
    (options, args) = parser.parse_args()
    if not options.log_file:
        print("No Nextflow log file specified, please specify with the -l flag.")
        return -1

    log_file = options.log_file

    dt_start = datetime.now();
    dt_end = datetime.now();
    cmd = ""

    with open(log_file) as fd:
        line = fd.readline()
        while line:
            # Get start
           m = re.search("nextflow\.cli\.Launcher", line)
           if(m):
              m2 = re.search("\$> (.*)",line)
              cmd = m2[1]
              m2 = re.search("(^.*) \[main\]",line)
              date_start = m2[1]
              dt_tmp = datetime.strptime(date_start, "%b-%d %H:%M:%S.%f")
              # Hack use this year
              dt_start = datetime(datetime.now().year,dt_tmp.month,dt_tmp.day,dt_tmp.hour,dt_tmp.minute,dt_tmp.second,dt_tmp.microsecond)

           # Get end
           m = re.search("Execution complete -- Goodbye", line)
           if(m):
              m2 = re.search("(^.*) \[main\]",line)
              date_end = m2[1]
              dt_tmp = datetime.strptime(date_end, "%b-%d %H:%M:%S.%f")
              # Hack use this year
              dt_end = datetime(datetime.now().year,dt_tmp.month,dt_tmp.day,dt_tmp.hour,dt_tmp.minute,dt_tmp.second,dt_tmp.microsecond)
           line = fd.readline()


    print ("Command: ", cmd)
    print ("Execution time: ", dt_end - dt_start)

if __name__ == "__main__":
    main()
