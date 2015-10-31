import csv
import matplotlib.pyplot as plt
import sys


def main(experimentID, nIn, nOut, nMw, poolsize):
	#experimentID = sys.argv[1]

	data = csv.reader(open('../experiments/'+experimentID+'/stats/allMW_TP.stat', 'rb'), delimiter="\t")

	clients, mean_tp, std_tp = [], [], []

	for row in data:
		clients.append(int(row[0]))
		mean_tp.append(float(row[1]))
		std_tp.append(float(row[2]))


	plt.errorbar(clients, mean_tp, std_tp, linestyle='-', marker='o')
	plt.title('Throughput : IN='+nIn+', OUT='+nOut+', MW='+nMw+', POOL='+poolsize)
	plt.ylabel('Throughput [req/sec]')
	plt.xlabel('User load [# of clients]')
	plt.margins(0.1)
	plt.xticks(clients)
	plt.savefig('../experiments/'+experimentID+'/stats/global_tp.png', bbox_inches='tight')
	#plt.show()

if __name__ == "__main__":
    main()
