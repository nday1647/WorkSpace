# -*- coding: utf-8 -*-
from __future__ import division
import scipy.io as sio
import numpy as np
from Filter import BPFilter
from CSP import CSPTrain, CSPSpatialFilter
from SVM import SVMTrain, SVMPredict
from ODICA import ICAFunc
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
# 带通滤波
Fs = 250
filter_low = 8
filter_high = 30
AfterFilter_train_x = BPFilter(train_x, Fs, filter_low, filter_high)
# 去眼电
# AfterICA_train_x = ICAFunc(AfterFilter_train_x)
# CSP 空间投影
m = 3
F = CSPTrain(AfterFilter_train_x, train_y, m)
AfterCSP_train_x = CSPSpatialFilter(AfterFilter_train_x, F)
# SVM 分类模型
svm_model = SVMTrain(AfterCSP_train_x, train_y)

# === 测试 ===
AfterFilter_test_x = BPFilter(test_x, Fs, filter_low, filter_high)
# AfterICA_test_x = ICAFunc(AfterFilter_test_x)
AfterCSP_test_x = CSPSpatialFilter(AfterFilter_test_x, F)
predict = SVMPredict(svm_model, AfterCSP_test_x)
right_sum = np.sum(predict == test_y)
Accuracy = right_sum/test_y.size
print Accuracy