%% set up the parameters used in the analysis 
settings.SelCh = 1:8;     % the channels selected to process实际上所需要的神经信号通道个数
settings.Feature_BinWidth = 0.2; % the window size of features，the units is in sec
settings.PowerspectrumOverlap=0.2; % the overlap of slice window in calculating the spectrum
settings.Feature_Extraction = 'pmtm';  % the method of LFP feature extraction   功率谱密度估计
settings.Freq_Band = [1:5:100]; % the frequency bands to be used
settings.Crossvalidataion = 5; % the number of folds used in the decoding cross-validation
% settings.NeuroDataDir='E:\百度云同步盘\任朵朵的自动备份-浙大\任朵朵的文件\matlab\LFPcode\ns3_LFP2_20171205001'; % the location of the data to be analyzed, the kinematic data and neural data are in the same folder

