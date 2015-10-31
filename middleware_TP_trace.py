import time
from datetime import datetime
import sys
import os
from math import sqrt
import re
import numpy as np
import matplotlib.pyplot as plt


def main():
    experimentID = sys.argv[1]
    noOfClients = sys.argv[2]
    inThread = sys.argv[3]
    outThread = sys.argv[4]
    noOfMW = sys.argv[5]
    poolSize = sys.argv[6]


    requestsCnt = 0
    mwID = 0

    mu_TP = 0.0
    mu_TP_MW = []

    sigma_TP = 0.0
    sigma_TP_MW = []

    throughputSec = []

    for i in range(0, int(noOfMW)):
        throughputSec.append([])

    pathMiddleware='../experiments/'+experimentID+'/'+noOfClients+'/MW'

    if not os.path.exists(pathMiddleware+'/stats'):
        os.makedirs(pathMiddleware+'/stats')

    for dir_entry in os.listdir(pathMiddleware):
        dir_entry_path = os.path.join(pathMiddleware, dir_entry)

        if os.path.isfile(dir_entry_path) and dir_entry != '.DS_Store' and dir_entry != 'allMW' and 'full' in dir_entry:
            mwID = re.findall(r'\d', dir_entry)[:1][0]


            with open(dir_entry_path, 'r') as mw_file:
                print(dir_entry)
                lineCnt = 0
                requestsCnt = 0
                delta = float(1.0)
                curT = float(0.0)

                for line in mw_file:
                    line = line.strip()
                    lineArray = line.split(' ')
                    if "PUTTING_REPLY" in line and 'ERROR' not in line and '-99' not in line:
                        timestamp = lineArray[0]+" "+lineArray[1]
                        t = time.mktime(datetime.strptime(timestamp, "%d/%m/%Y %H:%M:%S,%f").timetuple())
                        delta = t - curT
                        if delta >= 1.0:
                            if requestsCnt > 0:
                                throughputSec[(int(mwID)-1)].append(requestsCnt)
                            curT = t
                            delta = 0.0
                            requestsCnt = 0
                        requestsCnt += 1
                        lineCnt += 1
                
                mw_file.close()

    minlen = 999999999

    for i in range(0, int(noOfMW)):
        xaxis_len = len(throughputSec[i])
        if(minlen > xaxis_len):
            minlen = xaxis_len



    for i in range(0, int(noOfMW)):
        throughputSec[i] = throughputSec[i][0:minlen]
        xaxis = list(xrange(len(throughputSec[i])))
        plt.plot(xaxis, throughputSec[i], linestyle='-', marker='None')
        plt.title('Middleware #'+`(i+1)`+' Throughput Trace : #Clients='+noOfClients+', IN='+inThread+', OUT='+outThread+', MW='+noOfMW+', POOL='+poolSize)
        plt.ylabel('Throughput')
        plt.xlabel('Time [s]')
        plt.margins(0.1)
        plt.savefig(pathMiddleware+'/middleware'+`i`+'_tp_trace.png', bbox_inches='tight')
        plt.clf()


    plt.title('All Middlewares Throughput Trace : #Clients='+noOfClients+', IN='+inThread+', OUT='+outThread+', MW='+noOfMW+', POOL='+poolSize)
    plt.ylabel('Throughput')
    plt.xlabel('Time [s]')
    plt.margins(0.1)
    xaxis = list(xrange(len(throughputSec[i])))

    mwIDs = list(xrange(int(noOfMW)+1))
    mwIDs[len(mwIDs)-1] = 'Mean'

    for i in range(0, int(noOfMW)):
        plt.plot(xaxis, throughputSec[i], linestyle='-', marker='None')

    mu_TP= np.mean(throughputSec,axis=0)
    plt.plot(xaxis, mu_TP, linestyle='-', marker='None')
    plt.legend(mwIDs, loc='lower right')
    plt.savefig(pathMiddleware+'/all_middlwares_tp_trace.png', bbox_inches='tight')



if __name__ == "__main__":
    main()



