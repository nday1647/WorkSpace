function [w,save_w] = f_SOM(x,m,n,iter)
%F_SOM 输入样本x，神经网络维度m*n，迭代次数iter
[data_row,data_column]=size(x);
w = rand(m*n, data_column)*0.1;%权值随机初始化25*5
learn0 = 0.5; learn_rate = learn0;%学习率初始化
neighbor0 = 2;
neighbor_redius = neighbor0;%邻域初始化
%神经元位置
[I,J] = ind2sub([m, n], 1:m*n);

save_w = cell(1,1); count = 1;
%迭代次数
for t=1:iter 
    %  样本点遍历
    for j=1:data_row  
        %获取样本点值
        data_x = x(j,:); 
        %找到获胜神经元[minx, ind] = min(x);
        [~, win_som_index]=min(dist(data_x,w'));  
        %获胜神经元的拓扑位置
        [win_som_row,win_som_cloumn] =  ind2sub([m, n],win_som_index);
        win_som=[win_som_row,win_som_cloumn];
        %计算其他神经元和获胜神经元的距离,邻域函数
        distance_som = exp( sum(( ([I(:), J(:)] - repmat(win_som, m*n,1)) .^2) ,2)/(-2*neighbor_redius*neighbor_redius));%近大远小0~1
        %权值更新 wj(t+1)=wj(t)+learnfun(t)*neighborfun(t)*(x-wj);
        for i = 1:m*n
%            if distance_som(i)<neighbor_redius*neighbor_redius 
            w(i,:) = w(i,:) + learn_rate.*distance_som(i).*( data_x - w(i,:));
        end
    end
    if ~mod(t,200)
        save_w{count} = w;
        count = count + 1;
    end

    %更新学习率(折线)
    %learn_rate = learn0 * exp(-t/iter); 
    if(t<1000)
        learn_rate =(-4.604604604604604e-4) * t  + 0.500460460460461;
    else
        learn_rate =(-4.444444444444445e-6) * t + 0.044444444444444;
    end
    %更新邻域半径
    neighbor_para = iter/log(neighbor0);%邻域参数
    neighbor_redius = neighbor0*exp(-t/neighbor_para);%t由1到10000，r由2到1
%     neighbor_redius = (-0.002002002002002) * t + 2.002002002002003;
end

end

