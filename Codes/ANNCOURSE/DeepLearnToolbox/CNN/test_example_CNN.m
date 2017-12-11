function test_example_CNN
% Test_example_CNN:
% 1.设置CNN的基本参数规格，如卷积、降采样层的数量，卷积核的大小、降采样的降幅
% 2.cnnsetup函数 初始化卷积核、偏置等
% 3.cnntrain函数 训练cnn，把训练数据分成batch，然后调用 
%   3.1 cnnff 完成训练的前向过程
%   3.2 cnnbp计算并传递神经网络的error，并计算梯度（权重的修改量）
%   3.3 cnnapplygrads 把计算出来的梯度加到原始模型上去
% 4.cnntest 函数，测试当前模型的准确率
% 该模型采用的数据为mnist_uint8.mat，含有70000个手写数字样本其中60000作为训练样本，10000作为测试样本

%把数据转成相应的格式，并归一化
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
    %卷积层，outputmaps卷积核数 kernelsize卷积核大小
    struct('type', 'c', 'outputmaps', 8, 'kernelsize', [22,1]) 
    struct('type', 's', 'scale', [1,2]) %sub sampling layer
    struct('type', 'c', 'outputmaps', 5, 'kernelsize', [1,15]) %convolution layer
    struct('type', 's', 'scale', [1,4]) %subsampling layer
};

%opts训练参数
opts.alpha = 1;
opts.batchsize = 40;%批训练总样本的数量
opts.numepochs = 50;%迭代次数

cnn = cnnsetup(cnn, train_x, train_y);
cnn = cnntrain(cnn, train_x, train_y, opts);

[ertr, badtr] = cnntest(cnn, train_x, train_y);
[er, bad] = cnntest(cnn, test_x, test_y);

%plot mean squared error绘制均方误差曲线
figure; plot(cnn.rL);
ylabel('均方差MSE');
title(['错误率：训练集' num2str(ertr) '/测试集' num2str(er)]);
% assert(er<0.12, 'Too big error');
% save CNNnet cnn;
end

