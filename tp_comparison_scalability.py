import numpy as np
import matplotlib.pyplot as plt



def main():


    data60TP = np.genfromtxt('../experiments/46/60/stats/mw_tp.stat', delimiter='\t')
    data120TP = np.genfromtxt('../experiments/47/120/stats/mw_tp.stat', delimiter='\t')
    data180TP = np.genfromtxt('../experiments/48/180/stats/mw_tp.stat', delimiter='\t')

    data60DBRT = np.genfromtxt('../experiments/46/60/stats/mw_rt_db.stat', delimiter='\t')
    data120DBRT = np.genfromtxt('../experiments/47/120/stats/mw_rt_db.stat', delimiter='\t')
    data180DBRT = np.genfromtxt('../experiments/48/180/stats/mw_rt_db.stat', delimiter='\t')

    data60Q = np.genfromtxt('../experiments/46/60/stats/mw_qsize.stat', delimiter='\t')
    data120Q = np.genfromtxt('../experiments/47/120/stats/mw_qsize.stat', delimiter='\t')
    data180Q = np.genfromtxt('../experiments/48/180/stats/mw_qsize.stat', delimiter='\t')

    data60RT = np.genfromtxt('../experiments/46/60/stats/clients_RT.stat', delimiter='\t')
    data120RT = np.genfromtxt('../experiments/47/120/stats/clients_RT.stat', delimiter='\t')
    data180RT = np.genfromtxt('../experiments/48/180/stats/clients_RT.stat', delimiter='\t')
    


    # print CI_min
    # print CI_max
    print 'data'
    print data60DBRT

    meanTP60 = np.mean(data60TP[:,3])
    meanSTDTP60 = np.mean(data60TP[:,4])
    meanRT60 = np.mean(data60RT[:,3])
    meanSTDRT60 = np.mean(data60RT[:,4])
    meanDBRT60 = data60DBRT[2]
    meanSTDDBRT60 = data60DBRT[3]
    meanQ60 = data60Q[2]
    meanSTDQ60 = data60Q[3]

    meanTP120 = np.mean(data120TP[:,3])
    meanSTDTP120 = np.mean(data120TP[:,4])
    meanRT120 = np.mean(data120RT[:,3])
    meanSTDRT120 = np.mean(data120RT[:,4])
    meanDBRT120 = data120DBRT[2]
    meanSTDDBRT120 = data120DBRT[3]
    meanQ120 = data120Q[2]
    meanSTDQ120 = data120Q[3]

    meanTP180 = np.mean(data180TP[:,3])
    meanSTDTP180 = np.mean(data180TP[:,4])
    meanRT180 = np.mean(data180RT[:,3])
    meanSTDRT180 = np.mean(data180RT[:,4])
    meanDBRT180 = data180DBRT[2]
    meanSTDDBRT180 = data180DBRT[3]
    meanQ180 = data180Q[2]
    meanSTDQ180 = data180Q[3]



    allMeansTP = np.c_[meanTP60, meanTP120, meanTP180].flatten()
    allStdsTP = np.c_[meanSTDTP60, meanSTDTP120, meanSTDTP180].flatten()

    allMeansRT = np.c_[meanRT60, meanRT120, meanRT180].flatten()
    allStdsRT = np.c_[meanSTDRT60, meanSTDRT120, meanSTDRT180].flatten()

    allMeansDBRT = np.c_[meanDBRT60, meanDBRT120, meanDBRT180].flatten()
    allStdsDBRT = np.c_[meanSTDDBRT60, meanSTDDBRT120, meanSTDDBRT180].flatten()

    allMeansQ = np.c_[meanQ60, meanQ120, meanQ180].flatten()
    allStdsQ = np.c_[meanQ60, meanQ120, meanQ180].flatten()

    xaxis = [2,4,6]

    plt.errorbar(xaxis, allMeansTP, allStdsTP, linestyle='-', marker='None')
    plt.title('Throughput Comparison : #Clients=30 per MW, WL=1, IN=13 OUT=5, POOL=13')
    plt.ylabel('Throughput [req/sec]')
    plt.xlabel('Number of Middlewares')
    plt.margins(0.1)
    plt.xticks(xaxis)
    plt.savefig('../experiments/46/60/stats/tp_stab_comparison.png', bbox_inches='tight')
    plt.clf()

    plt.errorbar(xaxis, allMeansRT, allStdsRT, linestyle='-', marker='None')
    plt.title('Resp. Time Comparison : #Clients=30 per MW, WL=1, IN=13 OUT=5, POOL=13')
    plt.ylabel('Response TIme [ms]')
    plt.xlabel('Number of Middlewares')
    plt.margins(0.1)
    plt.xticks(xaxis)
    plt.savefig('../experiments/46/60/stats/rt_stab_comparison.png', bbox_inches='tight')
    plt.clf()

    plt.errorbar(xaxis, allMeansDBRT, allStdsDBRT, linestyle='-', marker='None')
    plt.title('Database Resp. Time Comparison : #Clients=30 per MW, WL=1, IN=13 OUT=5, POOL=13')
    plt.ylabel('Response TIme [ms]')
    plt.xlabel('Number of Middlewares')
    plt.margins(0.1)
    plt.xticks(xaxis)
    plt.savefig('../experiments/46/60/stats/db_rt_stab_comparison.png', bbox_inches='tight')
    plt.clf()

    plt.errorbar(xaxis, allMeansQ, allStdsQ, linestyle='-', marker='None')
    plt.title('InboxQueue Size Comparison : #Clients=30 per MW, WL=1, IN=13 OUT=5, POOL=13')
    plt.ylabel('Pending Queries')
    plt.xlabel('Number of Middlewares')
    plt.margins(0.1)
    plt.xticks(xaxis)
    plt.savefig('../experiments/46/60/stats/q_stab_comparison.png', bbox_inches='tight')
    plt.clf()








if __name__ == "__main__":
    main()