function net = cnnff(net, x)
% 取得CNN的输入
n = numel(net.layers);
net.layers{1}.a{1} = x;%a是输入map，一个[28, 28, 50]的矩阵（具体情况具体定）
inputmaps = 1;
% 两次卷积核降采样层处理
for l = 2 : n   %  for each layer
    if strcmp(net.layers{l}.type, 'c')
        %  !!below can probably be handled by insane matrix operations
        for j = 1 : net.layers{l}.outputmaps   %  for each output map
            %  create temp output map
            z = zeros(size(net.layers{l - 1}.a{1}) - [net.layers{l}.kernelsize(1) - 1 net.layers{l}.kernelsize(2) - 1 0]);
            for i = 1 : inputmaps   %  for each input map
                %  与相应的内核进行卷积，并添加到输出临时变量z
                z = z + convn(net.layers{l - 1}.a{i}, net.layers{l}.k{i}{j}, 'valid');
            end
            % 加权重
            net.layers{l}.a{j} = sigm(z + net.layers{l}.b{j});
        end
        %  set number of input maps to this layers number of outputmaps
        inputmaps = net.layers{l}.outputmaps;
    elseif strcmp(net.layers{l}.type, 's')
        %  downsample
        for j = 1 : inputmaps
            % z = convn(net.layers{l - 1}.a{j}, ones(net.layers{l}.scale) / (net.layers{l}.scale ^ 2), 'valid');   %  !! replace with variable
            % z = convn(net.layers{l - 1}.a{j}, ones(net.layers{l}.scale(1),net.layers{l}.scale(2)) / (net.layers{l}.scale(1).*net.layers{l}.scale(2))); 
            zero = zeros(net.layers{l}.scale(1),net.layers{l}.scale(2));
            zero(1)=1;
            z = convn(net.layers{l - 1}.a{j}, zero); 
            % net.layers{l}.a{j} = z(1 : net.layers{l}.scale : end, 1 : net.layers{l}.scale : end, :);
            net.layers{l}.a{j} = z(1 : net.layers{l}.scale(1) : end, 1 : net.layers{l}.scale(2) : end-net.layers{l}.scale(2)+1, :);
        end
    end
end

% 尾部单层感知机的数据处理 concatenate all end layer feature maps into vector
net.fv = [];
for j = 1 : numel(net.layers{n}.a)
    sa = size(net.layers{n}.a{j});
    net.fv = [net.fv; reshape(net.layers{n}.a{j}, sa(1) * sa(2), sa(3))];
end
%  %通过全连接层的映射得到网络的最终预测结果输出
net.o = sigm(net.ffW * net.fv + repmat(net.ffb, 1, size(net.fv, 2)));

end
