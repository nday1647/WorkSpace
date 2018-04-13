clc;clear;
global Fs;%采样频率
global N;%提取特征对数
global DATA_CHANNEL;%通道数
global DATA_LENGTH;%样本长度
global time_start;%开始时间
global time_end;%结束时间
global data_source;%存放原始数据
global data_x;%存放滤波后的数据
global data_y;%存放数据对应标签
global R;%样本的相关系数
global data_size;%样本数量
global data_index;%数据池指针
global F;%CSP所寻找到的投影方向
global w;%LDA权值
global b;%LDA偏移
global filter_low;%带通滤波低频范围
global filter_high;%带通滤波高频范围
global train_size;%训练样本数目
global filt_n;%带通滤波器阶数

%读取数据
EEG = pop_loadBCI2000('data.dat',  {'StimulusCode', 'StimulusBegin'});

%属性设置
Fs=EEG.srate;%采样率
%DATA_CHANNEL=h.NS;%通道数
DATA_CHANNEL=8;
%DATA_LENGTH=h.NRec;%数据长度3000个点
DATA_LENGTH=400;%1个trial的长度
time_start=1;
time_end=DATA_LENGTH;
data_source=EEG.data';
data_label=EEG.event;
train_size = 10;
data_size = length(EEG.event);
N=3;%提取特征对数
duration=400;%每次的窗时间

% %睁眼时的数据
% [num_eyes_open,eyes_open,y_eyes_open] = get_GDFdata(data_source,h,276,2);
% %闭眼时的数据
% [num_eyes_closed,eyes_closed,y_eyes_closed] = get_GDFdata(data_source,h,277,3);
% %动眼时的数据
% [num_eyes_movement,eyes_movement,y_eyes_movement] = get_GDFdata(data_source,h,1072,4);

%样本数据的脑电部分
% data_source =data_source(:, 1:22);

[num,onset,y] =  get_DATdata(data_source,duration,data_label);

x=onset;
%===============
% x = [onset_right onset_left];%1*144cell
% x_Train = [x(1:10) x(15:21) x(73:92)];%删除第14组数据(A01T NaN值) 左右各20训练集 
% x_Test = [x(22:72) x(93:144)];%51右 52左测试集
% % x_Train = [x(1:13) x(15:51) x(73:122)];%删除第14组数据 左右各50训练集 
% % x_Test = [x(52:72) x(123:144)];%21右 22左测试集
% x = [x_Train x_Test];%1*143
% y_Train = [y(1:13) y(15:21) y(73:92)];
% y_Test = [y(22:72) y(93:144)];
% % y_Train = [y(1:13) y(15:51) y(73:122)];%删除第14组数据 左右各50训练集 
% % y_Test = [y(52:72) y(123:144)];%21右 22左测试集
% y = [y_Train y_Test];
%===============
filt_n =5;%带通滤波器阶数
filter_low = 8;%带通滤波范围
filter_high = 30;

right=0;all=0;
init;%初始化函数
%size(A,1)返回矩阵A所对应的行数(2->列数)
for i=1:size(x,2)
    for j=1:DATA_LENGTH
        data_set(x{i}(j,:));%每次只输入一行
    end
    %==trial超过train_size开始预测==
    %y_test预测标签 y实际标签
    if data_size>train_size
        y_test=data_test();
        if y{data_size}==y_test
            right=right+1;
        end
        all=all+1;
    end
    
    %===调用CSP算法，生成投影矩阵F===
    csp_make(y(data_size));
end
%floor向下取整 disp输出 预测准确率
Accuracy = floor(right/all*100);
disp(['预测准确率：' int2str(Accuracy) '%']);
% data_save('data.mat');