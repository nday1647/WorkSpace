# -*- coding: utf-8 -*-
from sklearn.svm import SVC


def SVMTrain(train_x, train_y):
    """
       训练SVM，生成分类模型

       输入参数
       ----------
       train_x: array-like, shape (n_samples, n_features)
                L×2m   空间滤波后的数据samples
                L: 训练数据trial总数  m: CSP 阶数
       train_y: array-like, shape (n_samples,)
                L 个trial对应的标签

       返回值
       ----------
       svmModel: object

       """
    svm_model = SVC(kernel='rbf', probability=True)
    svm_model.fit(train_x, train_y)
    return svm_model
