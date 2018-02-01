%% 功率谱计算
function NeuroDataPowerSpe=PowerSpectrum(NeuroDataSel,settings)
ChannelNum = 8;%提取通道数
WindowOverLap = settings.PowerspectrumOverlap*500;%400
Step = settings.Feature_BinWidth*500;%200
BinNum = floor(size(NeuroDataSel,2)/Step-WindowOverLap/Step);%提取窗个数  15377
%BinNum = floor(size(NeuroDataSel,2)/Step);%提取窗个数
NeuroDataPowerSpe = [];
for m = 1:ChannelNum
    for n = 1:BinNum
        DataSel = NeuroDataSel(m,(n-1)*Step+1:n*Step+WindowOverLap);%提取所选窗内神经数据
        %DataSel = NeuroDataSel(m,(n-1)*Step+1:n*Step);%提取所选窗内神经数据,不带overlap
        [PowerSpe(n,:),f] = pmtm(DataSel,2.5,1024,settings.fs);%计算功率谱  功率谱的时宽带宽积为2.5，采样点数为2048
    end
    clear DataSel;
    disp(m);
    for k = 1:size(settings.Freq_Band,2)-1  %40段
        l = find(f>=settings.Freq_Band(k) & f<settings.Freq_Band(k+1)); %取出频率在0.3—200Hz部分
        LowFrequencyPSF(k,:) = sum(PowerSpe(:,l)',1);
    end
    PowerSpe = PowerSpe';
    save([settings.SettingPathName '\PSF',num2str(m)],'PowerSpe');
    NeuroDataPowerSpe = [NeuroDataPowerSpe;LowFrequencyPSF]; %频率在0.3—200Hz部分的信号功率谱
    clear PowerSpe;
end
save([settings.SettingPathName '\f'],'f');                                     
end