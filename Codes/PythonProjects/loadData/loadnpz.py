# -*- coding: utf-8 -*-
import numpy as np
import random
from Filter import BPFilter
from CAR import CARFilter


def loadnpz(filepath):
    """
       读npz文件，生成滑窗后数据 (CAR -> 带通滤波)

       输入参数
       ----------
       filepath: npz文件路径

       返回值
       ----------
       signal3d: T×N×L ndarray
                 T: 采样点数  N: 通道数  L: 训练数据trial总数
       signal_label: shape (n_samples,)
                L 个trial对应的标签


       """
    BPdata = np.load(filepath)
    Firsttime = BPdata.f.fistsignal - 20/500.0
    Stim = BPdata.f.mark
    Data = BPdata.f.signal[:, 0:15]

    # CAR
    Data = CARFilter(Data)
    # 带通滤波
    Fs = 500
    filter_low = 8
    filter_high = 30
    Data = BPFilter(Data, Fs, filter_low, filter_high)

    StiminSignal = np.zeros([Data.shape[0], 2])
    for i in range(Data.shape[0]):
        StiminSignal[i, 0] = Firsttime + i/500.0
    for i in range(1, Stim.shape[0]):
        index = int((Stim[i, 0] - Firsttime) * 500)
        if(StiminSignal[index, 1] == 0):
            StiminSignal[index, 1] = Stim[i, 1]
        else:
            StiminSignal[index+1, 1] = Stim[i, 1]
    # 获取分类 label 值及位置
    pos = []
    label = []
    trialsize = 0
    for i in range(StiminSignal.shape[0]):
        if StiminSignal[i, 1] == 769 or StiminSignal[i, 1] == 770:
            trialsize = trialsize + 1
            label.append(StiminSignal[i, 1] - 769)  # label 0/1
            pos.append(i)
    # 滑窗
    width = 3000  # 单个trial 的总长
    step = 100  # 步长
    window_size = 500  # 窗的大小
    delay = 500  # cue 出现后延迟
    window_num = int((width - delay - window_size) / step + 1)  # 每个trial 滑多少个窗
    j = 0
    signal_label = np.zeros(trialsize * window_num)
    channal_num = Data.shape[1]
    signal3d = np.zeros([window_size, channal_num, trialsize * window_num])
    for k in range(len(label)):
        for i in range(window_num):
            signal_label[j] = label[k]
            start = int(pos[k] + i * step + delay)
            signal3d[:, :, j] = Data[start:start + window_size, :]
            j = j + 1
    # 打乱次序
    li = list(range(signal3d.shape[2]))
    random.shuffle(li)
    signal3d = signal3d[:, :, li]
    signal_label = signal_label[li]
    return signal3d, signal_label



if __name__ == "__main__":
    import scipy.io as sio
    Data, label = loadnpz("D:\\Myfiles\\EEGProject\\Neuroscan\\signals\\PanLi\\NSsignal_2018_04_10_19_46_40.npz")
    sio.savemat('PLNSsignal_2_data.mat', {'data_x': Data, 'data_y': label})
