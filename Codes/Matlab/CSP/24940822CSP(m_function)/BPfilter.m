function AfterFilter_x = BPfilter(data_source, Fs, filt_n, filter_low, filter_high)
% ==信号滤波==
% ==data_source:trial size cell ×(samples×channel) || samples×channel

% ==Wn截止频率(带通滤波范围)==
% ==8Hz-30Hz带通滤波：8/(Fs/2)~30/(Fs/2)==
% ==[b,a]=butter(n,Wn)设计一个带通滤波器，生成滤波系数==
% ==n为阶数，Wn为截止频率(与采样频率Fs有关)==
% ==b,a为滤波器系数 用于filter(b,a,x)函数==
Wn=[filter_low filter_high]/(Fs/2);
[filter_b,filter_a]=butter(filt_n, Wn, 'bandpass');   
AfterFilter_x = data_source;
% ==data_source为多个trial时==
if iscell(data_source)
    channelNum = size(data_source{1},2);
    for data_size = 1:length(data_source)
        for i=1:channelNum
            %filter(b,a,x)，b,a滤波器系数
            AfterFilter_x{data_size}(:,i)=filter(filter_b,filter_a,data_source{data_size}(:,i));
        end
    end
% ==data_source为单个trial时==
else
    channelNum = size(data_source,2);
    for i=1:channelNum
        %filter(b,a,x)，b,a滤波器系数
        AfterFilter_x(:,i)=filter(filter_b,filter_a,data_source(:,i));
    end
end
return