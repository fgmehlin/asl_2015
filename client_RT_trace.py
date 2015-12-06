from __future__ import division
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
    inThread = sys.argv[3]
    outThread = sys.argv[4]
    noOfMW = sys.argv[5]
    poolSize = sys.argv[6]
    workload = sys.argv[7]
    repeatN = sys.argv[8]

    pathClients='../experiments/'+experimentID+'/'+noOfClients+'/'+repeatN+'/C'

    rtSec = []


    if not os.path.exists(pathClients+'/../../stats'):
        os.makedirs(pathClients+'/../../stats')

    with open(pathClients+'/allclients', 'r') as client_file:
        sumRTSec = 0.0
        rtCnt = 0
        nbSecs = 0
        delta = float(1.0)
        curT = float(0.0)

        for line in client_file:
            line = line.strip()
            lineArray = line.split(' ')
            #if "RESPONSE" in line and 'false' not in line and 'ERROR' not in line and 'False' not in line and 'FALSE' not in line:
            if "RESPONSE" in line:
                timestamp = lineArray[0]+" "+lineArray[1]
                rt = int(lineArray[7])/1000000
                sumRTSec += rt
                rtCnt += 1
                t = time.mktime(datetime.strptime(timestamp, "%d/%m/%Y %H:%M:%S,%f").timetuple())
                if rt > 1000:
                    print line
                delta = t - curT
                if delta >= 1.0:
                    if rtCnt > 1:
                        nbSecs+=1
                        #print nbSecs
                        rtSec.append(sumRTSec/rtCnt)
                        #print sumRTSec/rtCnt
                        rtCnt = 0
                        sumRTSec = 0.0
                    curT = t
                    delta = 0.0

        
        client_file.close()

    rtSec_trunc = rtSec[120:len(rtSec)-30]

    stop = len(rtSec)-30
    
    nsamples = len(rtSec_trunc)

    #rtMean = np.mean(rtSec_trunc, axis=0)
    rtMean = np.mean(rtSec_trunc)
    #rtSD = np.std(rtSec_trunc, axis=0)

    with open(pathClients+'/allclients', 'r') as client_file:
        sumRTSec = 0.0
        rtCnt = 0
        nbSecs = 0
        delta = float(1.0)
        curT = float(0.0)
        tmpSTD = 0.0
        lc = 0

        for line in client_file:
            line = line.strip()
            lineArray = line.split(' ')
            if "RESPONSE" in line and 'false' not in line and 'ERROR' not in line and 'False' not in line and 'FALSE' not in line:
                timestamp = lineArray[0]+" "+lineArray[1]
                rt = int(lineArray[7])/1000000
                lc +=1
                t = time.mktime(datetime.strptime(timestamp, "%d/%m/%Y %H:%M:%S,%f").timetuple())
                delta = t - curT
                if delta >= 1.0:
                    if lc > 1:
                        nbSecs+=1
                        print 'nbSecs %d' % nbSecs
                        curT = t
                        delta = 0.0
                
                if nbSecs>=120 and nbSecs < stop:
                    rtCnt += 1
                    tmp = (rt-rtMean) **2
                   # print 'rt : %d' % rt
                    #print 'rt - rtMean **2 :  %d ' % tmp
                    tmpSTD += tmp


        client_file.close()

    print 'rtCnt %d' % rtCnt
    rtSD = sqrt(tmpSTD/rtCnt)

    print 'length'
    print len(rtSec_trunc)

    # Truncate database warmup (60s) and cooldown (30s)


    allClientStats = open(pathClients+'/../../stats/clients_RT.stat', 'a')
    allClientStats.write(noOfClients+'\t'+`rtCnt`+'\t'+repeatN+'\t'+`rtMean`+'\t'+`rtSD`)
    allClientStats.write('\n')
    allClientStats.close()

    xaxis = list(xrange(len(rtSec_trunc)))

    plt.plot(xaxis, rtSec_trunc, linestyle='-', marker='None')
    plt.title('Client ResponseTime Trace : #Clients='+noOfClients+', WL='+workload+', IN='+inThread+', OUT='+outThread+', MW='+noOfMW+', POOL='+poolSize)
    plt.ylabel('ResponseTime [ms]')
    plt.xlabel('Time [s]')
    plt.margins(0.1)
    plt.savefig(pathClients+'/../../stats/client_rt_trace_'+repeatN+'.png', bbox_inches='tight')
    #plt.show()

if __name__ == "__main__":
    main()




