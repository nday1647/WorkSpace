clc;clear;
% ==读取数据==
% path = 'D:\Myfiles\EEGProject\BCICompetitionIV\BCICIV_2a_gdf\A08T.gdf';

% ==DATA_CHANNEL=h.NS;%通道数==
% DATA_CHANNEL=(1:22);
% ==DATA_LENGTH=h.NRec;%数据长度3000个点==
% Type = [769,770];
% y_tag = [1,-1];
% [x, y, Fs] = get_GDFdata(path, DATA_CHANNEL, Type, y_tag);
% ==将数据转三维格式提供给python版==
% for i =1:length(x)
%     data_x(:,:,i) = x{i};
%     data_y(i) = y{i};
% end
% save A09T data_x data_y 

% ==读入实验数据==
% [signal3d, signal_label, Fs] = loadov('D:\Myfiles\openvibefiles\MI-CSP-r1\signals\GH\GH-171225-online-1.mat'); 
load('D:\Myfiles\EEGProject\Neuroscan\signals\PanLi\PLNSsignal_2_data.mat');
signal3d = data_x(:,1:15,:);
signal_label = data_y;
n_trials = size(signal3d, 3);

%===CAR===(某一采样点全部通道减均值)
channel_num = size(signal3d, 2);
for j = 1 : n_trials
    channel_sum = zeros(size(signal3d, 1), 1);
    for i = 1 : channel_num
        channel_sum = channel_sum + signal3d(:, i, j);
    end
    channel_mean = channel_sum / channel_num;
    for i = 1:channel_num
        signal3d(:, i, j) = signal3d(:, i, j) - channel_mean;
    end
end

% ==randperm滑窗后数据打乱==
randperm_n_trials = randperm(n_trials);
signal3d = signal3d(:,:,randperm_n_trials);
y = signal_label(:,randperm_n_trials);
x = cell(1, n_trials);
for i =1:n_trials
    x{i} = signal3d(:,:,i);
end
% ==内部划分训练集&测试集==
train_size = 90; % 训练样本数目
train_x = x(1:train_size);
train_y = y(1:train_size);
test_size = length(x) - train_size;
test_x = x(train_size+1:end);
test_y = y(train_size+1:end);

% 读取测试集文件
% train_x = x;
% train_y = y;
% % [testx, testy, ~] = loadov('D:\Myfiles\openvibefiles\MI-CSP-r1\signals\GH\GH-171225-acquisition-3.mat'); 
% load('D:\Myfiles\EEGProject\Neuroscan\signals\PanLi\PLNSsignal_2_data.mat');
% testx = data_x(:,1:15,:);
% testy = data_y;
% test_size = size(testx, 3);
% %===CAR===(某一采样点全部通道减均值)
% channel_num = size(testx, 2);
% for j = 1 : test_size
%     channel_sum = zeros(size(testx, 1), 1);
%     for i = 1 : channel_num
%         channel_sum = channel_sum + testx(:, i, j);
%     end
%     channel_mean = channel_sum / channel_num;
%     for i = 1:channel_num
%         testx(:, i, j) = testx(:, i, j) - channel_mean;
%     end
% end
% randperm_n_trials = randperm(test_size);
% testx = testx(:,:,randperm_n_trials);
% test_y = testy(:,randperm_n_trials);
% test_x = cell(1, test_size);
% for i =1:test_size
%     test_x{i} = testx(:,:,i);
% end

Fs = 500;
% =======带通滤波========
filt_n = 4; % 带通滤波器阶数
filter_low = 1; % 带通滤波范围
filter_high = 40;
AfterFilter_train_x = BPfilter(train_x, Fs, filt_n, filter_low, filter_high);
% AfterFilter_train_x = train_x;
% ===调用CSP算法，生成投影矩阵F===
F = csp_train(AfterFilter_train_x, train_y);
%使用投影矩阵F对样本数据x进行空间滤波
AfterCSP_train_x = CSPSpatialFilter(AfterFilter_train_x, F);

% ===训练LDA分类器, 返回投影矩阵和类中心点, 测试返回测试标签y_test===
% [W, centers] = LDA_train1(train_xAfterCSP, train_y);
% [W, centers, y0] = LDA_train(train_xAfterCSP, train_y);
% predict_y = LDA_test(test_xAfterCSP, test_size, W, y0);

% ===训练SVM分类器, 返回投影矩阵和类中心点===
SVMModel = fitcsvm(AfterCSP_train_x, train_y, 'KernelFunction', 'linear');

% ===测试===
AfterFilter_test_x = BPfilter(test_x, Fs, filt_n, filter_low, filter_high); % 带通滤波
% AfterFilter_test_x = test_x;
AfterCSP_test_x = CSPSpatialFilter(AfterFilter_test_x, F); % CSP空间滤波
[predict_y,score] = predict(SVMModel, AfterCSP_test_x); % 分类预测

% ===根据返回测试标签计算分类正确率===
right = sum(predict_y == test_y');
% ===floor向下取整 disp输出 预测准确率===
Accuracy = floor(right/test_size*100);

%==Kappa==
A1 = sum(test_y==1);
A2 = test_size - A1;
B1 = sum(predict_y==1);
B2 = test_size - B1;
Pe = (A1*B1+A2*B2)/test_size.^2;
Kappa = (Accuracy*0.01-Pe)/(1-Pe);
%===
disp(['测试样本个数：' int2str(test_size) '，预测准确率：' int2str(Accuracy) '%']);