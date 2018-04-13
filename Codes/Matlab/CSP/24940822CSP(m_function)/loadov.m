function [signal3d, signal_label, Fs] = loadov(path)
% 输出格式
% signal3d : samples×channals×trials
% signal_label : trials
load(path);
Fs = samplingFreq ; % 采样 500Hz
data_x = samples;  % 数据
data_x_time = sampleTime;
data_x_time = data_x_time(:, 1);

% ==滑窗前带通滤波==
filt_n = 4; % 带通滤波器阶数
filter_low = 0.1; % 带通滤波范围
filter_high = 32;
data_x = BPfilter(data_x, Fs, filt_n, filter_low, filter_high);
% %===CAR===(某一采样点全部通道减均值)
channel_num = size(data_x, 2);
channel_sum = zeros(size(data_x, 1), 1);
for i = 1:channel_num
    channel_sum = channel_sum + data_x(:, i);
end
channel_mean = channel_sum / channel_num;
for i = 1:channel_num
    data_x(:, i) = data_x(:, i) - channel_mean;
end

% 确定 769/770 cue 出现位置
label = [];
label_time= [];
trialsize = 0;
for i = 1:size(stims,1)
    if stims(i, 2) == 769 || stims(i, 2) == 770
        trialsize = trialsize + 1;
        label = [label stims(i, 2)-769];
        label_time = [label_time stims(i, 1)];
    end
end
pos = zeros(1,length(data_x_time));
k = 1;
for i = 1:length(label_time)
    for j = 1:length(data_x_time)
        if data_x_time(j) > label_time(i)
            pos(k) = j;
            k = k + 1;
            break
        end
    end
end

width = 2500;
step = 10;
window_size = 500;
window_num = int32((width - window_size) / step + 1);
j = 1;

signal_label = zeros(1, trialsize*window_num);
channal_num = size(data_x, 2);
signal3d = zeros([window_size, channal_num, trialsize*window_num]);
for k = 1:length(label)
    for i = 1:window_num
        signal_label(j) = label(k);
        start = pos(k) + (i-1) * step;
        signal3d(:, :, j) = data_x(start:start + window_size - 1, :);
        j = j + 1;
    end
end
end

