%���������ڵ�һ���������ʶ�𾫶�ֻ�ܴﵽ0.01������ν����
%���������磨һ���м�㣬��������Ԫ��
net=newff(X,T,2);

%����Ȩֵ��ֵ
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




%����ѵ������
net.trainparam.show = 50 ;%��ʾƵ�ʣ�ѵ��50����ʾһ�Σ�
net.trainparam.epochs = 10000 ;%ѵ������
net.trainparam.goal = 0.000001 ;%ѵ��Ŀ����С���
net.trainParam.lr = 0.001 ;%ѧϰ����
net.trainParam.max_fail =6;%�������ʧ�ܴ���
net.trainParam.mc=0.95;%���ö�������
net.trainParam.min_grad=5e-7;%������С�����ݶ�

%��ʼѵ��
net=train(net,X,T);%%��β���ʹ;��ֻ��ʾѵ�����ߣ���


%��ȡ��������
%[t1,t2,t3,t4,t5,t6,class]=textread('testdata.txt','%f%f%f%f%f%f%f',1000);
%testinput=[t1,t2,t3,t4,t5,t6];
%testinput=testinput';

%����
output1=sim(net,X);

%��ͼ
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
    
%X(1,1)=input('�����һ������');
%X(2,1)=input('����ڶ�������')
%X(3,1)=input('�������������')
%X(4,1)=input('������ĸ�����');
%X(5,1)=input('������������');
%X(6,1)=input('�������������');
%test=sim(net,X);
%test(1,1)

%��S������Ԫ�غ�
S1=sum(S);
S1=S1';
S2=sum(S1);


while(S2>5);
fprintf('�ٴ�ѵ����');
    
%  ����ѵ������
net.trainparam.show = 50 ;%��ʾƵ�ʣ�ѵ��50����ʾһ�Σ�
net.trainparam.epochs = 10000 ;%ѵ������
net.trainparam.goal = 0.00001 ;%ѵ��Ŀ����С���
net.trainParam.lr = 0.001 ;%ѧϰ����
net.trainParam.max_fail =6;%�������ʧ�ܴ���
% ��ʼѵ��
net=train(net,X,T);
output1=sim(net,X);

% ��ͼ
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
% ��ʾѵ��Ȩ�غ���ֵ
net.iw{1,1}
net.lw{2,1}
net.b{1}
net.b{2}

figure(2)
plot(S,'r*');

% ��S������Ԫ�غ�
S1=sum(S);
S1=S1';
S2=sum(S1);
S2
    pause;
end;

fprintf('����Ҫ��');


net.iw{1,1}
net.lw{2,1}
net.b{1}
net.b{2}