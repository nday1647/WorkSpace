clc;clear;
global Fs;%����Ƶ��
global N;%��ȡ��������
global DATA_CHANNEL;%ͨ����
global DATA_LENGTH;%��������
global time_start;%��ʼʱ��
global time_end;%����ʱ��
global data_source;%���ԭʼ����
global data_x;%����˲��������
global data_y;%������ݶ�Ӧ��ǩ
global R;%���������ϵ��
global data_size;%��������
global data_index;%���ݳ�ָ��
global F;%CSP��Ѱ�ҵ���ͶӰ����
global w;%LDAȨֵ
global b;%LDAƫ��
global filter_low;%��ͨ�˲���Ƶ��Χ
global filter_high;%��ͨ�˲���Ƶ��Χ
global train_size;%ѵ��������Ŀ
global filt_n;%��ͨ�˲�������

%��ȡ����
EEG = pop_loadBCI2000('data.dat',  {'StimulusCode', 'StimulusBegin'});

%��������
Fs=EEG.srate;%������
%DATA_CHANNEL=h.NS;%ͨ����
DATA_CHANNEL=8;
%DATA_LENGTH=h.NRec;%���ݳ���3000����
DATA_LENGTH=400;%1��trial�ĳ���
time_start=1;
time_end=DATA_LENGTH;
data_source=EEG.data';
data_label=EEG.event;
train_size = 10;
data_size = length(EEG.event);
N=3;%��ȡ��������
duration=400;%ÿ�εĴ�ʱ��

% %����ʱ������
% [num_eyes_open,eyes_open,y_eyes_open] = get_GDFdata(data_source,h,276,2);
% %����ʱ������
% [num_eyes_closed,eyes_closed,y_eyes_closed] = get_GDFdata(data_source,h,277,3);
% %����ʱ������
% [num_eyes_movement,eyes_movement,y_eyes_movement] = get_GDFdata(data_source,h,1072,4);

%�������ݵ��Ե粿��
% data_source =data_source(:, 1:22);

[num,onset,y] =  get_DATdata(data_source,duration,data_label);

x=onset;
%===============
% x = [onset_right onset_left];%1*144cell
% x_Train = [x(1:10) x(15:21) x(73:92)];%ɾ����14������(A01T NaNֵ) ���Ҹ�20ѵ���� 
% x_Test = [x(22:72) x(93:144)];%51�� 52����Լ�
% % x_Train = [x(1:13) x(15:51) x(73:122)];%ɾ����14������ ���Ҹ�50ѵ���� 
% % x_Test = [x(52:72) x(123:144)];%21�� 22����Լ�
% x = [x_Train x_Test];%1*143
% y_Train = [y(1:13) y(15:21) y(73:92)];
% y_Test = [y(22:72) y(93:144)];
% % y_Train = [y(1:13) y(15:51) y(73:122)];%ɾ����14������ ���Ҹ�50ѵ���� 
% % y_Test = [y(52:72) y(123:144)];%21�� 22����Լ�
% y = [y_Train y_Test];
%===============
filt_n =5;%��ͨ�˲�������
filter_low = 8;%��ͨ�˲���Χ
filter_high = 30;

right=0;all=0;
init;%��ʼ������
%size(A,1)���ؾ���A����Ӧ������(2->����)
for i=1:size(x,2)
    for j=1:DATA_LENGTH
        data_set(x{i}(j,:));%ÿ��ֻ����һ��
    end
    %==trial����train_size��ʼԤ��==
    %y_testԤ���ǩ yʵ�ʱ�ǩ
    if data_size>train_size
        y_test=data_test();
        if y{data_size}==y_test
            right=right+1;
        end
        all=all+1;
    end
    
    %===����CSP�㷨������ͶӰ����F===
    csp_make(y(data_size));
end
%floor����ȡ�� disp��� Ԥ��׼ȷ��
Accuracy = floor(right/all*100);
disp(['Ԥ��׼ȷ�ʣ�' int2str(Accuracy) '%']);
% data_save('data.mat');