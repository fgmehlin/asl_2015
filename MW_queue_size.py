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
    workload = sys.argv[7]
    repeatN = sys.argv[8]

    clientsPerMW = int(noOfClients)/int(noOfMW)


    requestsCnt = 0
    mwID = 0

    mu_TP = 0.0
    mu_TP_MW = []

    sigma_TP = 0.0
    sigma_TP_MW = []

    queue_sizeSec = []
    rt_Sec = []

    for i in range(0, int(noOfMW)):
        queue_sizeSec.append([])
        rt_Sec.append([])


    pathMiddleware='../experiments/'+experimentID+'/'+noOfClients+'/'+repeatN+'/MW'

    if not os.path.exists(pathMiddleware+'/../../stats'):
        os.makedirs(pathMiddleware+'/../../stats')

    for dir_entry in os.listdir(pathMiddleware):
        dir_entry_path = os.path.join(pathMiddleware, dir_entry)

        if os.path.isfile(dir_entry_path) and dir_entry != '.DS_Store' and dir_entry != 'allMW' and 'full' in dir_entry:
            mwID = re.findall(r'\d', dir_entry)[:1][0]


            with open(dir_entry_path, 'r') as mw_file:
                print(dir_entry)
                sizeCnt = 0.0
                sumSize = 0.0
                sum_db_rt = 0.0
                rtCnt = 0.0


                delta_q = float(1.0)
                curT_q = float(0.0)
                delta_rt = float(1.0)
                curT_rt = float(0.0)

                for line in mw_file:
                    line = line.strip()
                    lineArray = line.split(' ')
                    

                    
                    if "POPING_QUERY" in line and 'ECHO' not in line and 'size' in line and 'InboxProcessingThread' in line:
                        size_unparsed = lineArray[8]
                        # print 'size'
                        # print size_unparsed
                        timestamp = lineArray[0]+" "+lineArray[1]
                        t = time.mktime(datetime.strptime(timestamp, "%d/%m/%Y %H:%M:%S,%f").timetuple())
                        size = int(''.join(re.findall(r'\d', size_unparsed)))
                        sumSize += size
                        delta_q = t - curT_q
                        if delta_q >= 1.0:
                            if sizeCnt > 0:
                                queue_sizeSec[(int(mwID)-1)].append(sumSize/sizeCnt)
                                print 'mean size in sec'
                                print sumSize/sizeCnt
                            curT_q = t
                            delta_q = 0.0
                            sizeCnt = 0.0
                            sumSize = 0.0
                        sizeCnt += 1

                    if "PUTTING_REPLY" in line and 'InboxProcessingThread' in line and 'ECHO' not in line and 'ERROR' not in line and '-99' not in line and 'False' not in line and 'FALSE' not in line and 'false' not in line:
                        db_rt = int(lineArray[7])
                        timestamp = lineArray[0]+" "+lineArray[1]
                        t = time.mktime(datetime.strptime(timestamp, "%d/%m/%Y %H:%M:%S,%f").timetuple())
                        # print 'rt'
                        # print db_rt
                        delta_rt = t - curT_rt
                        sum_db_rt += db_rt
                        if delta_rt >= 1.0:
                            if rtCnt > 0:
                                rt_Sec[(int(mwID)-1)].append(sum_db_rt/rtCnt)
                                print 'mean rt in sec'
                                print sum_db_rt/rtCnt
                            curT_rt = t
                            delta_rt = 0.0
                            rtCnt = 0
                            sum_db_rt = 0.0
                        rtCnt += 1
                
                mw_file.close()

    print 'length Q size'
    print len(queue_sizeSec[0])
    print len(queue_sizeSec[1])

    print 'length rt'
    print len(rt_Sec[0])
    print len(rt_Sec[1])

    minlen_q = 999999999
    minlen_rt = 999999999

    for i in range(0, int(noOfMW)):
        xaxis_len_q = len(queue_sizeSec[i])
        xaxis_len_rt = len(rt_Sec[i])
        if(minlen_q > xaxis_len_q):
            minlen_q = xaxis_len_q
        if(minlen_rt > xaxis_len_rt):
            minlen_rt = xaxis_len_rt

    queue_sizeSec_trunc = []
    rt_Sec_trunc = []

    for i in range(0, int(noOfMW)):
        queue_sizeSec_trunc.append([])
        rt_Sec_trunc.append([])
        # Equalize sizes of MW traces
        queue_sizeSec[i] = queue_sizeSec[i][0:minlen_q]
        rt_Sec[i] = rt_Sec[i][0:minlen_rt]
        # Truncate database warmup (60s) and cooldown (30s)
        if minlen_q > 120:
            queue_sizeSec_trunc[i] = queue_sizeSec[i][120:len(queue_sizeSec[i])-30]
        rt_Sec_trunc[i] = rt_Sec[i][120:len(rt_Sec[i])-30]

        # xaxis = list(xrange(len(throughputSec_trunc[i])))
        # plt.plot(xaxis, throughputSec_trunc[i], linestyle='-', marker='None')
        # plt.title('Middleware #'+`(i+1)`+' Throughput Trace : #Clients='+`clientsPerMW`+', WL='+workload+', IN='+inThread+', OUT='+outThread+', MW='+noOfMW+', POOL='+poolSize)
        # plt.ylabel('Throughput [req/sec]')
        # plt.xlabel('Time [s]')
        # plt.margins(0.1)
        # plt.savefig(pathMiddleware+'/../../middleware'+`(i+1)`+'_tp_trace_'+repeatN+'.png', bbox_inches='tight')
        # plt.clf()

    print '1'

   
    plt.margins(0.1)
    if len(queue_sizeSec_trunc) > 0:
        xaxis_q = list(xrange(len(queue_sizeSec_trunc[i])))

    xaxis_rt = list(xrange(len(rt_Sec_trunc[i])))

    mwIDs = list(xrange(int(noOfMW)+1))

    print '2'


    # mwIDs[len(mwIDs)-1] = 'Sum'

    # for i in range(0, int(noOfMW)):
    #     mwIDs[i] = 'Middleware '+`mwIDs[i]+1`
    #     plt.plot(xaxis, throughputSec_trunc[i], linestyle='-', marker='None')

    #mu_TP= np.mean(throughputSec_trunc,axis=0)
    if len(queue_sizeSec_trunc) > 0:
        mean_size_sec = np.mean(queue_sizeSec_trunc, axis=0)
        mean_all_size = np.mean(queue_sizeSec_trunc)
        std_all_size = np.std(queue_sizeSec_trunc)

    print '3'
    
    mean_rt_sec = np.mean(rt_Sec_trunc, axis=0)

    mean_all_rt = np.mean(rt_Sec_trunc)
    std_all_rt = np.std(rt_Sec_trunc)


    print '4'

    if len(queue_sizeSec_trunc) > 0:
        plt.title('Middleware queue size : #Clients='+noOfClients+', WL='+workload+', IN='+inThread+', OUT='+outThread+', MW='+noOfMW+', POOL='+poolSize)
        plt.ylabel('Mean Queue Size [requests]')
        plt.xlabel('Time [s]')
        plt.plot(xaxis_q, mean_size_sec, linestyle='-', marker='None')
        plt.savefig(pathMiddleware+'/../../stats/all_middlwares_qsize_trace_'+repeatN+'.png', bbox_inches='tight')
        plt.clf()


    print '5'

    allMWQStats = open(pathMiddleware+'/../../stats/mw_qsize.stat', 'a')
    allMWQStats.write(noOfClients+'\t'+repeatN+'\t'+`mean_all_size`+'\t'+`std_all_size`)
    allMWQStats.write('\n')
    allMWQStats.close()

    print '6'

    plt.title('Database response time : #Clients='+noOfClients+', WL='+workload+', IN='+inThread+', OUT='+outThread+', MW='+noOfMW+', POOL='+poolSize)
    plt.ylabel('Response Time [ms]')
    plt.xlabel('Time [s]')
    plt.plot(xaxis_rt, mean_rt_sec, linestyle='-', marker='None')
    plt.savefig(pathMiddleware+'/../../stats/all_middlwares_dbrt_trace_'+repeatN+'.png', bbox_inches='tight')
    plt.clf()

    print '7'

    allMWRTStats = open(pathMiddleware+'/../../stats/mw_rt_db.stat', 'a')
    allMWRTStats.write(noOfClients+'\t'+repeatN+'\t'+`mean_all_rt`+'\t'+`std_all_rt`)
    allMWRTStats.write('\n')
    allMWRTStats.close()



if __name__ == "__main__":
    main()



