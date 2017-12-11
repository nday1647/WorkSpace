function F = csp_train(AfterFilter_x, y, train_size)
% 输入参数为样本数据AfterFilter_x 标签y 训练数目train_size
% AfterFilter_x为cell类型 每个cell代表一个trial 对应一个标签y
% 每个cell结构为T×N, T采样点数, N通道数
% 返回投影矩阵F 新特征f1 f2(DataNum*FeatureNum)

channel_num=size(AfterFilter_x{1},2);
N=3;% 提取特征对数
for i = 1:train_size
    % R=X'*X/tr(X'*X) 协方差矩阵(对称矩阵)
    R{i}=AfterFilter_x{i}'*AfterFilter_x{i}/trace(AfterFilter_x{i}'*AfterFilter_x{i});
%     R{i}=AfterFilter_x{i}'*AfterFilter_x{i};
end
% 初始化R1，R2
R1=zeros(channel_num);
R2=zeros(channel_num);
countL=0;countR=0;
% 按数据标签分类，分别赋给R1,R2, 类1 y=1,类2 y=-1
for i=1:train_size
    if y{i} == 1
        R1 = R1+R{i};% 求和
        countL = countL+1;
    else
        R2 = R2+R{i};
        countR = countR+1;
    end
end
% 协方差矩阵的归一化
% R1=R1/trace(R1);
% R2=R2/trace(R2);
R1=R1/countL;
R2=R2/countR;
R3=R1+R2;
% close all%关闭所有figure窗口
% figure()创建一个窗口 surf(Z)绘三维曲面图
% figure();surf(R1);figure();surf(R2);figure();surf(R3);
% [V,D]=eig(A)返回矩阵A的全部特征值构成的对角阵D和特征向量V
[U0,Sigma]=eig(R3);
% 构造白化变换矩阵P
P=Sigma^(-0.5)*U0';
% 利用P对R1进行变换
YL=P*R1*P';
YR=P*R2*P';
% 特征值分解(同时对角化）
[UL,SigmaL]=eig(YL,YR);
% [UL,SigmaL]=eig(YL);
% [UR,SigmaR]=eig(YR);
% x=diag(v,k)以向量v的元素作为矩阵X的第k条对角线元素
% 当k=0时，v为X的主对角线
% 当k>0时，v为上方第k条对角线
% 当k<0时，v为下方第k条对角线
% descend降序 [B,I]=sort(A)默认对列进行排序返回排序后矩阵B
% I为返回的排序后元素在原数组中的行位置或列位置 22x1
[~,I]=sort(diag(SigmaL), 'descend');
% [~,IR]=sort(diag(SigmaR), 'descend');
% 取降序排序后特征向量UL的列向量的前N和后N个（最大N个&最小N个）
F=UL(:,I([1:N,channel_num-N+1:channel_num]))'*P;
% FL=P'*UL(:,I(1:N));
% FR=P'*UL(:,I(DATA_CHANNEL-N+1:DATA_CHANNEL));
% 原样本数据按列投影并分类(变换->乘方->求和->对数变换->转置=>新样本矩阵
% f1=[];f2=[];
% for i=1:train_size
%     Z = F*AfterFilter_x{i}';% 脑电信号投影后得到z 6*750
%     feature = log(var(Z,0,2)/sum(var(Z,0,2)))';% 按列求方差
%     if y{i}==1
%         f1 = [f1;feature];
%     else
%         f2 = [f2;feature];
%     end
% end
return