function [icasig, A, W, wm, dwm] = PCA_ICA(data, firstEig, lastEig)
%PCA&ICA �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
s_interactive = 'off';
[E, D] = pcamat(data, firstEig, lastEig, s_interactive);
% [newVectors, whiteningMatrix, dewhiteningMatrix]dwmȥ�׻�����
[nv, wm, dwm] = whitenv(data, E, D);
% WΪ������AΪ��Ͼ���
[icasig, A, W] = fastica (nv);
end

