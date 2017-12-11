%main.m是一个过程不是函数，模拟混编时C++所干的事情
clc;clear;
global Fs;%采样频率
global N;%提取特征对数
global DATA_CHANNEL;%通道数
global DATA_LENGTH;%样本长度==>每次读取的数据长度
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
global filter_a;%滤波系数a
global filter_b;%滤波系数b

%属性设置
Fs=1000;
N=3;
DATA_CHANNEL=21;
DATA_LENGTH=3*Fs;
time_start=1;
time_end=DATA_LENGTH;
filt_n =5;%带通滤波器阶数

%Wn截止频率(带通滤波范围)
%8Hz-30Hz带通滤波：8/(Fs/2)~30/(Fs/2)
Wn=[8 30]/(Fs/2);

%[b,a]=butter(n,Wn)设计一个带通滤波器，生成滤波系数
%n为阶数，Wn为截止频率(与采样频率Fs有关)
%b,a为滤波器系数 用于filter(b,a,x)函数
[filter_b,filter_a]=butter(filt_n,Wn);



right=0;all=0;
init;%初始化函数
%load('..\\dataset\\data_7.mat');
[s,h]=sload('D:\MyFiles\EEGProject\BCICompetitionIV\BCICIV_2a_gdf\A01T.gdf');
x=cell(1,1);
x{1}=s;
%size(A,1)返回矩阵A所对应的行数(2-列数)
for i=1:size(x,1)
    for j=1:DATA_LENGTH
        data_set(x{i}(j,:));%每次只输入一行
    end
    %==trial超过30开始预测==
    %y_test预测标签 y实际标签
    if data_size>30
        y_test=data_test();
        if y(data_size)==y_test
            right=right+1;
        end
        all=all+1;
        %floor向下取整 all检测矩阵是否全为非零元素 disp输出 预测准确率
        disp([all floor(right/all*100)]);
    end
    %===调用CSP算法，生成投影矩阵F===
    csp_make(y(data_size));
end
data_save('data.mat');