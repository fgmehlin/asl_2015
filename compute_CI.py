from math import sqrt
import sys
import numpy as np


def main():
    experimentID = sys.argv[1]
    noOfClients = sys.argv[2]

    int95 = 1.96

    dataRT = np.genfromtxt('../experiments/'+experimentID+'/'+noOfClients+'/stats/clients_RT.stat', delimiter='\t')
    dataTP = np.genfromtxt('../experiments/'+experimentID+'/'+noOfClients+'/stats/mw_tp.stat', delimiter='\t')

    # print dataRT
    # print dataTP

    # means
    # print 'means TP'
    # print dataTP[:,3] 
    # print 'std TP'
    # print dataTP[:,4] 

    ci_95_tp = (int95*dataTP[:,4])/np.sqrt(dataTP[:,1])
    ci_95_rt = (int95*dataRT[:,4])/np.sqrt(dataRT[:,1])

    # # print 'mean of means TP'
    # meanTP = np.mean(dataTP[:,3])
    # # print 'mean 95 TP'
    # mean95_TP = np.mean(ci_95_tp)
    # # print 'mean samples TP'
    # mean_samples_tp = int(np.mean(dataTP[:,1]))

    # # print 'mean of means RT'
    # meanRT = np.mean(dataRT[:,3])
    # # print 'mean 95 RT'
    # mean95_RT = np.mean(ci_95_rt)
    # # print 'mean samples RT'
    # mean_samples_rt = int(np.mean(dataRT[:,1]))

    ciStat = open('../experiments/'+experimentID+'/'+noOfClients+'/stats/confidence.stat', 'a')
    ciStat.write(experimentID+'\t95 Interval RT1:\t'+`dataRT[0,3]`+'\t'+`ci_95_rt[0]`+'\t'+`dataRT[0,1]`)
    ciStat.write('\n')
    ciStat.write(experimentID+'\t95 Interval RT2:\t'+`dataRT[1,3]`+'\t'+`ci_95_rt[1]`+'\t'+`dataRT[1,1]`)
    ciStat.write('\n')
    ciStat.write(experimentID+'\t95 Interval RT3:\t'+`dataRT[2,3]`+'\t'+`ci_95_rt[2]`+'\t'+`dataRT[2,1]`)
    ciStat.write('\n')
    ciStat.write(experimentID+'\t95 Interval TP1:\t'+`dataTP[0,3]`+'\t'+`ci_95_tp[0]`+'\t'+`dataTP[0,1]`)
    ciStat.write('\n')
    ciStat.write(experimentID+'\t95 Interval TP2:\t'+`dataTP[1,3]`+'\t'+`ci_95_tp[1]`+'\t'+`dataTP[1,1]`)
    ciStat.write('\n')
    ciStat.write(experimentID+'\t95 Interval TP3:\t'+`dataTP[2,3]`+'\t'+`ci_95_tp[2]`+'\t'+`dataTP[2,1]`)
    ciStat.write('\n')
    ciStat.close()

if __name__ == "__main__":
    main()