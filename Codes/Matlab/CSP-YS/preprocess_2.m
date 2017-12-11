function [ truerate_ave ] = preprocess_2( data )
%原始数据+带通滤波器+CSP+LDA
%   此处显示详细说明
load(data);
X = X_DATA_POSTPRE;%原始信号样本
Y = Y_DATA_POSTPRE;%样本对应的标签
left = find(Y==0);%左样本的位置
right = find(Y==1);%右样本的位置

% %检查样本中是否有无效值
% bad_sample = 0;
% for i =1: length(X)
%     empty = isnan(X{i});
% %     X{i}(empty) = 0;
%     if sum(sum(empty)) ~= 0 
%         bad_sample = i;
%         bad_ch = find(sum(empty));
%     end
% end
% % if bad_sample ~= 0
% %    X{bad_sample}(:,bad_ch) = [];
% % end

%% 预处理1：带通滤波，频率8-14HZ
X_DATA_POSTPRE1=cell(1,1);
filtwts = firls(2,[0 15 30 40]/128,[0 1 1 0]);%生成滤波器，保留8-14Hz成分的信号
for i=1:length(X)
%     X{1,i} = X{1,i}(1:300,:);
    for j=1:size(X{i},2)
      X_DATA_POSTPRE1{1,i}(:,j)=filtfilt(filtwts,1,X{1,i}(:,j));%对每一列做滤波
    end
end
X = X_DATA_POSTPRE1;

%% 共空间模式 CSP
R=X;%初始化协方差矩阵
for i=1:length(X)%计算每个样本的协方差矩阵
    R{i} = X{i}*X{i}' / trace(X{i}*X{i}');
end

R1 = R(left);%所有左样本协方差矩阵
R2 = R(right);%所有右样本协方差矩阵

% 交叉验证
k=3;%设置交叉验证的折数
indices = crossvalind('kfold',min(length(R1),length(R2)),k);%交叉验证函数，这里的k表示k折，即将训练输入样本分成k组。
truerate = zeros(1,k);%存放所有折的正确率
for Fold = 1:k
    test = (indices == Fold);%逻辑判断，每次循环选取一个fold作为测试集
    train = ~test; %取test的补集作为训练集，即剩下的5个fold。注意这里的test及train均为逻辑值,意味着与后面两句是一起用的
    
    % 样本分类
    x_train_L = R1(train');  %左训练集
    x_train_R = R2(train');%右训练集
%     x_test_L = R1(test'); %左测试集
%     x_test_R = R2(test');%右测试集
    
%% 计算平均协方差矩阵
R1_ave = 0; R2_ave = 0;
for i=1:length(x_train_L)
    R1_ave = R1_ave + x_train_L{i};
end
for i=1:length(x_train_R)
    R2_ave = R2_ave + x_train_R{i};
end
R1_ave = R1_ave/length(x_train_L);%左样本平均协方差矩阵
R2_ave = R2_ave/length(x_train_R);%右样本平均协方差矩阵

R = R1_ave +R2_ave;%混合协方差矩阵
[U,E] = eig(R);%主分量分解：U为R的特征向量；E为R的特征值的对角矩阵
P = E^(-1/2) * U';%定义白化变换矩阵
S1 = P * R1_ave * P';%白化变换R1_ave
S2 = P * R2_ave * P';%白化变换R2_ave

[U1,E1] = eig(S1);%主分量分解S1
[U2,E2] = eig(S2);%主分量分解S2

m=2;%确定选取特征数量，即m组滤波器
%取E1中最大m个特征值对应的特征向量V1构建类别1空间滤波器SF1：
[Y1,I1] = sort(diag(E1),'descend');
V1 = U1(:,I1(1:m));
SF1 = V1' *P;
%取E2中最大m个特征值对应的特征向量V2构建类别2空间滤波器SF2：
[Y2,I2] = sort(diag(E2),'descend');
V2 = U2(:,I2(1:m));
SF2 = V2' *P;

%原始信号样本分别滤波得到两个类别信号
Z1 = X;
for i=1:length(X)
    Z1{i} = SF1 * X{i};
end
Z2 = X;
for i=1:length(X)
    Z2{i} = SF2 * X{i};
end
%% 特征提取
f1 = zeros(1,length(Z1));%类别1的特征
f2 = zeros(1,length(Z2));%类别2的特征
for i=1:length(Z1)
    f1(i) = log(var(Z1{i}) / (var(Z1{i})+var(Z2{i})));%log为了f1和f2更接近正态分布
    f2(i) = log(var(Z2{i}) / (var(Z1{i})+var(Z2{i})));
end

feature = [f1;f2];%二维的特征点
f_L = feature(:,left);%左特征点
f_R = feature(:,right);%右特征点

Train_L = f_L(:, train');%取前T_l个左特征点作为训练集
Train_R = f_R(:, train');%取前T_l个右特征点作为训练集
Test_L = f_L(:, test');%取后T_l个左特征点作为训练集
Test_R = f_R(:,test');%取后T_l个右特征点作为训练集

%% 线性判别分析 LDA
mean_L = mean(Train_L,2);%第一类的中心
mean_R = mean(Train_R,2);%第二类的中心

s1 = (Train_L - repmat(mean_L,1,length(Train_L))) * (Train_L - repmat(mean_L,1,length(Train_L)))' ;%第一类的类内距
s2 = (Train_R - repmat(mean_R,1,length(Train_R))) * (Train_R - repmat(mean_R,1,length(Train_R)))' ;%第二类的类内距
Sw = s1 +s2;%
w = inv(Sw) * (mean_L - mean_R);%w=Sw^(-1) *(mean1 - mean2)

t_L = mean_L' * w;%训练集的类1中心的映射点
t_R = mean_R' * w;%训练集的类2中心的映射点
p_L = (Test_L' * w - t_L) < (Test_L' * w - t_R);%左测试集的映射点到训练集的类1中心的映射点的距离<其到训练集的类2中心的映射点的距离，说明预测结果为类1（左）。
p_R = abs(Test_R' * w - t_L) > (Test_R' * w - t_R);%右测试集的映射点到训练集的类1中心的映射点的距离>其到训练集的类2中心的映射点的距离，说明预测结果为类2（右）。

truerate(Fold) = (sum(p_L==1) + sum(p_R==1)) / (length(p_L) + length(p_R));
end
truerate_ave = sum(truerate)/length(truerate);
return

