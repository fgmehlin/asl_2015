from __future__ import division
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
    noOfMW = sys.argv[3]
    repeatN = sys.argv[4]

    clientsPerMW = int(noOfClients)/int(noOfMW)


    sum_RT = 0.0
    cnt_RT = 0.0

    requestsCnt = 0
    mwID = 0


    pathMiddleware='../experiments/'+experimentID+'/'+noOfClients+'/'+repeatN+'/MW'

    if not os.path.exists(pathMiddleware+'/../../stats'):
        os.makedirs(pathMiddleware+'/../../stats')

    for dir_entry in os.listdir(pathMiddleware):
        dir_entry_path = os.path.join(pathMiddleware, dir_entry)

        if os.path.isfile(dir_entry_path) and dir_entry != '.DS_Store' and dir_entry != 'allMW.log' and 'full' in dir_entry:
            mwID = re.findall(r'\d', dir_entry)[:1][0]


            with open(dir_entry_path, 'r') as mw_file:
                print(dir_entry)
                delta = float(1.0)
                startT = float(0.0)

                for line in mw_file:
                    line = line.strip()
                    lineArray = line.split(' ')

                    if "DBCOMM" in line and 'ERROR' not in line:

                        timestamp = lineArray[0]+" "+lineArray[1]
                        t = time.mktime(datetime.strptime(timestamp, "%d/%m/%Y %H:%M:%S,%f").timetuple())
                        rt = int(lineArray[7])/1000000
                        requestsCnt +=1
                        if requestsCnt ==1:
                            startT = t
                        delta = t - startT
                        if delta >= 120 and delta <= 420:
                            sum_RT += rt
                            cnt_RT += 1
                mw_file.close()



    # sum_RT_total = np.sum(sum_RT_sec_trunc)
    # cnt_RT_total = np.sum(cnt_RT_sec_trunc)
   # mean_service_time = np.mean(sum_RT_sec_trunc)/1000
    mean_service_time = (sum_RT / cnt_RT)/1000


    # mean_service_time = sum_RT_total / cnt_RT_total
    mean_service_rate = 1.0 / mean_service_time



    allMWStats = open(pathMiddleware+'/../../stats/mean_service_opt.stat', 'a')
    allMWStats.write(repeatN+'\t'+`mean_service_time`+'\t'+`mean_service_rate`)
    allMWStats.write('\n')
    allMWStats.close()



if __name__ == "__main__":
    main()



