function [er, bad] = cnntest(net, x, y)
%��֤����������׼ȷ��    
%  feedforward
net = cnnff(net, x);
[~, h] = max(net.o);
[~, a] = max(y);
bad = find(h ~= a); % ����Ԥ��������������

er = numel(bad) / size(y, 2);% ���������
end
