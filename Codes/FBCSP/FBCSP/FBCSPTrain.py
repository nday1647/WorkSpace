# -*- coding: utf-8 -*-
from __future__ import division
import numpy as np
import scipy.linalg as la


def FBCSPTrain(train_x, train_y, m):
    """
       训练FBCSP模型，生成B个投影矩阵F

       输入参数
       ----------
       train_x: T×N×B×L ndarray
                T: 采样点数  N: 通道数  B: 目标滤波段数  L: 训练数据trial总数
       train_y: 1 维 L 个
                L个trial对应的标签（二类）
             N: int 提取的CSP特征对数

       返回值
       ----------
       fbcsp_ProjMatrix: 2m×N×B
                FBCSP 投影矩阵(每个带通滤波一个2m×N投影矩阵)

       """
    train_size = train_x.shape[3]  # shape从0开始计数
    filter_num = train_x.shape[2]
    channel_num = train_x.shape[1]
    fbcsp_ProjMatrix = np.zeros([2*m, channel_num, filter_num])
    for k in range(filter_num):
        R = np.zeros([channel_num, channel_num, train_size])  # R: N×N×L
        for i in range(train_size):
            # R=X'*X/tr(X'*X) 协方差矩阵(对称矩阵)
            dot = np.dot(np.transpose(train_x[:, :, k, i]), train_x[:, :, k, i])
            R[:, :, i] = dot/np.trace(dot)
        # 初始化R1，R2
        R1 = np.zeros([channel_num,channel_num])  # R1/R2: N×N
        R2 = R1
        countL = 0
        countR = 0
        # 按数据标签分类，分别赋给R1,R2, 类1 train_y=1,类2 train_y=-1
        for i in range(train_size):
            if train_y[i] == 1:
                R1 = R1 + R[:, :, i]  # 求和
                countL = countL + 1
            else:
                R2 = R2 + R[:, :, i]
                countR = countR + 1
        # 协方差矩阵的归一化
        # R1=R1/trace(R1)
        # R2=R2/trace(R2)
        R1 = R1/countL
        R2 = R2/countR
        R3 = R1+R2
        # E,U = la.eig(R) 返回矩阵R的特征值E和特征向量U
        Sigma, U0 = la.eig(R3)
        # 构造白化变换矩阵P
        P = np.dot(np.sqrt(la.inv(np.diag(Sigma))), np.transpose(U0))
        # 利用P对R1进行变换
        YL = np.dot(np.dot(P, R1), np.transpose(P))
        YR = np.dot(np.dot(P, R2), np.transpose(P))
        # 特征值分解(同时对角化）
        SigmaL, UL = la.eig(YL,YR)
        # argsort(x)升序  argsort(-x)降序
        # 返回SigmaL降序排序后元素在原数组中的位置I
        I = np.argsort(-SigmaL)
        I = (np.hstack((I[0:m], I[channel_num-m:channel_num]))).tolist()
        # 取降序排序后特征向量UL的列向量的前m和后m个（最大m个&最小m个）
        ProjMatrix = np.real(np.dot(np.transpose(UL[:, I]), P))
        fbcsp_ProjMatrix[:, :, k] = ProjMatrix
    return fbcsp_ProjMatrix