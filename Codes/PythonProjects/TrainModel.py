# -*- coding: utf-8 -*-
from __future__ import division
import numpy as np
from Filter import BPFilter
from CSP import CSPTrain, CSPSpatialFilter
from Classifier import ClassifierTrain
from CAR import CARFilter
import matplotlib.pyplot as plt
# from ODICA import ICAFunc


def TrainModel(train_x, train_y, classifier_type, m):
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
       classifier_model:  分类模型
       classifier_type: str 'svm' or 'lda'
       m: CSP 参数

    """
    # 带通滤波
    # AfterFilter_train_x = BPFilter(train_x, Fs, filter_low, filter_high)
    # CAR 滤波
    # AfterCAR_train_x = CARFilter(AfterFilter_train_x)
    # 去眼电R
    # AfterICA_train_x = ICAFunc(AfterFilter_train_x)
    # CSP 空间投影
    csp_ProjMatrix = CSPTrain(train_x, train_y, m)
    AfterCSP_train_x = CSPSpatialFilter(train_x, csp_ProjMatrix)
    # Classifier 分类模型
    classifier_model = ClassifierTrain(AfterCSP_train_x, train_y, classifier_type)
    return csp_ProjMatrix, classifier_model


