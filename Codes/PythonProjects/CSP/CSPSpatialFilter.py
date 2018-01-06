# -*- coding: utf-8 -*-
import numpy as np


def CSPSpatialFilter(data_x, F):
    """
       返回 CSP 空间滤波后的数据

       输入参数
       ----------
       data_x: T×N×L ndarray
               T: 采样点数  N: 通道数  L: 训练数据trial总数
            F: 2m×N
               CSP 投影矩阵

       返回值
       ----------
       xAfterCSP: L×2m   空间滤波后的数据

       """
    trial_size = data_x.shape[2]
    feature_len = F.shape[0]
    xAfterCSP = np.zeros([trial_size, feature_len])
    for i in range(trial_size):
        Z = np.dot(F, np.transpose(data_x[:, :, i]))  # 1个trial脑电信号投影后得到Z(2m×T)
        feature = np.log((Z.var(1)/(Z.var(1)).sum()).transpose())  # feature: 2m
        xAfterCSP[i, :] = feature
    return xAfterCSP
