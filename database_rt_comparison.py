import numpy as np
import matplotlib.pyplot as plt



def main():


    data60RT = np.genfromtxt('../experiments/46/60/stats/clients_RT.stat', delimiter='\t')
    data120RT = np.genfromtxt('../experiments/47/120/stats/clients_RT.stat', delimiter='\t')
    data180RT = np.genfromtxt('../experiments/48/180/stats/clients_RT.stat', delimiter='\t')
    
    data60Q = np.genfromtxt('../experiments/46/60/stats/mw_tp.stat', delimiter='\t')
    data120Q = np.genfromtxt('../experiments/47/120/stats/mw_tp.stat', delimiter='\t')
    data180Q = np.genfromtxt('../experiments/48/180/stats/mw_tp.stat', delimiter='\t')


    # print CI_min
    # print CI_max
    print 'data'
    print data60TP[:,3]
    print data120TP[:,3]
    print data180TP[:,3]

    meanTP60 = np.mean(data60TP[:,3])
    meanSTDTP60 = np.mean(data60TP[:,4])
    meanRT60 = np.mean(data60RT[:,3])
    meanSTDRT60 = np.mean(data60RT[:,4])

    meanTP120 = np.mean(data120TP[:,3])
    meanSTDTP120 = np.mean(data120TP[:,4])
    meanRT120 = np.mean(data120RT[:,3])
    meanSTDRT120 = np.mean(data120RT[:,4])

    meanTP180 = np.mean(data180TP[:,3])
    meanSTDTP180 = np.mean(data180TP[:,4])
    meanRT180 = np.mean(data180RT[:,3])
    meanSTDRT180 = np.mean(data180RT[:,4])


    allMeansTP = np.c_[meanTP60, meanTP120, meanTP180].flatten()
    allStdsTP = np.c_[meanSTDTP60, meanSTDTP120, meanSTDTP180].flatten()

    allMeansRT = np.c_[meanRT60, meanRT120, meanRT180].flatten()
    allStdsRT = np.c_[meanSTDRT60, meanSTDRT120, meanSTDRT180].flatten()

    xaxis = [2,4,6]

    plt.errorbar(xaxis, allMeansTP, allStdsTP, linestyle='-', marker='None')
    plt.title('Stability, Throughput Comparison : #Clients=30 per MW, WL=1, IN=13 OUT=5, POOL=13')
    plt.ylabel('Throughput [req/sec]')
    plt.xlabel('Number of Middlewares')
    plt.margins(0.1)
    plt.xticks(xaxis)
    plt.savefig('../experiments/46/60/stats/tp_stab_comparison.png', bbox_inches='tight')
    plt.clf()

    plt.errorbar(xaxis, allMeansRT, allStdsRT, linestyle='-', marker='None')
    plt.title('Stability, Resp. Time Comparison : #Clients=30 per MW, WL=1, IN=13 OUT=5, POOL=13')
    plt.ylabel('Response TIme [ms]')
    plt.xlabel('Number of Middlewares')
    plt.margins(0.1)
    plt.xticks(xaxis)
    plt.savefig('../experiments/46/60/stats/rt_stab_comparison.png', bbox_inches='tight')

if __name__ == "__main__":
    main()