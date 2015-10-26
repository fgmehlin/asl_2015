import csv
import matplotlib.pyplot as plt
import sys

experimentID = sys.argv[1]

data = csv.reader(open('/Users/florangmehlin/Documents/ETHZ/Advanced Systems Lab_2015/experiments/'+experimentID+'/stats/allMW_TP.stat', 'rb'), delimiter="\t")

clients, mean_tp, std_tp = [], [], []

for row in data:
	clients.append(int(row[0]))
	mean_tp.append(float(row[1]))
	std_tp.append(float(row[2]))


plt.errorbar(clients, mean_tp, std_tp, linestyle='-', marker='o')
plt.ylabel('Global Throughput [req/sec]')
plt.xlabel('User load [# of clients]')
plt.margins(0.1)
plt.xticks(clients)
plt.savefig('/Users/florangmehlin/Documents/ETHZ/Advanced Systems Lab_2015/experiments/'+experimentID+'/stats/global_tp.png', bbox_inches='tight')
#plt.show()