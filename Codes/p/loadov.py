# -*- coding: utf-8 -*-
import scipy.io as sio
import numpy as np
import matplotlib.pyplot as plt
from sklearn import preprocessing

def loadov(path):

    # data = sio.loadmat(r'D:\Myfiles\openvibefiles\MI-CSP-r1\signals\GH\GH-171225-acquisition-2.mat')
    data = sio.loadmat(path)
    Fs = data['samplingFreq']  # 采样 500Hz
    data_x = data['samples']  # 数据
    data_x_time = data['sampleTime']
    data_x_time = data_x_time[:, 0].tolist()
    stims = data['stims']  # 标签[time; ID; duration] (10个769,10个770)
    channel_names=[]
    for ch in data['channelNames'][0]:
        channel_names.append(ch[0])
    info={}
    info['channal']=channel_names
    info['rate']=Fs

    # 确定 769/770 cue 出现位置
    label = []
    label_time= []
    trialsize = 0
    for i in range(stims.shape[0]):
        if stims[i, 1] == 769 or stims[i, 1] == 770:
            trialsize = trialsize + 1
            label.append(stims[i, 1]-769)
            label_time.append(stims[i, 0])
    pos = []
    for i in range(len(label_time)):
        for j in range(len(data_x_time)):
            if data_x_time[j] > label_time[i]:
                pos.append(j)
                break


    width = 2500
    overlap = 0
    length = 2500
    window_num = int((length - width) / ((1 - overlap) * width) + 1)
    j = 0
    signal_label = []
    channal_num = data_x.shape[1]
    signal3d = np.zeros([width, channal_num, trialsize * window_num])
    for k in range(len(label)):
        for i in range(window_num):
            signal_label.append(label[k])
            start = int(pos[k] + i * ((1 - overlap) * width))
            signal3d[:, :, j] = data_x[start:start + width, :]
            j = j + 1

    # data_x = reduceModerate(signal3d, signal_label)
    data_x = normalizeDatax(signal3d)

    # t = np.linspace(1, data_x.shape[0], data_x.shape[0])
    #plt.figure(1)
    #plt.subplot(211)
    # plt.plot(t[0:400], train_x[0:400, 3, 2])
    #plt.plot(t, data_x[:, 2, 30])
    #plt.subplot(212)
    # plt.plot(t[0:400], data_x[0:400, 3, 2])
    #plt.plot(t, data_x[:, 3, 30])
    #plt.show()

    return data_x, signal_label, info


def reduceModerate(signal3d, signal_label):
    # 减静息态均值
    data_x = np.zeros(signal3d.shape)
    samples = signal3d.shape[0]
    sum = np.zeros(signal3d.shape[1])
    for i in range(len(signal_label)):
        if signal_label[i] == 1:
            for j in range(samples):
                sum = sum + signal3d[j, :, i]
            mean = sum / samples
            break
        else:
            continue
    for i in range(len(signal_label)):
        for j in range(samples):
            data_x[j, :, i] = signal3d[j, :, i] - np.transpose(mean)
    return data_x

def normalizeDatax(signal3d):
    # 归一化
    data_x = np.zeros(signal3d.shape)
    channal_num = signal3d.shape[1]
    for i in range(signal3d.shape[2]):
        for j in range(channal_num):
            data_x[:, j, i] = preprocessing.scale(signal3d[:, j, i])
    return data_x


