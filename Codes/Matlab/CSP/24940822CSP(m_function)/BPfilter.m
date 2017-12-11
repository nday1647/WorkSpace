function AfterFilter_x = BPfilter(data_source, Fs, filt_n, filter_low, filter_high)%��������

%�ź��˲�
%Wn��ֹƵ��(��ͨ�˲���Χ)
%8Hz-30Hz��ͨ�˲���8/(Fs/2)~30/(Fs/2)
Wn=[filter_low filter_high]/(Fs/2);
channelNum = size(data_source{1},2);
%[b,a]=butter(n,Wn)���һ����ͨ�˲����������˲�ϵ��
%nΪ������WnΪ��ֹƵ��(�����Ƶ��Fs�й�)
%b,aΪ�˲���ϵ�� ����filter(b,a,x)����
[filter_b,filter_a]=butter(filt_n,Wn);
AfterFilter_x = data_source;
for data_size = 1:length(data_source)
    for i=1:channelNum
        %filter(b,a,x)��b,a�˲���ϵ��
        AfterFilter_x{data_size}(:,i)=filter(filter_b,filter_a,data_source{data_size}(:,i));
    end
end
return