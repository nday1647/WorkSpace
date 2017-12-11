function net = cnnbp(net, y)
% cnnbp函数实现计算并传递误差，计算梯度
n = numel(net.layers);

%   error
net.e = net.o - y;
%  loss function均方误差
net.L = 1/2* sum(net.e(:) .^ 2) / size(net.e, 2);

%  计算尾部单层感知机的误差backprop deltas
net.od = net.e .* (net.o .* (1 - net.o));   %  output delta
% 特征向里误差,上一层收集下层误差,size = [192*50]
net.fvd = (net.ffW' * net.od);              %  feature vector delta

%如果MLP的前一层（特征抽取最后一层）是卷积层，卷积层的输出经过sigmoid函数处理，error求导
%在数字识别这个网络中不要用到
if strcmp(net.layers{n}.type, 'c')         %  only conv layers has sigm function
    net.fvd = net.fvd .* (net.fv .* (1 - net.fv));
end

% 改变误差矩阵形状
% 把单层感知机的输入层featureVector的误差矩阵，恢复为subFeatureMap2的4*4二维矩阵形式
%  reshape feature vector deltas into output map style
sa = size(net.layers{n}.a{1});
fvnum = sa(1) * sa(2);% 一个图所含有的特征向量的数量
for j = 1 : numel(net.layers{n}.a)
    % net最后一层的delta，由特征向量delta，侬次取一个featureMap大小，然后组台成为一个featureMap的形状 
    % 在fvd里面保存的是所有祥本的特征向量（在cnnff.m函数中用特征map拉成的）；这里需要重新变换回来特征map的形式。
    % net.fvd(((j - 1) * fvnum + 1) : j * fvnum, : ) ,一个featureMap的误差d 
    net.layers{n}.d{j} = reshape(net.fvd(((j - 1) * fvnum + 1) : j * fvnum, :), sa(1), sa(2), sa(3));
end

% 误差在特征提取网络【卷积降采样层】的传播
% 如果本层是卷积层，它的误差是从后一层（降采样层）传过来，误差传播实际上是用降采样的反向过程，也就是降采样层的误差复制为2*2=4份。
% 卷积层的输入是经过sigmoid处理的，所以，从降采样层扩充来的误差要经过sigmoid求导处理。 
% 如果本层是降采样层，他的误差是从后一层（卷积层）传过来，误差传播实际是用卷积的反向过程，也就是卷积层的误差，反卷积（卷积核转180度）卷积层的误差。
for l = (n - 1) : -1 : 1
    if strcmp(net.layers{l}.type, 'c')
        if strcmp(net.layers{l+1}.type, 's')
        %卷积层的灵敏度传输
        for j = 1 : numel(net.layers{l}.a)
            % l层卷积层，误差从下层(降采样层)传来，采用后往前均摊 expand扩展矩阵
            % net.layers{l}.d{j} = net.layers{l}.a{j} .* (1 - net.layers{l}.a{j}) .* (expand(net.layers{l + 1}.d{j}, [net.layers{l + 1}.scale net.layers{l + 1}.scale 1]) / net.layers{l + 1}.scale ^ 2);
            net.layers{l}.d{j} = net.layers{l}.a{j} .* (1 - net.layers{l}.a{j}) .* (expand(net.layers{l + 1}.d{j}, [net.layers{l+1}.scale(1) net.layers{l+1}.scale(2) 1]) / net.layers{l + 1}.scale(1).*net.layers{l + 1}.scale(2));
        end
        end
    elseif strcmp(net.layers{l}.type, 's')
        for i = 1 : numel(net.layers{l}.a)%l输出层数量
            z = zeros(size(net.layers{l}.a{1}));
            for j = 1 : numel(net.layers{l + 1}.a)
                % net.layers{l + 1}.d{j}下一层(卷积层)的灵敏度
                % net.layers{l + 1}.k{i}{j}下一层(卷积层)的卷积核
                z = z + convn(net.layers{l + 1}.d{j}, rot180(net.layers{l + 1}.k{i}{j}), 'full');
            end
            net.layers{l}.d{i} = z;
        end
    end
end

%  calc gradients
for l = 2 : n
    if strcmp(net.layers{l}.type, 'c')
        for j = 1 : numel(net.layers{l}.a)
            for i = 1 : numel(net.layers{l - 1}.a)
                net.layers{l}.dk{i}{j} = convn(flipall(net.layers{l - 1}.a{i}), net.layers{l}.d{j}, 'valid') / size(net.layers{l}.d{j}, 3);
            end
            net.layers{l}.db{j} = sum(net.layers{l}.d{j}(:)) / size(net.layers{l}.d{j}, 3);
        end
    end
end
net.dffW = net.od * (net.fv)' / size(net.od, 2);
net.dffb = mean(net.od, 2);

function X = rot180(X)
    X = flipdim(flipdim(X, 1), 2);
end
end
