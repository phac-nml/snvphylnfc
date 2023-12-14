#!/usr/bin/env python
"""
This source file was developed by Guruprasad Ananda and was included in a
nf-core pipeline for SNVPhyl developed by Jill Hagey as a work of the United
States Government, which was distributed as a work within the public domain
under the Apache Software License version 2.

This source file has been adapted to work within our pipeline.

Please refer to the README for more information.
"""

import sys, os

def stop_err(msg):
    sys.stderr.write(msg)
    sys.exit()
    
def main():
    outfile = sys.argv[1]
    infile = sys.argv[2]
    
    try:
        fout = open(sys.argv[1],'w')
    except:
        stop_err("Output file cannot be opened for writing.")
        
    try:
        fin = open(sys.argv[2],'r')
    except:
        stop_err("Input file cannot be opened for reading.")
    
    if len(sys.argv) < 4:
        os.system("cp %s %s" %(infile,outfile))
        sys.exit()
    
    cmdline = "cat %s " %(infile)
    for inp in sys.argv[3:]:
        cmdline = cmdline + inp + " "
    cmdline = cmdline + ">" + outfile
    try:
        os.system(cmdline)
    except:
        stop_err("Error encountered with cat.")
        
if __name__ == "__main__": main()