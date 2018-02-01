clc;clear all;close all;
%% 读取并运行配置文件
SettingPathName = 'D:\Myfiles\WorkSpace\Codes\Matlab\EEGspectrum';%配置文件路径
addpath(SettingPathName);   
run configuration;
%% 加载神经数据
load GH-171225-acquisition-2-samples.mat;
% load competitionA03T_data.mat
total_channel=8;
NeuroDataSelect=samples(:,1:total_channel)';
settings.fs = 500;%采样率 2000
settings.SettingPathName = SettingPathName;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(4,1,1);
plot(NeuroDataSelect(1,1:1000),'r');
title("Original");

%% CAR：common average referencing filter 共参考均值滤波
sum=0;
for i=1:total_channel
    sum=sum+NeuroDataSelect(i,:);
end
channel_mean=sum./total_channel;
for i=1:total_channel
    NeuroDataSelect(i,:)=NeuroDataSelect(i,:)-channel_mean;
end
% save([SettingPathName '\NeuroDataSelect'],'NeuroDataSelect','settings');%保存实际神经数据

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hold on;
subplot(3,1,2);
plot(NeuroDataSelect(1,1:1000),'b');
title("After CAR");

%% Savitzky-Golay 滤波器
% for i=1:4
%     NeuroDataSelect(i,:)=sgolayfilt(NeuroDataSelect(i,:),3,11);
% end
% save([SettingPathName '\NeuroDataSelect'],'NeuroDataSelect','settings');%保存实际神经数据
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hold on;
% subplot(4,1,2);
% plot(NeuroDataSelect(4,442000:477000),'b');
% title("After Filter");

%% 获取功率谱
NeuroDataPowerSpectrum = PowerSpectrum(NeuroDataSelect,settings);%频率在0.3—200Hz部分的信号功率谱
save([SettingPathName '\NeuroDataPowerSpectrum'],'NeuroDataPowerSpectrum','settings');%保存

%% 获取打标值
label=samples(:,9);
label=double(label);
save([SettingPathName '\label'],'label','settings');%保存
