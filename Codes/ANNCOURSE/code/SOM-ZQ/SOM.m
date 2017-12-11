% newsom函数 创建som神经网络函数 
% net=newsom(PR,[D1,D2,...],TFCN,DFCN,OLR,OSTEPS,TLR,TND)
% PR:R个输入元素的最大值和最小值的设定值，R*2维矩阵
% Di：第I层的维数，默认为[5 8]
% TFCN：拓扑函数，默认为hextop
% DFCN:距离函数，默认为linkdist
% OLR：分类阶段学习速率，默认为0.9
% OSTEPS：分类阶段的步长，默认为1000
% TLR：调谐阶段的学习速率，默认为0.02
% TNS:调谐阶段的领域距离，默认为1.

% newc函数用于创建一个竞争层
% net=newc(PR,S,KLR,CLR)
% S:神经元的数目
% KLR：Kohonen学习速度，默认为0.01
% CLR：Conscience学习速度，默认为0.001
% net:函数返回值，一个新的竞争层。

% %随机生成1000个二维向量，作为样本，并绘出其分布 
% p1 = rand(2,500)+1; 
% p2 = rand(2,500);
% p3 = rands(2,500)+1;
% P = [p1 p2 p3];
% plot(P(1,:),P(2,:),'+r');
% title('初始随机样本点分布'); 
% xlabel('P(1)'); 
% ylabel('P(2)'); 
% %建立网络，得到初始权值 
% net=newsom([0 1; 0 1],[5 6]); 
% w1_init=net.iw{1,1};
% %绘出初始权值分布图 
% figure; 
% plotsom(w1_init,net.layers{1}.distances);
% 
% net.trainParam.epochs=50; 
% net=train(net,P); 
% figure; 
% plotsom(net.iw{1,1},net.layers{1}.distances) 
% 
% %对于训练好的网络，选择特定的输入向量，得到网络的输出结果 
% % p=[0.5;0.3]; 
% % a=0; 
% % a = sim(net,p) ;
% % ac = vec2ind(a);
% a = sim(net,P);
% ac = vec2ind(a);
% T = rands(2,50)+1;
% y = sim(net,T);
% yc = vec2ind(y);
%plotsomhits每个神经元都显示了它分类的输入向量的数量
%====
% 1.初始化
%    1)迭代次数：时间步长iter
%    2)输出结点权值向量初始值,向量各元素可选区间(0，1)上的随机值,这里选择正方形邻域
%    3)学习率初始值
%    4)邻域半径的设置应尽量包含较多的邻神经元,整个输出平面的一半
% 2.求竞争获胜神经元;欧拉距离函数求解
% 3.权值更新：
%        获胜节点和邻域范围内神经元集合的m个节点更新权值，j=1:m；    
%            wj(t+1)=wj(t)+learnfun(t)*neighborfun(t)*(x-wj);
% 4.更新学习率，更新邻域函数 
%        neighborfun(t)=neighbor0*exp(-dij/t1);   t1=iter/log(neighbor0)
%         learnfun(t)=learn0*exp(-t/t2);     t2=iter
% 5.当特征映射不再发生明显变化时或达到最大网络训练次数时退出,否则转入第2步
x=[1 1 1 0 1;
    0 1 1 1 1;
    0 0 1 0 1;
    0 0 0 0 1];
x_label = ['X1','X2','X3','X4','X5'];
% net=newsom([0 1; 0 1; 0 1; 0 1],[5 5],'hextop','linkdist',0.5,1000,0.04,2); 
% net=train(net,x); 
[data_row,data_clown]=size(x);
m = 5;n = 5;%自组织映射网络m*n
w = rand(m*n, data_clown);%权值随机初始化
learn0 = 0.5;
learn_rate = learn0;%学习率初始化
learn_para=1000;%学习率参数
iter =200;%设置迭代次数
%神经元位置
[I,J] = ind2sub([m, n], 1:m*n);
neighbor0 =2;
neighbor_redius = neighbor0;%邻域初始化
neighbor_para = 1000/log(neighbor_redius);%邻域参数

%迭代次数
for t=1:iter 
    %  样本点遍历
    for j=1:data_row  
        %获取样本点值
        data_x = x(j,:); 
        %找到获胜神经元
        [win_row, win_som_index]=min(dist(data_x,w'));  
        %获胜神经元的拓扑位置
        [win_som_row,win_som_cloumn] =  ind2sub([m, n],win_som_index);
        win_som=[win_som_row,win_som_cloumn];
        %计算其他神经元和获胜神经元的距离,邻域函数
        %distance_som = sum(( ([I( : ), J( : )] - repmat(win_som, som_sum,1)) .^2) ,2);
        distance_som = exp( sum(( ([I( : ), J( : )] - repmat(win_som, m*n,1)) .^2) ,2)/(-2*neighbor_redius*neighbor_redius)) ;
        %权值更新
        for i = 1:m*n
           % if distance_som(i)<neighbor_redius*neighbor_redius 
            w(i,:) = w(i,:) + learn_rate.*distance_som(i).*( data_x - w(i,:));
        end
    end

    %更新学习率
    learn_rate = learn0 * exp(-t/learn_para);   
    %更新邻域半径
    neighbor_redius = neighbor0*exp(-t/neighbor_para);  
end
%data数据在神经元的映射
%神经元数组som_num存储图像编号
som_num=cell(1,size(w,1));
for i=1:size(w,1)
    som_num{1,i}=[];
end
%每个神经元节点对应的data样本编号
for num=1:data_row
    [som_row,clown]= min(sum(( (w - repmat(x(num,:), m*n,1)) .^2) ,2));
    som_num{1,clown}= [som_num{1,clown},num];    
end
