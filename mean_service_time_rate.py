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


    sum_RT_sec = []
    sum_RT = 0.0
    cnt_RT_sec = []
    cnt_RT = 0.0

    requestsCnt = 0
    mwID = 0

    mu_TP = 0.0
    mu_TP_MW = []

    cnt0 = 0
    cnt1 = 0

    sigma_TP = 0.0
    sigma_TP_MW = []

    throughputSec = []

    for i in range(0, int(noOfMW)):
        sum_RT_sec.append([])
        cnt_RT_sec.append([])

    pathMiddleware='../experiments/'+experimentID+'/'+noOfClients+'/'+repeatN+'/MW'

    if not os.path.exists(pathMiddleware+'/../../stats'):
        os.makedirs(pathMiddleware+'/../../stats')

    for dir_entry in os.listdir(pathMiddleware):
        dir_entry_path = os.path.join(pathMiddleware, dir_entry)

        if os.path.isfile(dir_entry_path) and dir_entry != '.DS_Store' and dir_entry != 'allMW' and 'full' in dir_entry:
            mwID = re.findall(r'\d', dir_entry)[:1][0]


            with open(dir_entry_path, 'r') as mw_file:
                print(dir_entry)
                delta = float(1.0)
                curT = float(0.0)

                for line in mw_file:
                    line = line.strip()
                    lineArray = line.split(' ')

                    if "PUTTING_REPLY" in line and 'ERROR' not in line:

                        timestamp = lineArray[0]+" "+lineArray[1]
                        t = time.mktime(datetime.strptime(timestamp, "%d/%m/%Y %H:%M:%S,%f").timetuple())
                        rt = int(lineArray[7])
                        if rt > 0:
                            cnt1 += 1
                        else:
                            cnt0 += 1
                        sum_RT += rt
                        cnt_RT += 1
                        delta = t - curT
                        if delta >= 1.0:
                            if cnt_RT > 1:
                                # print 'sum_RT : %d' % sum_RT
                                # print 'cnt_RT : %d' % cnt_RT
                                sum_RT_sec[(int(mwID)-1)].append(sum_RT/cnt_RT)
                                print 'mean : %.10f' % (sum_RT/cnt_RT)
                                # print 'cnt0 : %d' % cnt0
                                # print 'cnt1 : %d' % cnt1
                                # print 'sum_RT : %d' % sum_RT
                                # print 'cnt_RT : %d' % cnt_RT
                                cnt0 = 0
                                cnt1 = 0
                                # cnt_RT_sec[(int(mwID)-1)].append(cnt_RT)
                            curT = t
                            delta = 0.0
                            sum_RT = 0
                            cnt_RT = 0
                mw_file.close()



    minlen = 999999999

    for i in range(0, int(noOfMW)):
        xaxis_len = len(sum_RT_sec[i])
        if(minlen > xaxis_len):
            minlen = xaxis_len

    sum_RT_sec_trunc = []
    # cnt_RT_sec_trunc = []

    for i in range(0, int(noOfMW)):
        sum_RT_sec_trunc.append([])
        # cnt_RT_sec_trunc.append([])
        # Equalize sizes of MW traces
        sum_RT_sec[i] = sum_RT_sec[i][0:minlen]
        # cnt_RT_sec[i] = cnt_RT_sec[i][0:minlen]
        # Truncate database warmup (60s) and cooldown (30s)
        sum_RT_sec_trunc[i] = sum_RT_sec[i][120:len(sum_RT_sec[i])-30]
        # cnt_RT_sec_trunc[i] = cnt_RT_sec[i][120:len(cnt_RT_sec[i])-30]
        

    # sum_RT_total = np.sum(sum_RT_sec_trunc)
    # cnt_RT_total = np.sum(cnt_RT_sec_trunc)
    mean_service_time = np.mean(sum_RT_sec_trunc)


    # mean_service_time = sum_RT_total / cnt_RT_total
    mean_service_rate = 1.0 / mean_service_time



    allMWStats = open(pathMiddleware+'/../../stats/mean_service.stat', 'a')
    allMWStats.write(repeatN+'\t'+`mean_service_time`+'\t'+`mean_service_rate`)
    allMWStats.write('\n')
    allMWStats.close()



if __name__ == "__main__":
    main()



