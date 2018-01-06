clc;clear;
%��ȡ����
path = 'D:\Myfiles\EEGProject\BCICompetitionIV\BCICIV_2a_gdf\A03T.gdf';

%DATA_CHANNEL=h.NS;%ͨ����
DATA_CHANNEL=(1:22);
%DATA_LENGTH=h.NRec;%���ݳ���3000����
Type = [769,770];
y_tag = [1,-1];
[x, y, Fs] = get_GDFdata(path, DATA_CHANNEL, Type, y_tag);
DATA_LENGTH = length(x{1});%1��trial�ĳ���
%size(A,1)���ؾ���A����Ӧ������(2->����)
train_size = 60;%ѵ��������Ŀ

%===============
filt_n =4;%��ͨ�˲�������
filter_low = 4;%��ͨ�˲���Χ
filter_high = 40;
AfterFilter_x = BPfilter(x, Fs, filt_n, filter_low, filter_high);

%===����CSP�㷨������ͶӰ����F===
F = csp_train(AfterFilter_x, y, train_size);
%ʹ��ͶӰ����F����������x���пռ��˲�
xAfterCSP = CSPSpatialFilter(AfterFilter_x, F);
yArray = cell2mat(y)';%��ǩyת��Ϊ��������
xy = [xAfterCSP yArray];
train_xAfterCSP = xAfterCSP(1:train_size,:);train_y = yArray(1:train_size);
test_size = length(AfterFilter_x) - train_size;
test_xAfterCSP = xAfterCSP(train_size+1:end,:);test_y = yArray(train_size+1:end);

%===ѵ��LDA������, ����ͶӰ����������ĵ�, ���Է��ز��Ա�ǩy_test===
% [W, centers] = LDA_train1(train_xAfterCSP, train_y);
% [W, centers, y0] = LDA_train(train_xAfterCSP, train_y);
% y_test = LDA_test(test_xAfterCSP, test_size, W, y0);

%===ѵ��SVM������, ����ͶӰ����������ĵ�===
SVMModel = fitcsvm(train_xAfterCSP, train_y,'KernelFunction','linear');
[predict_y,score] = predict(SVMModel,test_xAfterCSP);

%===���ݷ��ز��Ա�ǩ���������ȷ��
right = sum(predict_y == test_y);
%floor����ȡ�� disp��� Ԥ��׼ȷ��
Accuracy = floor(right/test_size*100);

%==Kappa==
A1 = sum(test_y==1);A2 = test_size - A1;
B1 = sum(predict_y==1);B2 = test_size - B1;
Pe = (A1*B1+A2*B2)/test_size.^2;
Kappa = (Accuracy*0.01-Pe)/(1-Pe);
%===

disp(['��������������' int2str(test_size) '��Ԥ��׼ȷ�ʣ�' int2str(Accuracy) '%']);