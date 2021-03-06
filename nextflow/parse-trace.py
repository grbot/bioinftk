#!/usr/bin/env python3
# Reads a Nextflow trace file and calculates the total run time, CPU and memory usage
# The format of the tracefile can be seen here: https://www.nextflow.io/docs/latest/tracing.html#trace-report
# Output is printed to stdout in tabular format

from optparse import OptionParser
import pandas as pd
import re

def main():
    parser = OptionParser(usage="usage: %prog -t trace.txt")
    parser.add_option("-t", "--trace", dest="trace_file", help="Path to Nextflow trace file.")
    (options, args) = parser.parse_args()
    if not options.trace_file:
        print("No Nextflow trace file specified, please specify with the -t flag.")
        return -1

    trace_file = options.trace_file

    df = pd.read_table(trace_file)
    # Do some reformatting
    df = df.rename({'%cpu':'cpu'}, axis='columns')

    total_hours = 0.0
    total_jobs = 0
    max_cpu = 0.0
    avg_cpu = 0.0
    max_mem = 0.0
    avg_mem = 0.0

    for i in range (df.shape[0]):
        exit = df.loc[df.index[i],'exit']
        if(str(exit) == '0'):
            total_jobs+=1
            # Get duration
            duration = df.loc[df.index[i],'duration']
            pattern =  re.compile("([\d\.]*)ms")
            milliseconds = pattern.findall(duration)
            if (milliseconds):
                total_hours += (float(milliseconds[0]) / 60 / 60 / 1000)

            pattern =  re.compile("([\d\.]*)s")
            seconds = pattern.findall(duration)
            if (seconds and not seconds[0] == ''):
                total_hours += (float(seconds[0]) / 60 / 60)

            pattern = re.compile("([\d\.]*)m")
            minutes = pattern.findall(duration)
            if (minutes):
                total_hours += (float(minutes[0]) / 60)

            pattern = re.compile("([\d\.]*)h")
            hours = pattern.findall(duration)

            if (hours):
                total_hours += (float(hours[0]))

            # Get max and avg CPU
            cpu = re.sub("%","",df.loc[df.index[i],'cpu'])
            cpu = cpu.replace(",",'.')
            if (float(cpu) > max_cpu):
                max_cpu = float(cpu)
            avg_cpu = avg_cpu + float(cpu)
            # Get max and avg memory
            mem_val = 0.0
            memory = df.loc[df.index[i],'peak_rss']
            pattern = re.compile("([\d\.]*)\sB")
            b = pattern.findall(memory)
            if (b):
                mem_val = (float(b[0]) / 1000 / 1000 / 1000)

            pattern = re.compile("([\d\.]*)\sKB")
            kb = pattern.findall(memory)
            if (kb):
                mem_val = (float(kb[0]) / 1000 / 1000)

            pattern = re.compile("([\d\.]*)\sMB")
            mb = pattern.findall(memory)
            if (mb):
                mem_val = (float(mb[0]) / 1000)

            pattern = re.compile("([\d\.]*)\sGB")
            gb = pattern.findall(memory)
            if (gb):
                mem_val = (float(gb[0]))

            pattern = re.compile("([\d\.]*)\sTB")
            tb = pattern.findall(memory)
            if (tb):
                mem_val = (float(tb[0]) * 1000)

            if (mem_val > max_mem):
                max_mem = mem_val

            avg_mem = avg_mem + mem_val

    total_days = total_hours / 24
    avg_cpu = avg_cpu / total_jobs
    avg_mem = avg_mem / total_jobs

    print ("Total hours\tTotal days\tTotal jobs\tMax CPU %\tAverage CPU %\tMax memory (GB)\tAverage memory (GB)")
    print (str(round(total_hours,2)) + "\t" + str(round(total_days,2)) + "\t" + str(round(total_jobs,2)) + "\t" + str(round(max_cpu,2)) + "\t" + str(round(avg_cpu,2)) + "\t" + str(round(max_mem,2)) + "\t" + str(round(avg_mem,2)))

if __name__ == "__main__":
    main()
