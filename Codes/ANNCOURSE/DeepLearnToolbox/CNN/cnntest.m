function [er, bad] = cnntest(net, x, y)
%验证测试样本的准确率    
%  feedforward
net = cnnff(net, x);
[~, h] = max(net.o);
[~, a] = max(y);
bad = find(h ~= a); % 计算预测错误的样本数量

er = numel(bad) / size(y, 2);% 计算错误率
end
