%% set up the parameters used in the analysis 
settings.SelCh = 1:8;     % the channels selected to processʵ��������Ҫ�����ź�ͨ������
settings.Feature_BinWidth = 0.2; % the window size of features��the units is in sec
settings.PowerspectrumOverlap=0.2; % the overlap of slice window in calculating the spectrum
settings.Feature_Extraction = 'pmtm';  % the method of LFP feature extraction   �������ܶȹ���
settings.Freq_Band = [1:5:100]; % the frequency bands to be used
settings.Crossvalidataion = 5; % the number of folds used in the decoding cross-validation
% settings.NeuroDataDir='E:\�ٶ���ͬ����\�ζ����Զ�����-���\�ζ����ļ�\matlab\LFPcode\ns3_LFP2_20171205001'; % the location of the data to be analyzed, the kinematic data and neural data are in the same folder

