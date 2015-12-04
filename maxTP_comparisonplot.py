import numpy as np
import matplotlib.pyplot as plt



def main():


    data5 = np.genfromtxt('../experiments/38/50/stats/mw_tp.stat', delimiter='\t')
    data10 = np.genfromtxt('../experiments/39/50/stats/mw_tp.stat', delimiter='\t')
    data13 = np.genfromtxt('../experiments/40/50/stats/mw_tp.stat', delimiter='\t')
    data17 = np.genfromtxt('../experiments/45/50/stats/mw_tp.stat', delimiter='\t')

    dataCI5 = np.genfromtxt('../experiments/38/50/stats/confidence.stat', delimiter='\t')
    dataCI10 = np.genfromtxt('../experiments/39/50/stats/confidence.stat', delimiter='\t')
    dataCI13 = np.genfromtxt('../experiments/40/50/stats/confidence.stat', delimiter='\t')
    dataCI17 = np.genfromtxt('../experiments/45/50/stats/confidence.stat', delimiter='\t')

    CI_min = np.c_[dataCI5[1,2], dataCI10[1,2], dataCI13[1,2], dataCI17[1,2]].flatten()
    CI_max = np.c_[dataCI5[1,3], dataCI10[1,3], dataCI13[1,3], dataCI17[1,3]].flatten()

    print CI_min
    print CI_max

    meanTP5 = np.mean(data5[:,3])
    meanSTD5 = np.mean(data5[:,4])

    meanTP10 = np.mean(data10[:,3])
    meanSTD10 = np.mean(data10[:,4])

    meanTP13 = np.mean(data13[:,3])
    meanSTD13 = np.mean(data13[:,4])

    meanTP17 = np.mean(data17[:,3])
    meanSTD17 = np.mean(data17[:,4])

    allMeans = np.c_[meanTP5, meanTP10, meanTP13, meanTP17].flatten()
    allStds = np.c_[meanSTD5, meanSTD10, meanSTD13, meanSTD17].flatten()

    xaxis = [5,10,13,17]

    plt.errorbar(xaxis, allMeans, allStds, linestyle='-', marker='None')
    plt.title('Max Throughput Experiment : #Clients=50, WL=1, OUT=5, MW=2')
    plt.ylabel('Throughput [req/sec]')
    plt.xlabel('Number of InboxProcessingThreads/DB Connections in pool')
    plt.margins(0.1)
    plt.xticks(xaxis)
    plt.savefig('../experiments/40/50/stats/max_tp_comparison.png', bbox_inches='tight')

    












if __name__ == "__main__":
    main()