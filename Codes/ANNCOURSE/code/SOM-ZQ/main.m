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
x=[1,0,0,0;1,1,0,0;1,1,1,0;0,1,0,0;1,1,1,1];
x_label = {'X1','X2','X3','X4','X5'};
[data_row,data_column]=size(x);
m = 5;n = 5;%自组织映射网络m*n
iter = 10000;%设置迭代次数

[w,save_w] = f_SOM(x,m,n,iter);

%原数据在神经元的映射(输出与五个输入数据最近的神经元位置)
result = zeros(1,m*n);
for num=1:data_row
    [~,column]= min(sum(( (w - repmat(x(num,:), m*n,1)) .^2) ,2));   
    result(column) = num;
end
%神经元分类结果,每个神经元节点对应的输入样本标签
PlotSOM(x,result,x_label);

%===test===
x_test = [100 100 99 98];
test_result = zeros(1,m*n);
[~,column]= min(sum(( (w - repmat(x_test, m*n,1)) .^2) ,2));   
test_result(column) = 1;
PlotSOM(x_test,test_result,'P');
%==========学习率曲线======
% x = 1:10000;
% %分段函数的写法
% rate =((-4.604604604604604e-4) * x  + 0.500460460460461).*(x<1000)+((-4.444444444444445e-6) * x + 0.044444444444444) .* (x>=1000);
% plot(x,rate);
%==========优胜邻域半径曲线======
% x = 1:1000;
% rate = (-0.002002002002002) * x + 2.002002002002003;
% rate2 = 2*exp(-x/(10000/log(2)));
% plot(x,rate);
% x = 1:10000;
% rate = zeros(1,10000);
% rate(1)=2;
% for i=1:10000
%     rate(i+1) =  rate(i)+1-x(i)/10000;
% end
% plot(x,rate(1:10000));

