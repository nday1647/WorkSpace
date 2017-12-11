% ����whitenv����
clc
clear
close all
 
% ����matlab�Դ�������
load cities
stdr = std(ratings);%ÿһ�еı�׼��
sr = ratings./repmat(stdr,329,1);
 
figure
boxplot(sr,'orientation','horizontal','labels',categories)
 
% ����
firstEig = 1;
lastEig = 8;
s_interactive = 'off';
% [E, D] = pcamat(vectors, firstEig, lastEig, s_interactive, s_verbose)
%(����ֵ�ֽ�+ѡ��ǰ�����ɷ�)
% ��������������ʽ���������ݵ�PCA���󡣷���ѡ����ӿռ��������������E�ͶԽǻ�����ֵ����D��
% ��ά��firstEig��lastEig�������ƣ���Ҳ��������s_interactiveΪ'on'��'gui'���������㡣
% ����˵����
% vectors     ���ݣ�����������ʾ��
% firstEig    ������������ɷֵĴ���Ĭ��Ϊ1.
% lastEig     ��������С���ɷֵĴ���Ĭ�ϵ����������ĸ�����
% interactive ����ʽָ������ֵ���������Ϊ'on'��'gui'����ô����
%             'firstEig'��'lastEig'�������ԣ�����������Ҫ���롣�������
%             Ϊ'gui'����ô��fasticag��ͼ���û��ӿڽ���ʹ�á�Ĭ��Ϊ'off'��
% verbose     �Ƿ���ʾ��ϸ���裬Ĭ��Ϊ'on'�� 
[E, D] = pcamat(sr', firstEig, lastEig, s_interactive);

% [newVectors, whiteningMatrix, dewhiteningMatrix] = whitenv(vectors, E, D, s_verbose)
% �׻����������ݲ���ά�����ذ׻������ݡ��׻��任�����ȥ�׻�����
% ����˵����
% vectors     ���ݣ�����������ʾ��
% E           �ɺ���pcamat�õ���������������
% D           �ɺ���pcamat�õ��ĶԽǻ�����ֵ����
% verbose     �Ƿ���ʾ��ϸ���裬Ĭ��Ϊ'on'��
[nv, wm, dwm] = whitenv(sr', E, D);

figure
boxplot(nv','orientation','horizontal')