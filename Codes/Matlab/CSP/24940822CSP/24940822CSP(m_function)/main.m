%main.m��һ�����̲��Ǻ�����ģ����ʱC++���ɵ�����
clc;clear;
global Fs;%����Ƶ��
global N;%��ȡ��������
global DATA_CHANNEL;%ͨ����
global DATA_LENGTH;%��������==>ÿ�ζ�ȡ�����ݳ���
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

%��������
Fs=1000;
N=3;
DATA_CHANNEL=21;
DATA_LENGTH=3*Fs;
time_start=1;
time_end=DATA_LENGTH;
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
%load('..\\dataset\\data_7.mat');
[s,h]=sload('D:\MyFiles\EEGProject\BCICompetitionIV\BCICIV_2a_gdf\A01T.gdf');
x=cell(1,1);
x{1}=s;
%size(A,1)���ؾ���A����Ӧ������(2-����)
for i=1:size(x,1)
    for j=1:DATA_LENGTH
        data_set(x{i}(j,:));%ÿ��ֻ����һ��
    end
    %==trial����30��ʼԤ��==
    %y_testԤ���ǩ yʵ�ʱ�ǩ
    if data_size>30
        y_test=data_test();
        if y(data_size)==y_test
            right=right+1;
        end
        all=all+1;
        %floor����ȡ�� all�������Ƿ�ȫΪ����Ԫ�� disp��� Ԥ��׼ȷ��
        disp([all floor(right/all*100)]);
    end
    %===����CSP�㷨������ͶӰ����F===
    csp_make(y(data_size));
end
data_save('data.mat');