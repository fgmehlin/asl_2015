import time
from datetime import datetime
import sys
import os
import re
import matplotlib.pyplot as plt



def main():
    experimentID = sys.argv[1]
    inThread = sys.argv[2]
    outThread = sys.argv[3]
    noOfMW = sys.argv[4]
    poolSize = sys.argv[5]

    for i in [2, 4, 6, 8, 10]:
        noOfClients = i*6

        pathDatabase='../experiments/'+`experimentID`+'/'+`noOfClients`+'/DB'



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
        plt.title('Database Performance : #Clients='+noOfClients+', IN='+inThread+', OUT='+outThread+', MW='+noOfMW+', POOL='+poolSize)
        plt.ylabel('Transactions per second')
        plt.xlabel('Time [s]')
        plt.margins(0.1)
        plt.savefig(pathDatabase+'/db_performance.png', bbox_inches='tight')
        #plt.show()

if __name__ == "__main__":
    main()




