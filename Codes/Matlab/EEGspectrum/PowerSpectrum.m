%% �����׼���
function NeuroDataPowerSpe=PowerSpectrum(NeuroDataSel,settings)
ChannelNum = 8;%��ȡͨ����
WindowOverLap = settings.PowerspectrumOverlap*500;%400
Step = settings.Feature_BinWidth*500;%200
BinNum = floor(size(NeuroDataSel,2)/Step-WindowOverLap/Step);%��ȡ������  15377
%BinNum = floor(size(NeuroDataSel,2)/Step);%��ȡ������
NeuroDataPowerSpe = [];
for m = 1:ChannelNum
    for n = 1:BinNum
        DataSel = NeuroDataSel(m,(n-1)*Step+1:n*Step+WindowOverLap);%��ȡ��ѡ����������
        %DataSel = NeuroDataSel(m,(n-1)*Step+1:n*Step);%��ȡ��ѡ����������,����overlap
        [PowerSpe(n,:),f] = pmtm(DataSel,2.5,1024,settings.fs);%���㹦����  �����׵�ʱ������Ϊ2.5����������Ϊ2048
    end
    clear DataSel;
    disp(m);
    for k = 1:size(settings.Freq_Band,2)-1  %40��
        l = find(f>=settings.Freq_Band(k) & f<settings.Freq_Band(k+1)); %ȡ��Ƶ����0.3��200Hz����
        LowFrequencyPSF(k,:) = sum(PowerSpe(:,l)',1);
    end
    PowerSpe = PowerSpe';
    save([settings.SettingPathName '\PSF',num2str(m)],'PowerSpe');
    NeuroDataPowerSpe = [NeuroDataPowerSpe;LowFrequencyPSF]; %Ƶ����0.3��200Hz���ֵ��źŹ�����
    clear PowerSpe;
end
save([settings.SettingPathName '\f'],'f');                                     
end