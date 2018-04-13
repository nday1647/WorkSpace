# -*- coding: utf-8 -*-
from __future__ import division
import numpy as np
from CSP import CSPSpatialFilter
from Classifier import ClassifierPredict
from TrainModel import TrainModel
from loadData.loadnpz import loadnpz
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
train_x1, train_y1 = loadnpz('D:\\Myfiles\\EEGProject\\Neuroscan\\signals\\PanLi\\NSsignal_2018_04_10_19_34_41.npz')
train_x2, train_y2 = loadnpz('D:\\Myfiles\\EEGProject\\Neuroscan\\signals\\PanLi\\NSsignal_2018_04_10_19_46_40.npz')

# train_x1, train_y1 = loadov("D:\Myfiles\openvibefiles\MI-CSP-r1\signals\GH\GH-171225-online-1.mat")
# train_x2, train_y2 = loadov("D:\Myfiles\openvibefiles\MI-CSP-r1\signals\GH\GH-171225-acquisition-2.mat")
# train_x3, train_y3 = loadov("D:\Myfiles\openvibefiles\MI-CSP-r1\signals\GH\GH-171225-acquisition-3.mat")
train_x = np.concatenate((train_x1, train_x2), axis=2)
train_y = np.concatenate((train_y1, train_y2), axis=0)
# test_x, test_y = loadov("D:\Myfiles\openvibefiles\MI-CSP-r1\signals\GH\GH-171225-online-1.mat")
test_x, test_y = loadnpz('D:\\Myfiles\\EEGProject\\Neuroscan\\signals\\PanLi\\NSsignal_2018_04_10_19_19_01.npz')
# data_x = train_x
# data_y = train_y
# test_x = train_x
# test_y = train_y

fold = 5
# trial_num = data_x.shape[2]
# pos = int(round(trial_num/fold))
# indices = [pos, pos*2, pos*3, pos*4]
# X_folds = np.split(data_x, indices, axis=2)
# Y_folds = np.split(data_y, indices, axis=0)
m = 2  # CSP 参数
# Fs = 500
# filter_low = 8
# filter_high = 30
classifier_type = 'svm'  # 分类模型 'svm' or 'lda'
Accuracy_sum = 0
for i in range(fold):
    # train_x = np.concatenate(X_folds[:i]+X_folds[i+1:], axis=-1)
    # train_y = np.concatenate(Y_folds[:i]+Y_folds[i+1:], axis=-1)
    # test_x = X_folds[i]
    # test_y = Y_folds[i]
    csp_ProjMatrix, classifier_model = TrainModel(train_x, train_y, classifier_type, m)
    # AfterFilter_test_x = BPFilter(test_x, Fs, filter_low, filter_high)  # 带通滤波
    # AfterCAR_test_x = CARFilter(AfterFilter_test_x)  # CAR 滤波
    # AfterICA_test_x = ICAFunc(AfterFilter_test_x)
    AfterCSP_test_x = CSPSpatialFilter(test_x, csp_ProjMatrix)  # CSP 空间滤波
    predict = ClassifierPredict(classifier_model, AfterCSP_test_x)  # 分类
    right_sum = np.sum(predict == test_y)
    Acc = right_sum / len(test_y)
    Accuracy_sum = Accuracy_sum + Acc
Accuracy = Accuracy_sum / fold
print(Accuracy)
