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
global filter_a;%�˲�ϵ��a
global filter_b;%�˲�ϵ��b

%��ȡ����
[s,h] = sload('D:\MyFiles\EEGProject\BCICompetitionIV\BCICIV_2a_gdf\A01T.gdf');%,0,'OVERFLOWDETECTION:OFF'
s(isnan(s)==1)=0;
%��������
Fs=h.EVENT.SampleRate;%������
%DATA_CHANNEL=h.NS;%ͨ����
DATA_CHANNEL=22;
%DATA_LENGTH=h.NRec;%���ݳ���3000����
DATA_LENGTH=313;
time_start=1;
time_end=DATA_LENGTH;
data_source=s;
data_size = length(h.Classlabel);
N=3;
POS = h.EVENT.POS;%��ǩλ��
TYP = h.EVENT.TYP;%��ǩ����
DUR = h.EVENT.DUR;%����ʱ��

%����ʱ������
eyes_open_POS = POS(find(TYP == 276));%���ۿ�ʼ��λ��
eyes_open_DUR = DUR(find(TYP == 276));%���۳�����ʱ��
eyes_open = data_source(eyes_open_POS : eyes_open_POS + eyes_open_DUR, :);%����ʱ������
%����ʱ������
eyes_closed_POS = POS(find(TYP == 277));%���ۿ�ʼ��λ��
eyes_closed_DUR = DUR(find(TYP == 277));%���۳�����ʱ��
eyes_closed = data_source(eyes_closed_POS : eyes_closed_POS + eyes_closed_DUR, :);%����ʱ���۵�����
%����ʱ������
eyes_movement_POS = POS(find(TYP == 277));%���ۿ�ʼ��λ��
eyes_movement_DUR = DUR(find(TYP == 277));%���۳�����ʱ��
eyes_movement = data_source(eyes_movement_POS : eyes_movement_POS + eyes_movement_DUR, :);%����ʱ���۵�����

%�������Ե粿��
data_source =data_source(:, 1:22);

%�����������
num_left = sum(TYP == 769);
onset_left_POS = POS(find(TYP == 769));
onset_left_DUR = DUR(find(TYP == 769));
onset_left =cell(1,num_left);%�������ĸ���
y_left=cell(1,num_left);
for i=1 : num_left
    onset_left{i} = data_source(onset_left_POS(i)-1125+1:onset_left_POS(i)-375, :);
    y_left{i} = 1;
end

%�����ҵ�����
num_right = sum(TYP == 770);
onset_right_POS = POS(find(TYP == 770));
onset_right_DUR = DUR(find(TYP == 770));
onset_right = cell(1,num_right);%�������ĸ���
y_right = cell(1,num_right);
for i=1 : num_right
    onset_right{i} = data_source(onset_right_POS(i)-1125+1:onset_right_POS(i)-375, :);
    y_right{i} = -1;
end

% csp_2(onset_left,onset_right);

% data_save('data.mat');

%===============
x = [onset_right onset_left];%1*144cell
x_Train = [x(1:13) x(15:21) x(73:92)];%ɾ����14������ ���Ҹ�20ѵ���� 
x_Test = [x(22:72) x(93:144)];%51�� 52����Լ�
% x_Train = [x(1:13) x(15:51) x(73:122)];%ɾ����14������ ���Ҹ�50ѵ���� 
% x_Test = [x(52:72) x(123:144)];%21�� 22����Լ�
x = [x_Train x_Test];%1*143
y = [y_right y_left];
y_Train = [y(1:13) y(15:21) y(73:92)];
y_Test = [y(22:72) y(93:144)];
% y_Train = [y(1:13) y(15:51) y(73:122)];%ɾ����14������ ���Ҹ�50ѵ���� 
% y_Test = [y(52:72) y(123:144)];%21�� 22����Լ�
y = [y_Train y_Test];


%===============
filt_n =5;%��ͨ�˲�������

%Wn��ֹƵ��(��ͨ�˲���Χ)
%8Hz-30Hz��ͨ�˲���8/(Fs/2)~30/(Fs/2)
Wn=[8 30]/(Fs/2);

%[b,a]=butter(n,Wn)���һ����ͨ�˲����������˲�ϵ��
%nΪ������WnΪ��ֹƵ��(�����Ƶ��Fs�й�)
%b,aΪ�˲���ϵ�� ����filter(b,a,x)����
[filter_b,filter_a]=butter(filt_n,Wn);

right=0;all=0;
init;%��ʼ������
%size(A,1)���ؾ���A����Ӧ������(2-����)
for i=1:size(x,2)
    for j=1:DATA_LENGTH
        data_set(x{i}(j,:));%ÿ��ֻ����һ��
    end
    %==trial����30��ʼԤ��==
    %y_testԤ���ǩ yʵ�ʱ�ǩ
    if data_size>40
        y_test=data_test();
        if y{data_size}==y_test
            right=right+1;
        end
        all=all+1;
        %floor����ȡ�� disp��� Ԥ��׼ȷ��
        %disp([all floor(right/all*100)]);
    end
    
    %===����CSP�㷨������ͶӰ����F===
    csp_make(y(data_size));
end
disp([all floor(right/all*100)]);
data_save('data.mat');