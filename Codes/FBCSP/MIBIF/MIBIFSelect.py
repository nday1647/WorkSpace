# -*- coding: utf-8 -*-
import numpy as np


def MIBIFSelect(data_x, feature_set):
    """
       Mutual Information-based Best Individual Feature, MIBIF
       根据位置筛选对应的特征，得到新的训练数据

       输入参数
       ----------
       data_x: 2m×B×L (或单个trial 1D 2m×B)  空间滤波后的数据
               m: CSP维数  B: 目标滤波段数  L: 训练数据trial总数
       feature_set: type'set'  互信息最大的n个特征及其成对特征的位置 n~2n 个

       返回值
       ----------
       feature:  (n~2n)×L (或单个trial 1D n~2n)

    """
    feature_len = len(feature_set)
    if len(data_x.shape) == 3:
        trial_size = data_x.shape[2]
        feature = np.zeros([feature_len, trial_size])
        for i in range(trial_size):
            index = 0
            for j in feature_set:
                feature[index, i] = data_x[j[0], j[1], i]
                index = index + 1
    else:
        feature = np.zeros(feature_len)
        index = 0
        for j in feature_set:
            feature[index] = data_x[j[0], j[1]]
            index = index + 1
    return feature
