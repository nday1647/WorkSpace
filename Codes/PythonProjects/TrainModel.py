# -*- coding: utf-8 -*-
from __future__ import division
import numpy as np
from Filter import BPFilter
from CSP import CSPTrain, CSPSpatialFilter
from Classifier import ClassifierTrain
from CAR import CARFilter
import matplotlib.pyplot as plt
# from ODICA import ICAFunc


def TrainModel(train_x, train_y, Fs, filter_low, filter_high, classifier_type):
    """
       离线训练

       输入参数
       ----------
       train_x : T×N×L ndarray
                T: 采样点数  N: 通道数  L: 训练数据trial总数
       train_y : L

       返回值
       ----------
       csp_ProjMatrix: 2m×N     CSP 投影矩阵
       svm_model: svm 分类模型

    """
    # 带通滤波
    # AfterFilter_train_x = BPFilter(train_x, Fs, filter_low, filter_high)

    # t = np.linspace(1, train_x.shape[0], train_x.shape[0])
    # plt.figure(1)
    # plt.subplot(411)
    # # plt.plot(t[0:400], train_x[0:400, 3, 2])
    # plt.plot(t, train_x[:, 3, 19])
    # plt.subplot(412)
    # # plt.plot(t[0:400], data_x[0:400, 3, 2])
    # plt.plot(t, AfterFilter_train_x[:, 3, 19])
    # plt.subplot(413)
    # # plt.plot(t[0:400], data_x[0:400, 3, 2])
    # plt.plot(t, train_x[:, 4, 19])
    # plt.subplot(414)
    # # plt.plot(t[0:400], data_x[0:400, 3, 2])
    # plt.plot(t, AfterFilter_train_x[:, 4 , 19])
    # plt.show()

    # CAR 滤波
    # AfterCAR_train_x = CARFilter(AfterFilter_train_x)
    # 去眼电R
    # AfterICA_train_x = ICAFunc(AfterFilter_train_x)
    # CSP 空间投影
    m = 2
    csp_ProjMatrix = CSPTrain(train_x, train_y, m)
    AfterCSP_train_x = CSPSpatialFilter(train_x, csp_ProjMatrix)
    # Classifier 分类模型
    classifier_model = ClassifierTrain(AfterCSP_train_x, train_y, classifier_type)
    return csp_ProjMatrix, classifier_model


