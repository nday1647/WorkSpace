# -*- coding: utf-8 -*-
import numpy as np


def FBCSPSpatialFilter(data_x, fbcsp_ProjMatrix):
    """
       返回 FBCSP 空间滤波后的数据

       输入参数
       ----------
       data_x: T×N×B×L ndarray ( 或单个trial T×N×B )  滤波后的数据
               T: 采样点数  N: 通道数  B: 目标滤波段数  L: 训练数据trial总数
       csp_ProjMatrix: 2m×N×B
               FBCSP 投影矩阵 B个

       返回值
       ----------
       xAfterCSP: 2m×B×L (或单个trial 1D 2m×B)  空间滤波后的数据

       """

    feature_len = fbcsp_ProjMatrix.shape[0]
    filter_num = data_x.shape[2]
    if len(data_x.shape) == 4:
        trial_size = data_x.shape[3]
        xAfterCSP = np.zeros([feature_len, filter_num, trial_size])
        for k in range(filter_num):
            for i in range(trial_size):
                Z = np.dot(fbcsp_ProjMatrix[:, :, k], np.transpose(data_x[:, :, k, i]))  # 1个trial脑电信号投影后得到Z(2m×T)
                feature = np.log((Z.var(1)/(Z.var(1)).sum()).transpose())  # feature: 2m
                xAfterCSP[:, k, i] = feature
    else:
        xAfterCSP = np.zeros([feature_len, filter_num])
        for k in range(filter_num):
            Z = np.dot(fbcsp_ProjMatrix[:, :, k], np.transpose(data_x[:, :, k]))  # 1个trial脑电信号投影后得到Z(2m×T)
            feature = np.log((Z.var(1) / (Z.var(1)).sum()).transpose())  # feature: 2m
            xAfterCSP[:, k] = feature
    return xAfterCSP
