# -*- coding: utf-8 -*-
from __future__ import division
import numpy as np
import scipy.signal as signal
def BPFilter(data_x, Fs, filter_low, filter_high):
    """
       IIR 带通滤波

       输入参数
       ----------
       data_x: T×N×L ndarray
               T: 采样点数  N: 通道数  L: 训练数据trial总数
           Fs: 采样频率

       返回值
       ----------
       AfterFilter_x: T×N×L

       """

    Wn1 = filter_low/(Fs/2)
    Wn2 = filter_high/(Fs/2)
    b, a = signal.iirdesign([Wn1, Wn2], [Wn1-0.05, Wn2+0.05], 2, 40)
    channel_num = data_x.shape[1]
    trial_size = data_x.shape[2]
    AfterFilter_x = np.zeros(data_x.shape)

    for i in range(trial_size):
        for j in range(channel_num):
            AfterFilter_x[:, j, i] = signal.lfilter(b, a, data_x[:, j, i])

    return AfterFilter_x