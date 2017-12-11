function [icasig, A, W, wm, dwm] = PCA_ICA(data, firstEig, lastEig)
%PCA&ICA 此处显示有关此函数的摘要
%   此处显示详细说明
s_interactive = 'off';
[E, D] = pcamat(data, firstEig, lastEig, s_interactive);
% [newVectors, whiteningMatrix, dewhiteningMatrix]dwm去白化矩阵
[nv, wm, dwm] = whitenv(data, E, D);
% W为解混矩阵，A为混合矩阵
[icasig, A, W] = fastica (nv);
end

