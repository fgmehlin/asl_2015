from dateutil.parser import parse
import time
from datetime import datetime
import sys
import os
from math import sqrt


def writeEachClient(client):
    with open(pathClient+'/stats/eachClient_RT.stat', 'a') as f:
        f.write(client+'\t'+`mu_RTi`+'\t'+`sigma_RTi`)
        f.write('\n')
        f.close()

experimentID = sys.argv[1]
noOfClients = sys.argv[2]

pathClient='/Users/florangmehlin/Documents/ETHZ/Advanced Systems Lab_2015/experiments/'+experimentID+'/'+noOfClients+'/C'

sumResponseTime = 0.0
totalSumResponseTime = 0.0
totalCandidates = 0

sm_candidates = 0
sm_RT = 0
sm_tmpStdDev = 0.0
sm_sigma = 0.0

pm_candidates = 0
pm_RT = 0
pm_tmpStdDev = 0.0
pm_sigma = 0.0

gm_candidates = 0
gm_RT = 0
gm_tmpStdDev = 0.0
gm_sigma = 0.0



mu_RTi = 0.0
sigma_RTi = 0.0

mu_RT = 0.0
sigma_RT = 0.0
lineCnt = 0
tmpStdDev = 0.0

totalTmpStdDev = 0.0

if not os.path.exists(pathClient+'/stats'):
    os.makedirs(pathClient+'/stats')

for dir_entry in os.listdir(pathClient):
    dir_entry_path = os.path.join(pathClient, dir_entry)

    if os.path.isfile(dir_entry_path) and dir_entry != 'allclients' and dir_entry != '.DS_Store':

        with open(dir_entry_path, 'r') as client_file:
            print(dir_entry)
            lineCnt = 0
            sumResponseTime = 0.0
            mu_RTi = 0.0
            sigma_RTi = 0.0

            # Compute mean of response time for 1 client
            for line in client_file:
                line = line.strip()
                lineArray = line.split(' ')
                if(len(lineArray)>=6 and 'started' not in line):
                    timestamp = lineArray[0]+" "+lineArray[1]
                    typeQ = lineArray[6]
                    #print(typeQ)
                    if "RESPONSE" in typeQ:
                        lineCnt+=1
                        responseTime = float(lineArray[7])
                        sumResponseTime += responseTime
                        if "SM" in typeQ:
                            sm_candidates += 1
                            sm_RT += responseTime
                        elif "PM" in typeQ:
                            pm_candidates += 1
                            pm_RT += responseTime
                        elif "GM" in typeQ:
                            gm_candidates += 1
                            gm_RT += responseTime

            totalSumResponseTime += sumResponseTime
            totalCandidates += lineCnt

            mu_RTi = float(sumResponseTime / lineCnt)
            client_file.close()

        with open(dir_entry_path, 'r') as client_file:
            lineCnt = 0
            tmpStdDev = 0.0
            # Compute standard deviation of response time for 1 client
            for line in client_file:
                line = line.strip()
                lineArray = line.split(' ')
                if(len(lineArray)>=6 and 'started' not in line):
                    timestamp = lineArray[0]+" "+lineArray[1]
                    typeQ = lineArray[6]
                    if "RESPONSE" in typeQ:
                    	lineCnt += 1
                        responseTime = float(lineArray[7])
                        tmpStdDev += float((responseTime - mu_RTi)**2)
            sigma_RTi = sqrt(tmpStdDev / lineCnt)
            client_file.close()
            # write mean and response time to file for individual client
        writeEachClient(dir_entry)

        
            


with open(pathClient+'/allclients', 'r') as allclients:
    lineCnt = 0
    tmpStdDev = 0
# Compute standard deviation of response time for all client
    mu_RT = float(totalSumResponseTime / totalCandidates)
    mu_sm_RT = float(sm_RT / sm_candidates)
    mu_pm_RT = float(pm_RT / pm_candidates)
    mu_gm_RT = float(gm_RT / gm_candidates)

    # Compute standard deviation of response time for all client
    for line in allclients:
        line = line.strip()
        lineArray = line.split(' ')
        if(len(lineArray)>=6 and 'started' not in line):
            timestamp = lineArray[0]+" "+lineArray[1]
            typeQ = lineArray[6]
            if "RESPONSE" in typeQ:
                lineCnt+=1
                reponseTime = float(lineArray[7])
                tmpStdDev += float((responseTime - mu_RT)**2)
                if "SM" in typeQ:
                    sm_tmpStdDev += float((responseTime - mu_sm_RT)**2)
                elif "PM" in typeQ:
                    pm_tmpStdDev += float((responseTime - mu_pm_RT)**2)
                elif "GM" in typeQ:
                    gm_tmpStdDev += float((responseTime - mu_gm_RT)**2)
    # print 'tmpStdDev %.5f' % tmpStdDev
    # print 'sm_tmpStdDev %.5f' % sm_tmpStdDev
    # print 'pm_tmpStdDev %.5f' % pm_tmpStdDev
    # print 'gm_tmpStdDev %.5f' % gm_tmpStdDev
    # print 'sm_candidates %.5f' % sm_candidates
    # print 'pm_candidates %.5f' % pm_candidates
    # print 'gm_candidates %.5f' % gm_candidates

    sigma_RT = sqrt(tmpStdDev / totalCandidates)
    sm_sigma = sqrt(sm_tmpStdDev / sm_candidates)
    pm_sigma = sqrt(pm_tmpStdDev / pm_candidates)
    gm_sigma = sqrt(gm_tmpStdDev / gm_candidates)


    print 'totalCandidates %d' % totalCandidates
    print 'lineCnt %d ' % lineCnt

    allClientStats = open(pathClient+'/stats/allclients_RT.stat', 'w')
    allClientStats.write(noOfClients+'\t'+`mu_RT`+'\t'+`sigma_RT`+'\t'+`mu_sm_RT`+'\t'+`sm_sigma`+'\t'+`mu_pm_RT`+'\t'+`pm_sigma`+'\t'+`mu_gm_RT`+'\t'+`gm_sigma`)
    allClientStats.write('\n')
    allClientStats.close()
    allclients.close()




