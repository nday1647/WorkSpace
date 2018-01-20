# -*- coding: utf-8 -*-
from __future__ import division
import scipy.io as sio
import numpy as np
from Filter import BPFilter
from CSP import CSPSpatialFilter
from SVM import SVMPredict
from TrainModel import TrainModel
dataForMain = sio.loadmat(r'D:\Myfiles\WorkSpace\Codes\PythonProjects\Data\dataForMain.mat')
data_x = dataForMain['data_x']  # shape(750,22,137)
data_y = dataForMain['data_y']  # shape(1,137)
data_y = data_y.ravel()  # shape(,137)  1D
train_size = 60
test_size = data_x.shape[2] - train_size
train_x = data_x[:, :, 0:train_size]
train_y = data_y[0:train_size]
test_x = data_x[:, :, train_size:data_x.shape[2]]
test_y = data_y[train_size:data_x.shape[2]]

csp_ProjMatrix, svm_model = TrainModel(train_x, train_y)

Fs = 250
filter_low = 8
filter_high = 30

AfterFilter_test_x = BPFilter(test_x, Fs, filter_low, filter_high)
# AfterICA_test_x = ICAFunc(AfterFilter_test_x)
AfterCSP_test_x = CSPSpatialFilter(AfterFilter_test_x, csp_ProjMatrix)
predict = SVMPredict(svm_model, AfterCSP_test_x)
right_sum = np.sum(predict == test_y)
Accuracy = right_sum/test_y.size
print Accuracy