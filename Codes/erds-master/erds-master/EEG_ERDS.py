from erds import Erds
import numpy as np
from loadov import loadov
import scipy.io as sio
# input_data(n_epochs, n_channels, n_samples)

# dataForMain = sio.loadmat(r'D:\Myfiles\EEGProject\BCICompetitionIV\2amat\A01T.mat')
# x = dataForMain['data_x']  # shape(n_samples,n_channels,n_epochs)
# y = dataForMain['data_y']  # shape(1,n_epochs)
# y = y.ravel()  # shape(,n_epochs)  1D

x, y = loadov("D:\Myfiles\openvibefiles\MI-CSP-r1\signals\GH\GH-171225-online-1.mat")
[n_samples, n_channels, n_epochs] = x.shape
n_epochs_class1 = np.sum(y == 1)
n_epochs_class2 = np.sum(y == 0)
data_x_class1 = np.zeros([n_epochs_class1, n_channels, n_samples])
data_x_class2 = np.zeros([n_epochs_class2, n_channels, n_samples])
for i in range(n_epochs):
    if y[i] == 1:
        data_x_class1 = data_x_class1 + np.transpose(x[:, :, i])
    else:
        data_x_class2 = data_x_class2 + np.transpose(x[:, :, i])
maps = Erds()
maps.fit(data_x_class1, fs=500)  # data must be available in appropriate format
fig = maps.plot()