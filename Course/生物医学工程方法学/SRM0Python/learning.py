import numpy as np

class STDP:
    """Spike Timing Dependent Plasticity"""
    def __init__(self, eta, w_in, w_out, tau, window_size, tau2=None):
        """
        :param eta: learning rate
        :param w_in:
        :param w_out:
        :param tau: The tau parameter for the learning window. If you want an unsymmetric window, then also set tau2.
        :param window_size:
        :param tau2: If learning window is unsymmetric, then tau2 is the tau parameter for x-values GREATER than 0. If not given, it defaults to tau.
        :return:
        """
        self.eta = eta
        self.w_in = w_in
        self.w_out = w_out
        self.tau = tau
        self.tau2 = tau2 if tau2 else tau
        self.window_size = window_size

    def learning_window_neuron_pre(self, t1, t2_list):
        sum_result = 0
        for t2 in t2_list:
            sum_result += self.learning_window(t2 - t1)
        return sum_result

    def learning_window_neuron_post(self, t1, t2_list):
        sum_result = 0
        for t2 in t2_list:
            sum_result += self.learning_window(t1 - t2)
        return sum_result

    def learning_window(self, x):
        if x > 0:
            return - np.exp(-x / self.tau2)
        elif x < 0:
            return np.exp(x / self.tau)
        else:
            return 0

    def weight_change(self, spikes, weights, t):
        spikes = spikes[:, max(0, t+1-self.window_size):t+1]
        neurons, current_time = spikes.shape
        current_time -= 1
        connected_neurons = np.array(weights, dtype=bool)
        last_spikes = spikes[:, -1]
        last_spikes = last_spikes[:, np.newaxis]

        # Calculate the weight change for presynaptic spikes
        weight_change_presynaptic = last_spikes * connected_neurons * self.w_in

        # Calculate the weight change for postsynaptic spikes
        weight_change_postsynaptic = last_spikes.T * connected_neurons * self.w_out

        # Calculate the weight changes in regards of the learning window
        spikes_time = []
        for neuron in range(neurons):
            spikes_time.append([])
            for time, spike in enumerate(spikes[neuron, :]):
                if spike:
                    spikes_time[neuron].append(time)

        neuron_learnwindow_pre = [self.learning_window_neuron_pre(current_time, x) for x in spikes_time]
        neuron_learnwindow_pre = np.array(neuron_learnwindow_pre, ndmin=2).T  # Make it a column-vector

        neuron_learnwindow_post = [self.learning_window_neuron_post(current_time, x) for x in spikes_time]
        neuron_learnwindow_post = np.array(neuron_learnwindow_post, ndmin=2).T  # Make it a column-vector
        a = (last_spikes.T * connected_neurons)
        learning_window_presynaptic = (last_spikes.T * connected_neurons) * neuron_learnwindow_pre
        learning_window_postsynaptic = (last_spikes * connected_neurons) * neuron_learnwindow_post.T

        # Total weight change
        weight_change = self.eta * (weight_change_presynaptic + weight_change_postsynaptic + learning_window_presynaptic
                               + learning_window_postsynaptic)

        # Change the weight in place
        weights.__iadd__(weight_change)
        return weight_change


if __name__ == "__main__":
    from scipy import sparse
    # row = np.array([0, 0, 0, 0, 1, 1,  2, 2, 2])
    # col = np.array([1, 20, 40, 41, 23, 22, 2, 21, 41])
    # data = np.ones(len(col))
    # s = sparse.coo_matrix((data, (row, col)), shape=(3, 50))
    # s = s.toarray()
    s = np.array([[0, 0, 1, 0, 0, 0, 0, 0, 1, 0],
                  [1, 0, 0, 0, 1, 1, 0, 0, 0, 0],
                  [0, 1, 0, 0, 0, 0, 0, 1, 0, 0]], dtype=bool)

    w = np.array([[0, 0, 1],
                  [0, 0, 1],
                  [0, 0, 0]], dtype=float)
    learning_model = STDP(eta=0.05, w_in=0.5, w_out=0.5, tau=10.0, window_size=3)
    neurons, timesteps = s.shape
    weight = np.zeros(s.shape)
    for t in range(timesteps):
        learning_model.weight_change(s, w, t)
        weight[:, t] = w[:, -1]
    print("updated weights", w)
    print("weights", weight)

    import matplotlib.pyplot as plt
    plt.figure()
    plt.subplot(311)
    plt.plot(s[0, :])
    plt.ylabel('cell1')
    plt.subplot(312)
    plt.plot(s[1, :])
    plt.ylabel('cell2')
    plt.subplot(313)
    plt.plot(s[2, :])
    plt.xlabel('timesteps')
    plt.ylabel('cell3')
    plt.grid()
    plt.show()
