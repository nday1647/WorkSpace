# -*- coding: utf-8 -*-
from sklearn import metrics as mr
import numpy as np
from MutualInfoScore import MutualInfoScore


def MIBIFTrain(data_x, data_y, n):
    """
       Mutual Information-based Best Individual Feature, MIBIF
       得到互信息最大的n个特征及其配对特征的位置

       输入参数
       ----------
       data_x: 2m×B×L   空间滤波后的calibration session数据
               m: CSP维数  B: 目标滤波段数  L: 训练数据trial总数
       data_y: 1D L  L 个trial对应的标签

       返回值
       ----------
       feature_set: type'set'  互信息最大的n个特征及其成对特征的位置 n~2n 个
                    坐标(CSP维度, 滤波带序号)


    """
    feature_len = data_x.shape[0]
    filter_num = data_x.shape[1]
    # MutualInfo = np.zeros([feature_len, filter_num])
    # for i in range(filter_num):
    #     for j in range(feature_len):
    #         MutualInfo[j, i] = mr.mutual_info_score(data_y, data_x[j, i, :])
    MutualInfo = MutualInfoScore(data_x, data_y)
    MutualInfo1D = MutualInfo.reshape(-1)  # 降到一维
    pos = np.argsort(-MutualInfo1D)  # 降序排列 返回位置序列
    # 选择互信息最大的前n个，若与已选特征成对的特征未被选入则加入
    feature_set = set()
    list = []
    for i in range(n):
        post = divmod(pos[i], filter_num)
        list.append(post)
    for i in list:
        feature_set.add(i)
        feature_set.add((feature_len-1-i[0], i[1]))

    return feature_set
