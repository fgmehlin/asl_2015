import matplotlib.pyplot as plt
import numpy as np

x_tp = np.array([1, 3, 5, 15, 25])
y_tp = np.array([2912.28, 9130.14, 10312.98, 10838.22, 11842.73]) # Effectively y = x**2
e_tp = np.array([92.49, 123.04, 263.2, 197.99, 208.11])

plt.title("Throughput Comparison")
plt.xlabel("Load : Number of Clients")
plt.ylabel("Throughput [requests/second]")
plt.xticks(x_tp)
plt.xlim([0.5,26])

plt.errorbar(x_tp, y_tp, e_tp, color='r', linestyle='--', marker='o')

plt.show()
plt.clf()

x_rt = np.array([1, 3, 5, 15, 25])
y_rt = np.array([0.3289, 0.318, 0.474, 1.371, 2.096]) # Effectively y = x**2
e_rt = np.array([0.47, 0.47, 0.51, 2.30, 4.49])

plt.title("Response Time Comparison")
plt.xlabel("Load : Number of Clients")
plt.ylabel("Response Time [ms]")
plt.xticks(x_rt)
plt.xlim([0.5,26])
plt.errorbar(x_rt, y_rt, e_rt, color='b',  linestyle='--', marker='o')
plt.show()