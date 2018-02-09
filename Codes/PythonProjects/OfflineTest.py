# -*- coding: utf-8 -*-
from __future__ import division
import scipy.io as sio
import numpy as np
from Filter import BPFilter
from CSP import CSPSpatialFilter
from Classifier import ClassifierPredict
from TrainModel import TrainModel
from sklearn.model_selection import train_test_split
from loadov import loadov
import matplotlib.pyplot as plt
from CAR import CARFilter
# 竞赛数据
# dataForMain = sio.loadmat(r'D:\Myfiles\EEGProject\BCICompetitionIV\2amat\A01T.mat')
# data_x = dataForMain['data_x']  # shape(750,22,137)
# data_y = dataForMain['data_y']  # shape(1,137)
# data_y = data_y.ravel()  # shape(,137)  1D
# train_size = 109
# test_size = data_x.shape[2] - train_size
# train_x = data_x[:, :, 0:train_size]
# train_y = data_y[0:train_size]
# test_x = data_x[:, :, train_size:data_x.shape[2]]
# test_y = data_y[train_size:data_x.shape[2]]

# test_x = data_x[:, :, 0:test_size]
# test_y = data_y[0:test_size]
# train_x = data_x[:, :, test_size:data_x.shape[2]]
# train_y = data_y[test_size:data_x.shape[2]]

# 采集数据
train_x1, train_y1 = loadov("D:\Myfiles\openvibefiles\MI-CSP-r1\signals\DM\DM-180202.mat")
# train_x2, train_y2 = loadov("D:\Myfiles\openvibefiles\MI-CSP-r1\signals\GH\GH-171225-acquisition-2.mat")
# train_x3, train_y3 = loadov("D:\Myfiles\openvibefiles\MI-CSP-r1\signals\GH\GH-171225-acquisition-3.mat")
# data_x = np.concatenate((train_x1, train_x2, train_x3), axis=2)
# data_y = np.concatenate((train_y1, train_y2, train_y3), axis=0)
# test_x, test_y = loadov("D:\Myfiles\openvibefiles\MI-CSP-r1\signals\GH\GH-171225-online-1.mat")
data_x = train_x1
data_y = train_y1
# test_x = train_x
# test_y = train_y

fold = 5
trial_num = data_x.shape[2]
pos = int(round(trial_num/fold))
indices = [pos, pos*2, pos*3, pos*4]
X_folds = np.split(data_x, indices, axis=2)
Y_folds = np.split(data_y, indices, axis=0)
Fs = 500
filter_low = 8
filter_high = 30
classifier_type = 'svm'  # 分类模型'svm' or 'lda'
Accuracy_sum = 0
for i in range(fold):
    train_x = np.concatenate(X_folds[:i]+X_folds[i+1:], axis=-1)
    train_y = np.concatenate(Y_folds[:i]+Y_folds[i+1:], axis=-1)
    test_x = X_folds[i]
    test_y = Y_folds[i]
    csp_ProjMatrix, classifier_model = TrainModel(train_x, train_y, Fs, filter_low, filter_high, classifier_type)
    AfterFilter_test_x = BPFilter(test_x, Fs, filter_low, filter_high)  # 带通滤波

    t = np.linspace(1, data_x.shape[0], data_x.shape[0])
    plt.figure(1)
    plt.subplot(411)
    # plt.plot(t[0:400], train_x[0:400, 3, 2])
    plt.plot(t, data_x[:, 3, 17])
    plt.subplot(412)
    # plt.plot(t[0:400], data_x[0:400, 3, 2])
    plt.plot(t, AfterFilter_test_x[:, 3, 17])
    plt.subplot(413)
    # plt.plot(t[0:400], data_x[0:400, 3, 2])
    plt.plot(t, data_x[:, 4, 17])
    plt.subplot(414)
    # plt.plot(t[0:400], data_x[0:400, 3, 2])
    plt.plot(t, AfterFilter_test_x[:, 4, 17])
    plt.show()

    AfterCAR_test_x = CARFilter(AfterFilter_test_x)  # CAR 滤波
    # AfterICA_test_x = ICAFunc(AfterFilter_test_x)
    AfterCSP_test_x = CSPSpatialFilter(AfterCAR_test_x, csp_ProjMatrix)  # CSP 空间滤波
    predict = ClassifierPredict(classifier_model, AfterCSP_test_x)  # 分类
    right_sum = np.sum(predict == test_y)
    Acc = right_sum / len(test_y)
    Accuracy_sum = Accuracy_sum + Acc
Accuracy = Accuracy_sum/fold
print Accuracy
