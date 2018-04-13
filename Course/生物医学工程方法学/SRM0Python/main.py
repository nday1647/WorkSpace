from tools import poisson_homogenous
import spiking
import numpy as np
import matplotlib.pyplot as plt
import learning
import pickle
neurons = 3
model = spiking.SRM(neurons=neurons, threshold=1, t_current=0.3, t_membrane=20, eta_reset=5)
learning_model = learning.STDP(eta=0.05, w_in=0.5, w_out=0.5, tau=10.0, window_size=5)

timesteps = 100
# generate signal
# s = np.zeros([neurons, timesteps])
# s[0, :] = poisson_homogenous(0.1, timesteps)
# s[1, :] = poisson_homogenous(0.02, timesteps)
# fw = open('signal3.txt','wb')
# pickle.dump(s, fw)
# fw.close()
fr = open('signal3.txt','rb')
s = pickle.load(fr)
fr.close()
w = np.array([[0, 0, 1.0],
              [0, 0, 1.0],
              [0, 0, 0]])
total_potential = np.zeros(s.shape)
weight = np.zeros(s.shape)
for t in range(timesteps):
    total_potential[:, t] = model.check_spikes(s, w, t)
    weight_change = learning_model.weight_change(s, w, t)
    weight[:, t] = w[:, 2]
plt.figure()
plt.subplot(411)
plt.plot(weight[0, :])
plt.ylabel('input1_weight')
plt.subplot(412)
plt.plot(weight[1, :])
plt.ylabel('input2_weight')
plt.subplot(413)
plt.plot(total_potential[2, :])
plt.xlabel('timesteps')
plt.grid()
plt.ylabel('output_potential')
plt.subplot(414)
plt.plot(s[2, :])
plt.xlabel('timesteps')
plt.ylabel('output_spike')
plt.show()
