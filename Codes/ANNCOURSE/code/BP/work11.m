clear;
clc;
%²úÉú100000*6¾ØÕó
n=1000000;
T=randsrc(1,n,[0,1]);
X=-100+200*rand(n,6);
for i=1:n
    if(T(i)==1)
        X(i,1)=X(i,6);
          X(i,2)=X(i,5);
            X(i,3)=X(i,4);
    end
end
for i=1:n
    if( X(i,1)==X(i,6)&&X(i,2)==X(i,5)&&X(i,3)==X(i,4))
        T(i)=1;
    end
end
X=X';
load filename net;
[net,tr]=train(net,X,T);
figure(1);
plotperform(tr);
output1=sim(net,X);

%×÷Í¼
S=zeros(1,1000000);
output=zeros(1,1000000);
for i=1:100000
    if(output1(i)>=0.5)
        output(i)=1;
    end
    if(output1(i)<0.5) 
        output(i)=0;
    end
    if(output1(i)>0.1&&output1(i)<0.9) 
        output(i)=output1(i);
   end
    if(output(i)~=T(i)) 
        S(i)=1;
    end
end
figure(2)
plot(S,'r*');
S1=sum(S);
S1=S1';
S2=sum(S1);
