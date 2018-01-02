# -*- coding: utf-8 -*-
import numpy as np
from sklearn.decomposition import PCA, FastICA
from ADJBP import ADJBP

# 输入：T 采样点 x N 通道数
# 输出：T 采样点 x N 通道数


def ICAFunc(X):

    # pca = PCA()
    pca_w = PCA(whiten=True)
    ica = FastICA()

    # fit_transform
    # X: array - like, shape(n_samples, n_features)
    # returns: array-like, shape (n_samples, n_components)

    # PCAsig = pca.fit_transform(X)
    PCAsig_W = pca_w.fit_transform(X)
    ICAsig = ica.fit_transform(PCAsig_W)

    setZero = np.zeros(ICAsig.shape)
    for i in range(ICAsig.shape[1]):
        isOutlier = ADJBP(ICAsig[:,i])
        vector = ICAsig[:,i]  # 取矩阵的列
        vector[isOutlier] = 0
        setZero[:,i] = vector

    reconSetZero = pca_w.inverse_transform(ica.inverse_transform(setZero))

    return reconSetZero
