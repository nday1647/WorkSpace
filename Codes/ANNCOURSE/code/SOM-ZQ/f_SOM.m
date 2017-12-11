function [w,save_w] = f_SOM(x,m,n,iter)
%F_SOM ��������x��������ά��m*n����������iter
[data_row,data_column]=size(x);
w = rand(m*n, data_column)*0.1;%Ȩֵ�����ʼ��25*5
learn0 = 0.5; learn_rate = learn0;%ѧϰ�ʳ�ʼ��
neighbor0 = 2;
neighbor_redius = neighbor0;%�����ʼ��
%��Ԫλ��
[I,J] = ind2sub([m, n], 1:m*n);

save_w = cell(1,1); count = 1;
%��������
for t=1:iter 
    %  ���������
    for j=1:data_row  
        %��ȡ������ֵ
        data_x = x(j,:); 
        %�ҵ���ʤ��Ԫ[minx, ind] = min(x);
        [~, win_som_index]=min(dist(data_x,w'));  
        %��ʤ��Ԫ������λ��
        [win_som_row,win_som_cloumn] =  ind2sub([m, n],win_som_index);
        win_som=[win_som_row,win_som_cloumn];
        %����������Ԫ�ͻ�ʤ��Ԫ�ľ���,������
        distance_som = exp( sum(( ([I(:), J(:)] - repmat(win_som, m*n,1)) .^2) ,2)/(-2*neighbor_redius*neighbor_redius));%����ԶС0~1
        %Ȩֵ���� wj(t+1)=wj(t)+learnfun(t)*neighborfun(t)*(x-wj);
        for i = 1:m*n
%            if distance_som(i)<neighbor_redius*neighbor_redius 
            w(i,:) = w(i,:) + learn_rate.*distance_som(i).*( data_x - w(i,:));
        end
    end
    if ~mod(t,200)
        save_w{count} = w;
        count = count + 1;
    end

    %����ѧϰ��(����)
    %learn_rate = learn0 * exp(-t/iter); 
    if(t<1000)
        learn_rate =(-4.604604604604604e-4) * t  + 0.500460460460461;
    else
        learn_rate =(-4.444444444444445e-6) * t + 0.044444444444444;
    end
    %��������뾶
    neighbor_para = iter/log(neighbor0);%�������
    neighbor_redius = neighbor0*exp(-t/neighbor_para);%t��1��10000��r��2��1
%     neighbor_redius = (-0.002002002002002) * t + 2.002002002002003;
end

end

