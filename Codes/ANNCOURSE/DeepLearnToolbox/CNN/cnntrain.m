function net = cnntrain(net, x, y, opts)
% cnntrain函数用于训练CNN
% net为网络,x是数据，y为训练目标，opts (options)为训练参数
% 生成随机序列，每次选取一个batch（50）个样本进行训练。 
% 批训练：计算50个随机样本的梯度，求和之后一次性更新到模型权重中。 
% 在批训练过程中调用： 
% Cnnff.m 完成前向过程 
% Cnnbp.m 完成误差传导和梯度计算过程 
% Cnnapplygrads.m 把计算出来的梯度加到原始模型上去

% m为图片祥本的数量60000，size(x) = 28*28*60000
m = size(x, 3);
% batchsize为批训练时，一批所含图片样本数（50） 
numbatches = m / opts.batchsize;
if rem(numbatches, 1) ~= 0
    error('numbatches not integer');
end
net.rL = []; % rL是最小均方误差的平滑序列，绘图要用
for i = 1 : opts.numepochs % 训练迭代
    %显示训练到第几个epoch，一共多少个epoch
    disp(['epoch ' num2str(i) '/' num2str(opts.numepochs)]);
    tic;
    % Matlab自带函数randperm(n)产生1到n的整数的无重复的随机排列，可以得到无重复的随机数。 
    % 生成m（图片数量）1~n整数的随机无重复排列，用于打乱训练顺序 kk 1x60000
    kk = randperm(m);
    for l = 1 : numbatches % 训练每个batch 
        %得到训练信号，一个样本是一层x(:, :, sampleOrder)，每次训练，取50个样本．kk
        %1-50|51-100|101…… batch_x 28x28x50
        batch_x = x(:, :, kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize));
        %label信号，一个样本是一列
        batch_y = y(:,    kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize));
        %NN信号前传导过程
        net = cnnff(net, batch_x);
        %计算误差并反向传导，计算梯度
        net = cnnbp(net, batch_y);
        %应用梯度，模型更新
        net = cnnapplygrads(net, opts);
        
        %net.L为模型的costFunction,即最小均方误差mse
        %net.rL是最小均方误差的平滑序列
        if isempty(net.rL)
            net.rL(1) = net.L;
        end
        net.rL(end + 1) = 0.99 * net.rL(end) + 0.01 * net.L;
    end
    toc;
end
end
