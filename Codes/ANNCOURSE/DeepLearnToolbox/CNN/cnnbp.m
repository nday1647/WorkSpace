function net = cnnbp(net, y)
% cnnbp����ʵ�ּ��㲢�����������ݶ�
n = numel(net.layers);

%   error
net.e = net.o - y;
%  loss function�������
net.L = 1/2* sum(net.e(:) .^ 2) / size(net.e, 2);

%  ����β�������֪�������backprop deltas
net.od = net.e .* (net.o .* (1 - net.o));   %  output delta
% �����������,��һ���ռ��²����,size = [192*50]
net.fvd = (net.ffW' * net.od);              %  feature vector delta

%���MLP��ǰһ�㣨������ȡ���һ�㣩�Ǿ���㣬�������������sigmoid��������error��
%������ʶ����������в�Ҫ�õ�
if strcmp(net.layers{n}.type, 'c')         %  only conv layers has sigm function
    net.fvd = net.fvd .* (net.fv .* (1 - net.fv));
end

% �ı���������״
% �ѵ����֪���������featureVector�������󣬻ָ�ΪsubFeatureMap2��4*4��ά������ʽ
%  reshape feature vector deltas into output map style
sa = size(net.layers{n}.a{1});
fvnum = sa(1) * sa(2);% һ��ͼ�����е���������������
for j = 1 : numel(net.layers{n}.a)
    % net���һ���delta������������delta��ٯ��ȡһ��featureMap��С��Ȼ����̨��Ϊһ��featureMap����״ 
    % ��fvd���汣����������鱾��������������cnnff.m������������map���ɵģ���������Ҫ���±任��������map����ʽ��
    % net.fvd(((j - 1) * fvnum + 1) : j * fvnum, : ) ,һ��featureMap�����d 
    net.layers{n}.d{j} = reshape(net.fvd(((j - 1) * fvnum + 1) : j * fvnum, :), sa(1), sa(2), sa(3));
end

% �����������ȡ���硾����������㡿�Ĵ���
% ��������Ǿ���㣬��������ǴӺ�һ�㣨�������㣩������������ʵ�������ý������ķ�����̣�Ҳ���ǽ������������Ϊ2*2=4�ݡ�
% �����������Ǿ���sigmoid����ģ����ԣ��ӽ������������������Ҫ����sigmoid�󵼴��� 
% ��������ǽ������㣬��������ǴӺ�һ�㣨����㣩������������ʵ�����þ���ķ�����̣�Ҳ���Ǿ�������������������ת180�ȣ���������
for l = (n - 1) : -1 : 1
    if strcmp(net.layers{l}.type, 'c')
        if strcmp(net.layers{l+1}.type, 's')
        %�����������ȴ���
        for j = 1 : numel(net.layers{l}.a)
            % l�����㣬�����²�(��������)���������ú���ǰ��̯ expand��չ����
            % net.layers{l}.d{j} = net.layers{l}.a{j} .* (1 - net.layers{l}.a{j}) .* (expand(net.layers{l + 1}.d{j}, [net.layers{l + 1}.scale net.layers{l + 1}.scale 1]) / net.layers{l + 1}.scale ^ 2);
            net.layers{l}.d{j} = net.layers{l}.a{j} .* (1 - net.layers{l}.a{j}) .* (expand(net.layers{l + 1}.d{j}, [net.layers{l+1}.scale(1) net.layers{l+1}.scale(2) 1]) / net.layers{l + 1}.scale(1).*net.layers{l + 1}.scale(2));
        end
        end
    elseif strcmp(net.layers{l}.type, 's')
        for i = 1 : numel(net.layers{l}.a)%l���������
            z = zeros(size(net.layers{l}.a{1}));
            for j = 1 : numel(net.layers{l + 1}.a)
                % net.layers{l + 1}.d{j}��һ��(�����)��������
                % net.layers{l + 1}.k{i}{j}��һ��(�����)�ľ����
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
