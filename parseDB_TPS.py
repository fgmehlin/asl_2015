import time
from datetime import datetime
import sys
import os
import re
import matplotlib.pyplot as plt





experimentID = sys.argv[1]
noOfClients = sys.argv[2]
pathDatabase='/Users/florangmehlin/Documents/ETHZ/Advanced Systems Lab_2015/experiments/'+experimentID+'/'+noOfClients+'/DB'



requestsCnt = 0
throughputSec = []


if not os.path.exists(pathDatabase+'/stats'):
    os.makedirs(pathDatabase+'/stats')

with open(pathDatabase+'/db.out', 'r') as db_file:
    lineCnt = 0
    requestsCnt = 0
    delta = float(1.0)
    curT = float(0.0)

    for line in db_file:
        line = line.strip()
        lineArray = line.split(' ')
        if "execute" in line:
            timestamp = lineArray[0]+" "+lineArray[1]
            t = time.mktime(datetime.strptime(timestamp, "%Y-%m-%d %H:%M:%S.%f").timetuple())
            delta = t - curT
            if delta >= 1.0:
                if requestsCnt > 0:
                    throughputSec.append(requestsCnt)
                curT = t
                delta = 0.0
                requestsCnt = 0
            requestsCnt += 1
            lineCnt += 1
    
    db_file.close()

db_TPS = open(pathDatabase+'/stats/DB_TPS.stat', 'w')
for i in range(0, len(throughputSec)):
    db_TPS.write(`i+1`+'\t'+`throughputSec[i]`)
    db_TPS.write('\n')

db_TPS.close()

xaxis = list(xrange(len(throughputSec)))

plt.plot(xaxis, throughputSec, linestyle='None', marker='o')
plt.ylabel('Transaction per seconds')
plt.xlabel('Time [s]')
plt.margins(0.1)
plt.savefig(pathDatabase+'/db_performance.png', bbox_inches='tight')
#plt.show()




