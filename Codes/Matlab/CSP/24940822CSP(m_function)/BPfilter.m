function AfterFilter_x = BPfilter(data_source, Fs, filt_n, filter_low, filter_high)
% ==�ź��˲�==
% ==data_source:trial size cell ��(samples��channel) || samples��channel

% ==Wn��ֹƵ��(��ͨ�˲���Χ)==
% ==8Hz-30Hz��ͨ�˲���8/(Fs/2)~30/(Fs/2)==
% ==[b,a]=butter(n,Wn)���һ����ͨ�˲����������˲�ϵ��==
% ==nΪ������WnΪ��ֹƵ��(�����Ƶ��Fs�й�)==
% ==b,aΪ�˲���ϵ�� ����filter(b,a,x)����==
Wn=[filter_low filter_high]/(Fs/2);
[filter_b,filter_a]=butter(filt_n, Wn, 'bandpass');   
AfterFilter_x = data_source;
% ==data_sourceΪ���trialʱ==
if iscell(data_source)
    channelNum = size(data_source{1},2);
    for data_size = 1:length(data_source)
        for i=1:channelNum
            %filter(b,a,x)��b,a�˲���ϵ��
            AfterFilter_x{data_size}(:,i)=filter(filter_b,filter_a,data_source{data_size}(:,i));
        end
    end
% ==data_sourceΪ����trialʱ==
else
    channelNum = size(data_source,2);
    for i=1:channelNum
        %filter(b,a,x)��b,a�˲���ϵ��
        AfterFilter_x(:,i)=filter(filter_b,filter_a,data_source(:,i));
    end
end
return