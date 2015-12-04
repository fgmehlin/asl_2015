import numpy as np
import matplotlib.pyplot as plt



def main():


    data41 = np.genfromtxt('../experiments/41/60/stats/mw_rt_db.stat', delimiter='\t')
    data42 = np.genfromtxt('../experiments/42/60/stats/mw_rt_db.stat', delimiter='\t')
    data43 = np.genfromtxt('../experiments/43/60/stats/mw_rt_db.stat', delimiter='\t')
    data44 = np.genfromtxt('../experiments/44/60/stats/mw_rt_db.stat', delimiter='\t')



    # print CI_min
    # print CI_max
    print 'data'

    data41RTDB = data41[2]
    data41STDRTDB = data41[3]

    data42RTDB = data42[2]
    data42STDRTDB = data42[3]

    data43RTDB = data43[2]
    data43STDRTDB = data43[3]

    data44RTDB = data44[2]
    data44STDRTDB = data44[3]

    allMeansDBRT = np.c_[data41RTDB, data42RTDB, data43RTDB, data44RTDB].flatten()
    allStdsDBRT = np.c_[data41STDRTDB, data42STDRTDB, data43STDRTDB, data44STDRTDB].flatten()


    xaxis = [1,2,3,4]

    barlist = plt.plot(xaxis, allMeansDBRT, linestyle='-', marker='None')
    print len(barlist)
    plt.legend([' 1: 2 MW / message size 200 \n 2: 2 MW / message size 2000 \n 3: 4 MW / message size 200 \n 4: 4 MW / message size 2000'], bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)
    plt.title('Database Resp. Time Comparison : WL=1, IN=10 OUT=5, POOL=10')
    plt.ylabel('Response TIme [ms]')
    plt.xlabel('Groups')
    plt.margins(0.1)
    plt.xticks(xaxis)
    plt.savefig('../experiments/41/60/stats/db_rt_var_comparison.png', bbox_inches='tight')
    plt.clf()




if __name__ == "__main__":
    main()