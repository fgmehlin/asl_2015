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

    pathClients='../experiments/'+experimentID+'/'+noOfClients+'/C'

    rtSec = []


    if not os.path.exists(pathClients+'/stats'):
        os.makedirs(pathClients+'/stats')

    with open(pathClients+'/allclients', 'r') as client_file:
        sumRTSec = 0.0
        rtCnt = 0
        delta = float(1.0)
        curT = float(0.0)

        for line in client_file:
            line = line.strip()
            lineArray = line.split(' ')
            if "RESPONSE" in line:
                timestamp = lineArray[0]+" "+lineArray[1]
                rt = int(lineArray[7])
                sumRTSec += rt
                rtCnt += 1
                t = time.mktime(datetime.strptime(timestamp, "%d/%m/%Y %H:%M:%S,%f").timetuple())
                delta = t - curT
                if delta >= 1.0:
                    if rtCnt > 1:
                        rtSec.append(sumRTSec/rtCnt)
                        rtCnt = 0
                        sumRTSec = 0.0
                    curT = t
                    delta = 0.0

        
        client_file.close()

    xaxis = list(xrange(len(rtSec)))

    plt.plot(xaxis, rtSec, linestyle='-', marker='None')
    plt.title('Server Latency Trace : #Clients='+noOfClients+', IN='+inThread+', OUT='+outThread+', MW='+noOfMW+', POOL='+poolSize)
    plt.ylabel('Latency [ms]')
    plt.xlabel('Time [s]')
    plt.margins(0.1)
    plt.savefig(pathClients+'/server_latency_trace.png', bbox_inches='tight')
    #plt.show()

if __name__ == "__main__":
    main()




