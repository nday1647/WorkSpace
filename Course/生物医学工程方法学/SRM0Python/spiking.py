#/usr/bin/python3
import numpy as np
import functools
import matplotlib.pyplot as plt
class SRM:
    """ SRM_0 (Spike Response Model) """
    def __init__(self, neurons, threshold, t_current, t_membrane, eta_reset, simulation_window_size=100):
        threshold = np.array(threshold)
        t_current = np.array(t_current)
        t_membrane = np.array(t_membrane)
        eta_reset = np.array(eta_reset)

        self.neurons = neurons
        self.threshold = threshold
        self.t_current = t_current
        self.t_membrane = t_membrane
        self.eta_reset = eta_reset
        self.simulation_window_size = simulation_window_size
        self.cache = {}
        self.cache['last_t'] = -1
        self.cache['last_spike'] = np.ones(self.neurons, dtype=float) * -1000000
        self.cache['last_potential'] = np.zeros(self.neurons, dtype=float)

    def eta(self, s):
        return - self.eta_reset*np.exp(-s/self.t_membrane)

    @functools.lru_cache()
    def eps(self, s):
        return (1/(1-self.t_current/self.t_membrane))*(np.exp(-s/self.t_membrane) - np.exp(-s/self.t_current))

    @functools.lru_cache()
    def eps_matrix(self, k, size):
        matrix = np.zeros((self.neurons, size), dtype=float)
        for i in range(k):
            matrix[:, i] = self.eps(k-i)
        return matrix

    def check_spikes(self, spiketrain, weights, t, additional_term=None):

        spiketrain_window = spiketrain[:, max(0, t+1-self.simulation_window_size):t+1]

        # Retrieve necessary simulation data from cache if possible
        if self.cache['last_t'] == -1 or self.cache['last_t'] == t - 1:
            last_spike = self.cache['last_spike']
            last_potential = self.cache['last_potential']
        else:
            last_spike = t - np.argmax(spiketrain_window[:, ::-1], axis=1)
            # TODO find a way to calculate last_potential (recursive call to check_spikes is not a good option)
            last_potential = np.zeros(self.neurons)

        neurons, timesteps = spiketrain_window.shape

        epsilon_matrix = self.eps_matrix(min(self.simulation_window_size, t), timesteps)

        # Calculate current
        incoming_spikes = np.dot(weights.T, spiketrain_window)
        incoming_potential = np.sum(incoming_spikes * epsilon_matrix, axis=1)
        total_potential = self.eta(np.ones(neurons)*t - last_spike) + incoming_potential

        # Only spike if potential hits the threshold from below.
        neurons_high_current = np.where((total_potential >= self.threshold) & (last_potential < self.threshold))
        spiketrain[neurons_high_current, t] = True

        # Update cache (last_spike, last_potential and last_t)
        spiking_neurons = np.where(spiketrain[:, t])
        self.cache['last_spike'][spiking_neurons] = t
        self.cache['last_potential'] = total_potential
        self.cache['last_t'] = t

        return total_potential

if __name__ == "__main__":
    from scipy import sparse
    from tools import poisson_homogenous
    neurons = 3
    model = SRM(neurons=neurons, threshold=1, t_current=0.3, t_membrane=20, eta_reset=5)
    row = np.array([0, 0, 1, 1, 1, 1])
    col = np.array([5, 100, 140, 200, 300, 310])
    data = np.ones(len(col))
    s = sparse.coo_matrix((data, (row, col)), shape=(3, 450))
    s = s.toarray()
    timesteps = 450
    # s = np.zeros([neurons, timesteps])
    # s[0, :] = poisson_homogenous(0.05, 200)
    # s[1, :] = poisson_homogenous(0.05, 200)
    w = np.array([[0, 0, 1.2],
                  [0, 0, 0.8],
                  [0, 0, 0]])
    total_potential = np.zeros(s.shape)
    for t in range(timesteps):
        total_potential[:, t] = model.check_spikes(s, w, t)
    plt.figure()
    plt.subplot(411)
    plt.plot(s[0, :])
    plt.ylabel('weight1=1.2')
    plt.subplot(412)
    plt.plot(s[1, :])
    plt.ylabel('weight2=0.8')
    plt.subplot(413)
    plt.plot(total_potential[2, :])
    plt.xlabel('timesteps')
    plt.ylabel('output_potential')
    plt.grid()
    plt.subplot(414)
    plt.plot(s[2, :])
    plt.xlabel('timesteps')
    plt.ylabel('output_spike')

    plt.show()
