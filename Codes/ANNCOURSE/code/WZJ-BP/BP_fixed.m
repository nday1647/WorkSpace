clear all
clc
[I,R]=TrainData(75);
% I_total=textread('example.txt');
% I=I_total(:,1:6);
% R=I_total(:,7);
Wi=rand(6,2);
Wo=rand(2,1);
% Bi=rand(1,2);
% Bo=rand();w
Bi=[0.5 0.5];
Bo=0.5;
mc=7000;
precision=0.005;
speed=0.1;
count=1;
n=6;
m=2;
k=1;

while(count<=mc)
    cc=1;
    while(cc<=75) %75个训练数据是一组
        for j=1:m %计算隐含层输出
            s=0;
            for i=1:n
                s=s+Wi(i,j)*I(cc,i);
            end
            s=s-Bi(j);
            b(j)=1/(1+exp(-s));
        end
        ll=0;
        for j=1:m%计算输出层
            ll=ll+Wo(j)*b(j);
        end
        ll=ll-Bo;
        c=1/(1+exp(-ll));
        errort=(1/2)*((R(cc)-c)^2);%这个地方有点不一样
        errortt(cc)=errort;
        scyiban=(R(cc)-c)*c*(1-c);
        for j=1:m
            e(j)=scyiban*Wo(j)*b(j)*(1-b(j));
        end
        for j=1:m
            Wo(j)=Wo(j)+speed*scyiban*b(j);
        end
        Bo=Bo+speed*scyiban;
        for i=1:n
            for j=1:m
                Wi(i,j)=Wi(i,j)+speed*e(j)*I(cc,i);
            end
        end
         for j=1:m
             Bi(j)=Bi(j)-speed*e(j);
         end
        cc=cc+1;
    end
    
    tmp=0;
    for i=1:75
        tmp=tmp+errortt(i);%*errortt(i);
    end
    tmp=tmp/75;
    %error(count)=sqrt(tmp);
    error(count)=tmp;
%     if(error(count)<precision);
%         break;
%     end
    count=count+1;
end
errortt
count
p=1:count-1;
plot(p,error(p));
            
        
       
     
