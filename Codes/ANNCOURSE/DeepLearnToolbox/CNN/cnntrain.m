function net = cnntrain(net, x, y, opts)
% cnntrain��������ѵ��CNN
% netΪ����,x�����ݣ�yΪѵ��Ŀ�꣬opts (options)Ϊѵ������
% ����������У�ÿ��ѡȡһ��batch��50������������ѵ���� 
% ��ѵ��������50������������ݶȣ����֮��һ���Ը��µ�ģ��Ȩ���С� 
% ����ѵ�������е��ã� 
% Cnnff.m ���ǰ����� 
% Cnnbp.m ����������ݶȼ������ 
% Cnnapplygrads.m �Ѽ���������ݶȼӵ�ԭʼģ����ȥ

% mΪͼƬ�鱾������60000��size(x) = 28*28*60000
m = size(x, 3);
% batchsizeΪ��ѵ��ʱ��һ������ͼƬ��������50�� 
numbatches = m / opts.batchsize;
if rem(numbatches, 1) ~= 0
    error('numbatches not integer');
end
net.rL = []; % rL����С��������ƽ�����У���ͼҪ��
for i = 1 : opts.numepochs % ѵ������
    %��ʾѵ�����ڼ���epoch��һ�����ٸ�epoch
    disp(['epoch ' num2str(i) '/' num2str(opts.numepochs)]);
    tic;
    % Matlab�Դ�����randperm(n)����1��n�����������ظ���������У����Եõ����ظ���������� 
    % ����m��ͼƬ������1~n������������ظ����У����ڴ���ѵ��˳�� kk 1x60000
    kk = randperm(m);
    for l = 1 : numbatches % ѵ��ÿ��batch 
        %�õ�ѵ���źţ�һ��������һ��x(:, :, sampleOrder)��ÿ��ѵ����ȡ50��������kk
        %1-50|51-100|101���� batch_x 28x28x50
        batch_x = x(:, :, kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize));
        %label�źţ�һ��������һ��
        batch_y = y(:,    kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize));
        %NN�ź�ǰ��������
        net = cnnff(net, batch_x);
        %���������򴫵��������ݶ�
        net = cnnbp(net, batch_y);
        %Ӧ���ݶȣ�ģ�͸���
        net = cnnapplygrads(net, opts);
        
        %net.LΪģ�͵�costFunction,����С�������mse
        %net.rL����С��������ƽ������
        if isempty(net.rL)
            net.rL(1) = net.L;
        end
        net.rL(end + 1) = 0.99 * net.rL(end) + 0.01 * net.L;
    end
    toc;
end
end
