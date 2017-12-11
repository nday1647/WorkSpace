%% ʵ�ֹ��ܣ���ȡ���ݣ���ȡ��������Ӧ��ǩ

clc;clear;
%% ���ݶ���
run('E:\offline analysis\biosig4octmat-3.3.0 (64bit)\biosig_installer.m');
%��ȡ����
% for d = 1:9
%     str_read = ['A0' int2str(int8(d)) 'T.gdf'];
str_read = 'motor-imagery-csp-4-online-[2017.10.26-16.26.25].gdf';
    [s,h] = sload(str_read);%,0,'OVERFLOWDETECTION:OFF'

%��������
Fs=h.EVENT.SampleRate;%������
DATA_CHANNEL=h.NS;%��ͨ����
DATA_LENGTH=h.NRec;%���ݳ���
data_source=s;%ԭʼ����
data_size = length(h.Classlabel == 32);%��������
Sample_L = length(h.Classlabel == 1);%����������
Sample_R = length(h.Classlabel == 2);%����������
POS = h.EVENT.POS;%��ǩλ��
TYP = h.EVENT.TYP;%��ǩ����

% %�Ե粿��ԭʼ����
DATA_CHANNEL_EEG = DATA_CHANNEL;%�Ե�ͨ����
% 
%% ��ȡ����
%�����������
num_left = sum(TYP == 769);%�������ĸ���
onset_left_POS = POS(TYP == 769);%�������Ŀ�ʼλ��
% offset_left_POS = POS(TYP == 800);%�������Ľ���λ�ã��Ӽ�ͷ���ֵ�ʮ����ʧ��
onset_left_DUR = 2500;%�������ĳ���ʱ��:2500���㣬Լ5s
onset_left =cell(1,num_left);
for i=1 : num_left
    onset_left{i} = data_source(onset_left_POS(i):onset_left_POS(i)+onset_left_DUR-1, :);
end

%�����ҵ�����
num_right = sum(TYP == 770);
onset_right_POS = POS(TYP == 770);
% offset_left_POS = POS(TYP == 800);%�������Ľ���λ�ã��Ӽ�ͷ���ֵ�ʮ����ʧ��
onset_right_DUR = 2500;
onset_right =cell(1,num_right);%�������ĸ���
for i=1 : num_right
    onset_right{i} = data_source(onset_right_POS(i):onset_right_POS(i)+onset_right_DUR-1, :);
end

X = {onset_left{1:end},onset_right{1:end}};%1��num_leftΪ��������num_left+1��endλ������
y = [zeros(1,length(onset_left)), ones(1,length(onset_right))];%���ǩ0���ұ�ǩ1

X_DATA_POSTPRE = X;
Y_DATA_POSTPRE = y; %������Ӧ�ı�ǩ

str_save = 'ZJJ_3_online.mat';
save(str_save);
% end