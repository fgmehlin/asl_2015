import numpy as np
import matplotlib.pyplot as plt



def main():


    data2_200 = np.genfromtxt('../experiments/41/60/stats/clients_RT.stat', delimiter='\t')
    data2_2000 = np.genfromtxt('../experiments/42/60/stats/clients_RT.stat', delimiter='\t')
    data4_200 = np.genfromtxt('../experiments/43/60/stats/clients_RT.stat', delimiter='\t')
    data4_2000 = np.genfromtxt('../experiments/44/60/stats/clients_RT.stat', delimiter='\t')


    meanTP2_200 = np.mean(data2_200[:,3])
    meanSTD2_200 = np.mean(data2_200[:,4])

    meanTP2_2000 = np.mean(data2_2000[:,3])
    meanSTD2_2000 = np.mean(data2_2000[:,4])

    meanTP14_200 = np.mean(data4_200[:,3])
    meanSTD4_200 = np.mean(data4_200[:,4])

    meanTP4_2000 = np.mean(data4_2000[:,3])
    meanSTD4_2000 = np.mean(data4_2000[:,4])

    allMeans = np.c_[meanTP2_200, meanTP2_2000, meanTP14_200, meanTP4_2000].flatten()
    allStds = np.c_[meanSTD2_200, meanSTD2_2000, meanSTD4_200, meanSTD4_2000].flatten()

    error_config = {'ecolor': '0.3'}

    #xaxis = ['2 MW, 200','2 MW, 2000','4 MW, 200','4 MW, 2000']
    xaxis = [1,2,3,4]

    barlist = plt.bar(xaxis, allMeans, 0.35, alpha=0.4, color='r', yerr=allStds, error_kw=error_config)
    barlist[0].set_color('r')
    barlist[1].set_color('b')
    barlist[2].set_color('y')
    barlist[3].set_color('g')
    plt.title('Response Time Comparison : #Clients=60, WL=1, IN=10, OUT=5, POOL=10')
    #plt.legend(['A : 2 MW / message size 200', 'B : 2 MW / message size 2000', 'C : 4 MW / message size 200', 'D : 4 MW / message size 2000'], bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)
    plt.legend((barlist[0], barlist[1], barlist[2], barlist[3]), ('1: 2 MW / message size 200', '2: 2 MW / message size 2000', '3: 4 MW / message size 200', '4: 4 MW / message size 2000'), bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)
    plt.ylabel('Response Time [ms]')
    plt.xlabel('Groups')
    plt.margins(0.1)
    plt.xticks(xaxis)
    plt.savefig('../experiments/41/60/stats/rt_var_comparison.png', bbox_inches='tight')

    












if __name__ == "__main__":
    main()