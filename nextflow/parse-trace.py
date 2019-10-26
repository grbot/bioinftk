#!/usr/bin/env python3.6
# Reads a Nextflow trace.txt file and calculates the total run time
# The format of the tracefile can be seen here: https://www.nextflow.io/docs/latest/tracing.html#trace-report
# Output is printed to stdout

from optparse import OptionParser
import pandas as pd
import re

def main():
    parser = OptionParser(usage="usage: %prog -t trace.txt")
    parser.add_option("-t", "--trace", dest="trace_file", help="Path to Nextflow trace filed.")
    (options, args) = parser.parse_args()
    if not options.trace_file:
        print("No Nextflow trace file specified, please specify with the -t flag.")
        return -1

    trace_file = options.trace_file

    df = pd.read_table(trace_file)

    total_hours = 0.0
    for i in range (df.shape[0]):
        exit = df.loc[df.index[i],'exit']
        if(str(exit) == '0'):
            duration = df.loc[df.index[i],'duration']
            pattern = re.compile("(\d*)s")
            seconds = pattern.findall(duration)
            if (seconds):
                total_hours += (float(seconds[0]) / 60 / 60)

            pattern = re.compile("(\d*)m")
            minutes = pattern.findall(duration)
            if (minutes):
                total_hours += (float(minutes[0]) / 60)

            pattern = re.compile("(\d*)h")
            hours = pattern.findall(duration)
            if (hours):
                total_hours += (float(hours[0]))

    print ("Total hours: " + str(total_hours))
    total_days = total_hours / 24
    print ("Total days: " + str(total_days))

if __name__ == "__main__":
    main()
