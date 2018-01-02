# -*- coding: utf-8 -*-
import scipy.io as sio
from CSPTrain import CSPTrain
from CSPSpatialFilter import CSPSpatialFilter
trainx = sio.loadmat(r'D:\Myfiles\WorkSpace\Codes\PythonProjects\Data\trainx.mat')
trainy = sio.loadmat(r'D:\Myfiles\WorkSpace\Codes\PythonProjects\Data\trainy.mat')
train_x = trainx['train_x'] # shape(750,22,60)
train_y = trainy['train_y'] # shape(1,60)
m = 3
F = CSPTrain(train_x, train_y, m)
xAfterCSP = CSPSpatialFilter(train_x, F)