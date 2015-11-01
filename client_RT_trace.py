import time
from datetime import datetime
import sys
import os
import re
import matplotlib.pyplot as plt



def main():
    experimentID = sys.argv[1]
    noOfClients = sys.argv[2]
    inThread = sys.argv[3]
    outThread = sys.argv[4]
    noOfMW = sys.argv[5]
    poolSize = sys.argv[6]
    workload = sys.argv[7]

    pathClients='../experiments/'+experimentID+'/'+noOfClients+'/C'

    rtSec = []


    if not os.path.exists(pathClients+'/stats'):
        os.makedirs(pathClients+'/stats')

    with open(pathClients+'/allclients', 'r') as client_file:
        sumRTSec = 0.0
        rtCnt = 0
        nbSecs = 0
        delta = float(1.0)
        curT = float(0.0)

        for line in client_file:
            line = line.strip()
            lineArray = line.split(' ')
            if "RESPONSE" in line and 'false' not in line and 'ERROR' not in line and 'False' not in line and 'FALSE' not in line:
                timestamp = lineArray[0]+" "+lineArray[1]
                rt = int(lineArray[7])
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
                        print sumRTSec/rtCnt
                        rtCnt = 0
                        sumRTSec = 0.0
                    curT = t
                    delta = 0.0

        
        client_file.close()

    # Truncate database warmup (60s) and cooldown (30s)
    rtSec_trunc = rtSec[180:len(rtSec)-30]

    xaxis = list(xrange(len(rtSec_trunc)))

    plt.plot(xaxis, rtSec_trunc, linestyle='-', marker='None')
    plt.title('Client ResponseTime Trace : #Clients='+noOfClients+', WL='+workload+', IN='+inThread+', OUT='+outThread+', MW='+noOfMW+', POOL='+poolSize)
    plt.ylabel('ResponseTime [ms]')
    plt.xlabel('Time [s]')
    plt.margins(0.1)
    plt.savefig(pathClients+'/client_rt_trace.png', bbox_inches='tight')
    #plt.show()

if __name__ == "__main__":
    main()




