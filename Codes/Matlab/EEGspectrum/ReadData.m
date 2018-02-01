clc;clear all;close all;
%% ��ȡ�����������ļ�
SettingPathName = 'D:\Myfiles\WorkSpace\Codes\Matlab\EEGspectrum';%�����ļ�·��
addpath(SettingPathName);   
run configuration;
%% ����������
load GH-171225-acquisition-2-samples.mat;
% load competitionA03T_data.mat
total_channel=8;
NeuroDataSelect=samples(:,1:total_channel)';
settings.fs = 500;%������ 2000
settings.SettingPathName = SettingPathName;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(4,1,1);
plot(NeuroDataSelect(1,1:1000),'r');
title("Original");

%% CAR��common average referencing filter ���ο���ֵ�˲�
sum=0;
for i=1:total_channel
    sum=sum+NeuroDataSelect(i,:);
end
channel_mean=sum./total_channel;
for i=1:total_channel
    NeuroDataSelect(i,:)=NeuroDataSelect(i,:)-channel_mean;
end
% save([SettingPathName '\NeuroDataSelect'],'NeuroDataSelect','settings');%����ʵ��������

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hold on;
subplot(3,1,2);
plot(NeuroDataSelect(1,1:1000),'b');
title("After CAR");

%% Savitzky-Golay �˲���
% for i=1:4
%     NeuroDataSelect(i,:)=sgolayfilt(NeuroDataSelect(i,:),3,11);
% end
% save([SettingPathName '\NeuroDataSelect'],'NeuroDataSelect','settings');%����ʵ��������
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hold on;
% subplot(4,1,2);
% plot(NeuroDataSelect(4,442000:477000),'b');
% title("After Filter");

%% ��ȡ������
NeuroDataPowerSpectrum = PowerSpectrum(NeuroDataSelect,settings);%Ƶ����0.3��200Hz���ֵ��źŹ�����
save([SettingPathName '\NeuroDataPowerSpectrum'],'NeuroDataPowerSpectrum','settings');%����

%% ��ȡ���ֵ
label=samples(:,9);
label=double(label);
save([SettingPathName '\label'],'label','settings');%����
