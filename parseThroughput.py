import time
from datetime import datetime
import sys
import os
from math import sqrt
import re
import numpy as np





experimentID = sys.argv[1]
noOfClients = sys.argv[2]
noOfMW = sys.argv[3]
pathMiddleware='/Users/florangmehlin/Documents/ETHZ/Advanced Systems Lab_2015/project_repo/'+experimentID+'/MW'

def writeEachMW(mw, mu, sigma):
    with open(pathMiddleware+'/stats/eachMW.stat', 'a') as f:
        f.write(mw+'\t'+`mu`+'\t'+`sigma`)
        f.write('\n')
        f.close()

requestsCnt = 0
mwID = 0

mu_TP = 0.0
mu_TP_MW = []

sigma_TP = 0.0
sigma_TP_MW = []

throughputSec = []

for i in range(0, int(noOfMW)):
    throughputSec.append([])

if not os.path.exists(pathMiddleware+'/stats'):
    os.makedirs(pathMiddleware+'/stats')

for dir_entry in os.listdir(pathMiddleware):
    dir_entry_path = os.path.join(pathMiddleware, dir_entry)

    if os.path.isfile(dir_entry_path) and dir_entry != '.DS_Store' and dir_entry != 'allMW':
        mwID = re.findall(r'\d', dir_entry)[:1][0]


        with open(dir_entry_path, 'r') as mw_file:
            print(dir_entry)
            lineCnt = 0
            requestsCnt = 0
            delta = float(1.0)
            curT = float(0.0)

            # Compute mean of response time for 1 client
            for line in mw_file:
                line = line.strip()
                lineArray = line.split(' ')
                if "PUTTING_REPLY" in line and 'ERROR' not in line and 'null' not in line and '-99' not in line:
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

TP_flatten = [item for sublist in throughputSec for item in sublist]

mu_TP = np.array(TP_flatten).mean()
sigma_TP = np.array(TP_flatten).std()
     

for i in range(0, int(noOfMW)):
    print 'middleware %d, mean=%.5f, std=%.5f' % (i, np.array(throughputSec[i]).mean(), np.array(throughputSec[i]).std())
    writeEachMW('middleWare_'+`i+1`, np.array(throughputSec[i]).mean(), np.array(throughputSec[i]).std())




allMWStats = open(pathMiddleware+'/stats/allMW.stat', 'w')
allMWStats.write(noOfClients+'\t'+`mu_TP`+'\t'+`sigma_TP`)
allMWStats.write('\n')
allMWStats.close()




