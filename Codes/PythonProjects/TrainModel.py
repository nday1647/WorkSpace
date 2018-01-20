# -*- coding: utf-8 -*-
from __future__ import division

from Filter import BPFilter
from CSP import CSPTrain, CSPSpatialFilter
from SVM import SVMTrain
# from ODICA import ICAFunc

def TrainModel(train_x, train_y):
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
    Fs = 250
    filter_low = 8
    filter_high = 30
    AfterFilter_train_x = BPFilter(train_x, Fs, filter_low, filter_high)
    # 去眼电
    # AfterICA_train_x = ICAFunc(AfterFilter_train_x)
    # CSP 空间投影
    m = 3
    csp_ProjMatrix = CSPTrain(AfterFilter_train_x, train_y, m)
    AfterCSP_train_x = CSPSpatialFilter(AfterFilter_train_x, csp_ProjMatrix)
    # SVM 分类模型
    svm_model = SVMTrain(AfterCSP_train_x, train_y)
    return csp_ProjMatrix, svm_model


