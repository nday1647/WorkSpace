# -*- coding: utf-8 -*-
from __future__ import division
import scipy.io as sio
import numpy as np
import time
import serial
from Filter import BPFilter
from FBCSP import CSPSpatialFilter
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

try:
    t = serial.Serial('COM1', 9600)
except Exception, e:
    print 'open serial failed.'

# 以trial为单位输出结果
for i in range(10):
    Onetrial_test_x = test_x[:, :, i]
    AfterFilter_test_x = BPFilter(Onetrial_test_x, Fs, filter_low, filter_high)
    AfterCSP_test_x = CSPSpatialFilter(AfterFilter_test_x, csp_ProjMatrix)
    predict = SVMPredict(svm_model, AfterCSP_test_x)


    t.write(str(predict[0]))
    time.sleep(1)
    # print predict, test_y[i]
# 以block为单位输出结果
t.close()

