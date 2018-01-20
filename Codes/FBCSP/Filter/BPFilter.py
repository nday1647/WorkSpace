# -*- coding: utf-8 -*-
from __future__ import division
import numpy as np
import scipy.signal as signal
def BPFilter(data_x, Fs):
    """
       IIR 带通滤波,返回4–8, 8–12,…, 36–40 Hz 9个带通

       输入参数
       ----------
       data_x: T×N×L ndarray(或单个trial T×N)
               T: 采样点数  N: 通道数  L: 训练数据trial总数
           Fs: 采样频率

       返回值
       ----------
       AfterFilter_x: T×N×B×L ndarray ( 或单个trial T×N×B )
                      T: 采样点数  N: 通道数  B: 目标滤波段数  L: 训练数据trial总数

       """

    channel_num = data_x.shape[1]
    filter = [4, 8, 12, 16, 20, 24, 28, 32, 36, 40]
    filter_num = len(filter) - 1
    Wn = [i/(Fs/2) for i in filter]
    Wn1 = Wn[0:9]
    Wn2 = Wn[1:]

    # 输入为多个trial时
    if len(data_x.shape) == 3:
        trial_size = data_x.shape[2]
        AfterFilter_x = np.zeros([data_x.shape[0], channel_num, filter_num, trial_size])
        for i in range(trial_size):
            for j in range(filter_num):
                for k in range(channel_num):
                    b, a = signal.iirdesign([Wn1[j], Wn2[j]], [Wn1[j] - 0.02, Wn2[j] + 0.02], 2, 40)
                    AfterFilter_x[:, k, j, i] = signal.lfilter(b, a, data_x[:, k, i])
    # 输入为单个trial
    else:
        AfterFilter_x = np.zeros([data_x.shape[0], channel_num, filter_num])
        for i in range(filter_num):
            for j in range(channel_num):
                b, a = signal.iirdesign([Wn1[i], Wn2[i]], [Wn1[i] - 0.05, Wn2[i] + 0.05], 2, 40)
                AfterFilter_x[:, j, i] = signal.lfilter(b, a, data_x[:, j])
    return AfterFilter_x
