# -*- coding: utf-8 -*-
from __future__ import division
import numpy as np
import math


def MutualInfoScore(data_x, data_y):
    """
       Mutual Information 互信息计算

       输入参数
       ----------
       data_x: 2m×B×L   空间滤波后的calibration session数据
               m: CSP维数  B: 目标滤波段数  L: 训练数据trial总数
       data_y: 1D L   L 个trial对应的标签

       返回值
       ----------
       mutual_info_score: 互信息分数


    """

    feature_len = data_x.shape[0]
    filter_num = data_x.shape[1]
    trial_size = data_x.shape[2]
    (data_y == 1)

    n = len(data_x)
    std = np.std(data_y)
    h = ((4 / (3 * n)) ** (1 / 5)) * std
    sumA = np.zeros(data_x.shape)
    sumB = np.zeros(data_x.shape)
    for k in range(feature_len):
        for j in range(filter_num):
            for i in range(trial_size):
                for m in range(trial_size):
                    if data_y[k] == 1:
                        sumA[k, j, i] = sumA[k, j, i] + kernelFunc(data_x[k, j, i] - data_x[k, j, m], h)
                    else:
                        sumB[k, j, i] = sumB[k, j, i] + kernelFunc(data_x[k, j, i] - data_x[k, j, m], h)

    Pfw = (1/n)*()

def kernelFunc(y, h):


    fai = 1/((2*math.pi)**(1/2))*math.exp(-(y**2/(2*(h**2))))
    return fai
