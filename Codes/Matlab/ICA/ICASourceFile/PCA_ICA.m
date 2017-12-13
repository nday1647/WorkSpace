function [icasig, A, W, wm, dwm] = PCA_ICA(data)
%PCA&ICA 此处显示有关此函数的摘要
[E, D] = pcamat(data);
% [newVectors, whiteningMatrix, dewhiteningMatrix],其中dwm是去白化矩阵
[nv, wm, dwm] = whitenv(data, E, D);
% W为解混矩阵，A为混合矩阵
[icasig, A, W] = fastica (nv);
end

