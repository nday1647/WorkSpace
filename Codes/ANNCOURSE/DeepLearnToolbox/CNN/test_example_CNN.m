function test_example_CNN
% Test_example_CNN:
% 1.����CNN�Ļ�����������������������������������˵Ĵ�С���������Ľ���
% 2.cnnsetup���� ��ʼ������ˡ�ƫ�õ�
% 3.cnntrain���� ѵ��cnn����ѵ�����ݷֳ�batch��Ȼ����� 
%   3.1 cnnff ���ѵ����ǰ�����
%   3.2 cnnbp���㲢�����������error���������ݶȣ�Ȩ�ص��޸�����
%   3.3 cnnapplygrads �Ѽ���������ݶȼӵ�ԭʼģ����ȥ
% 4.cnntest ���������Ե�ǰģ�͵�׼ȷ��
% ��ģ�Ͳ��õ�����Ϊmnist_uint8.mat������70000����д������������60000��Ϊѵ��������10000��Ϊ��������

%������ת����Ӧ�ĸ�ʽ������һ��
% load mnist_uint8.mat;
% train_x = double(reshape(train_x',28,28,60000))/255;
% test_x = double(reshape(test_x',28,28,10000))/255;
% train_y = double(train_y');
% test_y = double(test_y');
load GDF_MI2a;
train_x = train_x(1:300,:,:);
test_x = test_x(1:300,:,:);
train_x = permute(train_x,[2 1 3]);
test_x= permute(test_x,[2 1 3]);
train_x(isnan(train_x)==1)=0;
test_x(isnan(train_x)==1)=0;
% ex1 Train a 6c-2s-12c-2s Convolutional neural network 
% will run 1 epoch in about 200 second and get around 11% error. 
% With 100 epochs you'll get around 1.2% error
rand('state',0)
% load CNNnet;
cnn.layers = {
    struct('type', 'i') %input layer
    %����㣬outputmaps������� kernelsize����˴�С
    struct('type', 'c', 'outputmaps', 8, 'kernelsize', [22,1]) 
    struct('type', 's', 'scale', [1,2]) %sub sampling layer
    struct('type', 'c', 'outputmaps', 5, 'kernelsize', [1,15]) %convolution layer
    struct('type', 's', 'scale', [1,4]) %subsampling layer
};

%optsѵ������
opts.alpha = 1;
opts.batchsize = 40;%��ѵ��������������
opts.numepochs = 50;%��������

cnn = cnnsetup(cnn, train_x, train_y);
cnn = cnntrain(cnn, train_x, train_y, opts);

[ertr, badtr] = cnntest(cnn, train_x, train_y);
[er, bad] = cnntest(cnn, test_x, test_y);

%plot mean squared error���ƾ����������
figure; plot(cnn.rL);
ylabel('������MSE');
title(['�����ʣ�ѵ����' num2str(ertr) '/���Լ�' num2str(er)]);
% assert(er<0.12, 'Too big error');
% save CNNnet cnn;
end

