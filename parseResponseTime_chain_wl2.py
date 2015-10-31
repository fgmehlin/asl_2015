from dateutil.parser import parse
import time
from datetime import datetime
import sys
import os
import re
from math import sqrt


def writeEachClient(client):
    with open(pathClient+'/stats/eachClient_RT_WL2.stat', 'a') as f:
        f.write(client+'\t'+`mu_RTi`+'\t'+`sigma_RTi`)
        f.write('\n')
        f.close()

experimentID = sys.argv[1]
#noOfClients = sys.argv[2]


pathExperiment='/Users/florangmehlin/Documents/ETHZ/Advanced Systems Lab_2015/experiments/'+experimentID

if not os.path.exists(pathExperiment+'/stats'):
        os.makedirs(pathExperiment+'/stats')

for exp in os.listdir(pathExperiment):
    exp_path = os.path.join(pathExperiment, exp)
    if os.path.isdir(exp_path) and exp != '.DS_Store' and exp != 'stats':

        noOfClients = exp

        pathClient='/Users/florangmehlin/Documents/ETHZ/Advanced Systems Lab_2015/experiments/'+experimentID+'/'+exp+'/C'

        sumResponseTime = 0.0
        totalSumResponseTime = 0.0
        totalCandidates = 0

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
                clientID = re.findall(r'\d', dir_entry)[:1][0]
                writeEachClient(clientID)

                
                    


        with open(pathClient+'/allclients', 'r') as allclients:
            lineCnt = 0
            tmpStdDev = 0
        # Compute standard deviation of response time for all client
            mu_RT = float(totalSumResponseTime / totalCandidates)

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


            sigma_RT = sqrt(tmpStdDev / totalCandidates)


            print 'totalCandidates %d' % totalCandidates
            print 'lineCnt %d ' % lineCnt

            allClientStats = open(pathExperiment+'/stats/allclients_RT_WL2.stat', 'a')
            allClientStats.write(noOfClients+'\t'+`mu_RT`+'\t'+`sigma_RT`)
            allClientStats.write('\n')
            allClientStats.close()
            allclients.close()




