function AfterFilter_x = BPfilter(data_source, Fs, filt_n, filter_low, filter_high)%输入数据

%信号滤波
%Wn截止频率(带通滤波范围)
%8Hz-30Hz带通滤波：8/(Fs/2)~30/(Fs/2)
Wn=[filter_low filter_high]/(Fs/2);
channelNum = size(data_source{1},2);
%[b,a]=butter(n,Wn)设计一个带通滤波器，生成滤波系数
%n为阶数，Wn为截止频率(与采样频率Fs有关)
%b,a为滤波器系数 用于filter(b,a,x)函数
[filter_b,filter_a]=butter(filt_n,Wn);
AfterFilter_x = data_source;
for data_size = 1:length(data_source)
    for i=1:channelNum
        %filter(b,a,x)，b,a滤波器系数
        AfterFilter_x{data_size}(:,i)=filter(filter_b,filter_a,data_source{data_size}(:,i));
    end
end
return