% 测试whitenv函数
clc
clear
close all
 
% 加载matlab自带的数据
load cities
stdr = std(ratings);%每一列的标准差
sr = ratings./repmat(stdr,329,1);
 
figure
boxplot(sr,'orientation','horizontal','labels',categories)
 
% 测试
firstEig = 1;
lastEig = 8;
s_interactive = 'off';
% [E, D] = pcamat(vectors, firstEig, lastEig, s_interactive, s_verbose)
%(特征值分解+选择前几主成分)
% 计算以行向量形式给出的数据的PCA矩阵。返回选择的子空间的特征向量矩阵E和对角化特征值矩阵D。
% 降维由firstEig和lastEig参数控制，但也可以设置s_interactive为'on'或'gui'来迭代计算。
% 参数说明：
% vectors     数据，以行向量表示。
% firstEig    保留的最大主成分的次序，默认为1.
% lastEig     保留的最小主成分的次序，默认等于行向量的个数。
% interactive 交互式指定特征值。如果设置为'on'或'gui'，那么参数
%             'firstEig'和'lastEig'将被忽略，但它们仍需要输入。如果设置
%             为'gui'，那么在fasticag中图形用户接口将被使用。默认为'off'。
% verbose     是否显示详细步骤，默认为'on'。 
[E, D] = pcamat(sr', firstEig, lastEig, s_interactive);

% [newVectors, whiteningMatrix, dewhiteningMatrix] = whitenv(vectors, E, D, s_verbose)
% 白化行向量数据并降维。返回白化后数据、白化变换矩阵和去白化矩阵。
% 参数说明：
% vectors     数据，以行向量表示。
% E           由函数pcamat得到的特征向量矩阵。
% D           由函数pcamat得到的对角化特征值矩阵。
% verbose     是否显示详细步骤，默认为'on'。
[nv, wm, dwm] = whitenv(sr', E, D);

figure
boxplot(nv','orientation','horizontal')