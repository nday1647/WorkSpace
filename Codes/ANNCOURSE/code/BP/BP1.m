%这个网络存在的一个问题就是识别精度只能达到0.01，该如何解决？
%创建神经网络（一层中间层，含两个神经元）
net=newff(X,T,2);

%设置权值阈值
net.iw{1,1}=[-6050.07653169327,1833.75998821591,12756.0935903260,-12756.0705320155,-1833.75998821591,6050.07653169327;
6121.63755883614,-1855.42703457461,-12906.9436689444,12906.9202961480,1855.44539321475,-6121.62425486913];
net.lw{2,1}=[178.325919123566,178.325895440407];
net.b{1}=[-0.545262186090581;0.560354884474101];
net.b{2}=[-1.00000961088171];
%net.iw{1,1}=[-10000,3000,15000,-15000,-3000,10000;
%10000,-3000,-15000,15000,3000,-10000];
%net.lw{2,1}=[250,250];
%net.b{1}=[-0.545262186090581;0.560354884474101];
%net.b{2}=[-1.00000961088171];




%设置训练参数
net.trainparam.show = 50 ;%显示频率（训练50次显示一次）
net.trainparam.epochs = 10000 ;%训练次数
net.trainparam.goal = 0.000001 ;%训练目标最小误差
net.trainParam.lr = 0.001 ;%学习速率
net.trainParam.max_fail =6;%设置最大失败次数
net.trainParam.mc=0.95;%设置动量因子
net.trainParam.min_grad=5e-7;%设置最小性能梯度

%开始训练
net=train(net,X,T);%%如何才能使途中只显示训练曲线？？


%读取测试数据
%[t1,t2,t3,t4,t5,t6,class]=textread('testdata.txt','%f%f%f%f%f%f%f',1000);
%testinput=[t1,t2,t3,t4,t5,t6];
%testinput=testinput';

%仿真
output1=sim(net,X);

%作图
S=zeros(1,n);
output=zeros(1,n);
for i=1:n
    if(output1(i)>=0.5)
        output(i)=1;
    end
    if(output1(i)<0.5) 
        output(i)=0;
    end
   %if(output1(i)>0.3&&output1(i)<0.7) 
        %output(i)=output1(i);
   %end
    if(output(i)~=T(i)) 
        S(i)=1;
    end
end
% figure(1)
%     plot(S,'r*');
    
%X(1,1)=input('输入第一个数：');
%X(2,1)=input('输入第二个数：')
%X(3,1)=input('输入第三个数：')
%X(4,1)=input('输入第四个数：');
%X(5,1)=input('输入第五个数：');
%X(6,1)=input('输入第六个数：');
%test=sim(net,X);
%test(1,1)

%求S中所有元素和
S1=sum(S);
S1=S1';
S2=sum(S1);


while(S2>5);
fprintf('再次训练！');
    
%  设置训练参数
net.trainparam.show = 50 ;%显示频率（训练50次显示一次）
net.trainparam.epochs = 10000 ;%训练次数
net.trainparam.goal = 0.00001 ;%训练目标最小误差
net.trainParam.lr = 0.001 ;%学习速率
net.trainParam.max_fail =6;%设置最大失败次数
% 开始训练
net=train(net,X,T);
output1=sim(net,X);

% 作图
S=zeros(1,100000);
output=zeros(1,100000);
for i=1:100000
    if(output1(i)>=0.5)
       output(i)=1;
    end
    if(output1(i)<0.5) 
       output(i)=0;
    end
   if(output(i)~=T(i)) 
       S(i)=1;
   end
end
% 显示训练权重和阈值
net.iw{1,1}
net.lw{2,1}
net.b{1}
net.b{2}

figure(2)
plot(S,'r*');

% 求S中所有元素和
S1=sum(S);
S1=S1';
S2=sum(S1);
S2
    pause;
end;

fprintf('符合要求！');


net.iw{1,1}
net.lw{2,1}
net.b{1}
net.b{2}