import time
from datetime import datetime
import sys
import os
import re
import matplotlib.pyplot as plt
import numpy as np
from math import sqrt



def main():
    experimentID = sys.argv[1]
    noOfClients = sys.argv[2]
    repeatN = sys.argv[3]

    taus = {}
    t0 = 0
    t1 = 0
    nLine = 0

    lastSecond = 0
    currentSecond = 0
    nbSeconds = 0


    pathMW='../experiments/'+experimentID+'/'+noOfClients+'/'+repeatN+'/MW'

    if not os.path.exists(pathMW+'/../../stats'):
        os.makedirs(pathMW+'/../../stats')

    with open(pathMW+'/allMW.log', 'r') as mw_file:
      
        for line in mw_file:
            line = line.strip()
            lineArray = line.split(' ')
            if "POPING_QUERY" in line:
                timestamp = lineArray[0]+" "+lineArray[1]
                if nLine == 0:
                    t0 = datetime.strptime(timestamp, "%d/%m/%Y %H:%M:%S,%f")
                    nLine+=1
                else:
                    t1 = datetime.strptime(timestamp, "%d/%m/%Y %H:%M:%S,%f")
                    tau = (t1 - t0).microseconds / 1000
                    if (t1 - t0).seconds>0:
                        print t1 - t0
                    t0 = t1
                  
                    if tau not in taus.keys():
                        taus[tau] = 1
                    else:
                        taus[tau] = taus[tau] + 1
                    nLine = nLine + 1
                    #print taus


        
        mw_file.close()

    totalTaus = 0
    meanTau = 0.0 
    for ms in taus.keys():
        totalTaus += taus[ms]
        meanTau += ms*taus[ms]
    meanTau = meanTau / totalTaus

    arrivalRate = 1.0/(meanTau/1000)


    allClientStats = open(pathMW+'/../../stats/arrival_rate.stat', 'a')
    allClientStats.write('E[tau]_ms:\t'+`meanTau`+'\tArrival_rate_rps:\t'+`arrivalRate`)
    allClientStats.write('\n')
    allClientStats.write('Distribution:\n')
    for ms in taus.keys():
        allClientStats.write(`ms`+'\t'+`taus[ms]`+'\n')
    allClientStats.close()

    # xaxis = list(xrange(len(rtSec_trunc)))

    # plt.plot(xaxis, rtSec_trunc, linestyle='-', marker='None')
    # plt.title('Client ResponseTime Trace : #Clients='+noOfClients+', WL='+workload+', IN='+inThread+', OUT='+outThread+', MW='+noOfMW+', POOL='+poolSize)
    # plt.ylabel('ResponseTime [ms]')
    # plt.xlabel('Time [s]')
    # plt.margins(0.1)
    # plt.savefig(pathClients+'/../../stats/client_rt_trace_'+repeatN+'.png', bbox_inches='tight')
    # #plt.show()

if __name__ == "__main__":
    main()




