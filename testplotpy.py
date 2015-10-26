import csv
import matplotlib.pyplot as plt




data = csv.reader(open('/Users/florangmehlin/Documents/ETHZ/Advanced Systems Lab_2015/project_repo/15/C/stats/eachClient_sorted.stat', 'rb'), delimiter="\t")

clients, mean_rt, std_rt = [], [], []

for row in data:
	clients.append(row[0])
	mean_rt.append(float(row[1]))
	std_rt.append(float(row[2]))


plt.errorbar(clients, mean_rt, std_rt, linestyle='None', marker='^')
plt.show()