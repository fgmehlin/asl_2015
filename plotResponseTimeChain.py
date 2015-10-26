import csv
import matplotlib.pyplot as plt
import sys

experimentID = sys.argv[1]

data = csv.reader(open('/Users/florangmehlin/Documents/ETHZ/Advanced Systems Lab_2015/experiments/'+experimentID+'/stats/allclients_RT.stat', 'rb'), delimiter="\t")

clients, mean_rt, std_rt, sm_mean_rt, sm_std_rt, pm_mean_rt, pm_std_rt, gm_mean_rt, gm_std_rt = [], [], [], [], [], [], [], [], []

for row in data:
	clients.append(int(row[0]))
	mean_rt.append(float(row[1]))
	std_rt.append(float(row[2]))
	sm_mean_rt.append(float(row[3]))
	sm_std_rt.append(float(row[4]))
	pm_mean_rt.append(float(row[5]))
	pm_std_rt.append(float(row[6]))
	gm_mean_rt.append(float(row[7]))
	gm_std_rt.append(float(row[8]))


plt.errorbar(clients, mean_rt, std_rt, linestyle='-', marker='o')
plt.ylabel('Global Mean Response Time [ms]')
plt.xlabel('User load [# of clients]')
plt.margins(0.1)
plt.xticks(clients)
plt.savefig('/Users/florangmehlin/Documents/ETHZ/Advanced Systems Lab_2015/experiments/'+experimentID+'/stats/global_rt.png', bbox_inches='tight')
#plt.show()

plt.errorbar(clients, sm_mean_rt, sm_std_rt, linestyle='-', marker='o')
plt.ylabel('Send Message Mean Response Time [ms]')
plt.xlabel('User load [# of clients]')
plt.margins(0.1)
plt.xticks(clients)
plt.savefig('/Users/florangmehlin/Documents/ETHZ/Advanced Systems Lab_2015/experiments/'+experimentID+'/stats/sm_rt.png', bbox_inches='tight')
#plt.show()

plt.errorbar(clients, pm_mean_rt, pm_std_rt, linestyle='-', marker='o')
plt.ylabel('Peek Message Mean Response Time [ms]')
plt.xlabel('User load [# of clients]')
plt.margins(0.1)
plt.xticks(clients)
plt.savefig('/Users/florangmehlin/Documents/ETHZ/Advanced Systems Lab_2015/experiments/'+experimentID+'/stats/pm_rt.png', bbox_inches='tight')
#plt.show()

plt.errorbar(clients, gm_mean_rt, gm_std_rt, linestyle='-', marker='o')
plt.ylabel('Pop Message Mean Response Time [ms]')
plt.xlabel('User load [# of clients]')
plt.margins(0.1)
plt.xticks(clients)
plt.savefig('/Users/florangmehlin/Documents/ETHZ/Advanced Systems Lab_2015/experiments/'+experimentID+'/stats/gm_rt.png', bbox_inches='tight')
#plt.show()