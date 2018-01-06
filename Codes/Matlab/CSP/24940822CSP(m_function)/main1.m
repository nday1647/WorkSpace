clc;clear;
%读取数据
path = 'D:\Myfiles\EEGProject\BCICompetitionIV\BCICIV_2a_gdf\A03T.gdf';

%DATA_CHANNEL=h.NS;%通道数
DATA_CHANNEL=(1:22);
%DATA_LENGTH=h.NRec;%数据长度3000个点
Type = [769,770];
y_tag = [1,-1];
[x, y, Fs] = get_GDFdata(path, DATA_CHANNEL, Type, y_tag);
DATA_LENGTH = length(x{1});%1个trial的长度
%size(A,1)返回矩阵A所对应的行数(2->列数)
train_size = 60;%训练样本数目

%===============
filt_n =4;%带通滤波器阶数
filter_low = 4;%带通滤波范围
filter_high = 40;
AfterFilter_x = BPfilter(x, Fs, filt_n, filter_low, filter_high);

%===调用CSP算法，生成投影矩阵F===
F = csp_train(AfterFilter_x, y, train_size);
%使用投影矩阵F对样本数据x进行空间滤波
xAfterCSP = CSPSpatialFilter(AfterFilter_x, F);
yArray = cell2mat(y)';%标签y转换为矩阵类型
xy = [xAfterCSP yArray];
train_xAfterCSP = xAfterCSP(1:train_size,:);train_y = yArray(1:train_size);
test_size = length(AfterFilter_x) - train_size;
test_xAfterCSP = xAfterCSP(train_size+1:end,:);test_y = yArray(train_size+1:end);

%===训练LDA分类器, 返回投影矩阵和类中心点, 测试返回测试标签y_test===
% [W, centers] = LDA_train1(train_xAfterCSP, train_y);
% [W, centers, y0] = LDA_train(train_xAfterCSP, train_y);
% y_test = LDA_test(test_xAfterCSP, test_size, W, y0);

%===训练SVM分类器, 返回投影矩阵和类中心点===
SVMModel = fitcsvm(train_xAfterCSP, train_y,'KernelFunction','linear');
[predict_y,score] = predict(SVMModel,test_xAfterCSP);

%===根据返回测试标签计算分类正确率
right = sum(predict_y == test_y);
%floor向下取整 disp输出 预测准确率
Accuracy = floor(right/test_size*100);

%==Kappa==
A1 = sum(test_y==1);A2 = test_size - A1;
B1 = sum(predict_y==1);B2 = test_size - B1;
Pe = (A1*B1+A2*B2)/test_size.^2;
Kappa = (Accuracy*0.01-Pe)/(1-Pe);
%===

disp(['测试样本个数：' int2str(test_size) '，预测准确率：' int2str(Accuracy) '%']);