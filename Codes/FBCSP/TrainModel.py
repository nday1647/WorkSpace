# -*- coding: utf-8 -*-
from __future__ import division
import numpy as np
from Filter import BPFilter
from FBCSP import FBCSPTrain, FBCSPSpatialFilter
from SVM import SVMTrain
from MIBIF import MIBIFTrain, MIBIFSelect
# from ODICA import ICAFunc


def TrainModel(train_x, train_y):
    """
       离线训练

       输入参数
       ----------
       train_x : T×N×L ndarray
                T: 采样点数  N: 通道数  L: 训练数据trial总数
       train_y:

       返回值
       ----------
       csp_ProjMatrix: 2m×N     FBCSP 投影矩阵
       feature_set: 最佳互信息特征位置
       svm_model: svm 分类模型

    """
    # 带通滤波
    Fs = 250
    AfterFilter_train_x = BPFilter(train_x, Fs)
    # 去眼电
    # AfterICA_train_x = ICAFunc(AfterFilter_train_x)
    # FBCSP 空间投影
    m = 3
    fbcsp_ProjMatrix = FBCSPTrain(AfterFilter_train_x, train_y, m)
    AfterFBCSP_train_x = FBCSPSpatialFilter(AfterFilter_train_x, fbcsp_ProjMatrix)

    feature_set = MIBIFTrain(AfterFBCSP_train_x, train_y, 4)
    feature = MIBIFSelect(AfterFBCSP_train_x, feature_set)

    # SVM 分类模型
    svm_model = SVMTrain(np.transpose(feature), train_y)
    return fbcsp_ProjMatrix, feature_set, svm_model


