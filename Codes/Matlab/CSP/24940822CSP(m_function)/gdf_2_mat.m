%% 实现功能：读取数据，提取样本及对应标签

clc;clear;
%% 数据读入
run('E:\offline analysis\biosig4octmat-3.3.0 (64bit)\biosig_installer.m');
%读取数据
% for d = 1:9
%     str_read = ['A0' int2str(int8(d)) 'T.gdf'];
str_read = 'motor-imagery-csp-4-online-[2017.10.26-16.26.25].gdf';
    [s,h] = sload(str_read);%,0,'OVERFLOWDETECTION:OFF'

%属性设置
Fs=h.EVENT.SampleRate;%采样率
DATA_CHANNEL=h.NS;%总通道数
DATA_LENGTH=h.NRec;%数据长度
data_source=s;%原始数据
data_size = length(h.Classlabel == 32);%样本个数
Sample_L = length(h.Classlabel == 1);%左样本个数
Sample_R = length(h.Classlabel == 2);%右样本个数
POS = h.EVENT.POS;%标签位置
TYP = h.EVENT.TYP;%标签类型

% %脑电部分原始数据
DATA_CHANNEL_EEG = DATA_CHANNEL;%脑电通道数
% 
%% 获取样本
%所有左的样本
num_left = sum(TYP == 769);%左样本的个数
onset_left_POS = POS(TYP == 769);%左样本的开始位置
% offset_left_POS = POS(TYP == 800);%左样本的结束位置（从箭头出现到十字消失）
onset_left_DUR = 2500;%左样本的持续时间:2500个点，约5s
onset_left =cell(1,num_left);
for i=1 : num_left
    onset_left{i} = data_source(onset_left_POS(i):onset_left_POS(i)+onset_left_DUR-1, :);
end

%所有右的样本
num_right = sum(TYP == 770);
onset_right_POS = POS(TYP == 770);
% offset_left_POS = POS(TYP == 800);%左样本的结束位置（从箭头出现到十字消失）
onset_right_DUR = 2500;
onset_right =cell(1,num_right);%右样本的个数
for i=1 : num_right
    onset_right{i} = data_source(onset_right_POS(i):onset_right_POS(i)+onset_right_DUR-1, :);
end

X = {onset_left{1:end},onset_right{1:end}};%1到num_left为左样本，num_left+1到end位右样本
y = [zeros(1,length(onset_left)), ones(1,length(onset_right))];%左标签0和右标签1

X_DATA_POSTPRE = X;
Y_DATA_POSTPRE = y; %样本对应的标签

str_save = 'ZJJ_3_online.mat';
save(str_save);
% end