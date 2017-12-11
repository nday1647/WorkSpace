function [W, centers, y0] = LDA_train(train_xAfterCSP,train_y)

f1=[];f2=[];
for i=1:train_size
    feature = train_xAfterCSP{i};
    if train_y{i}==1
        f1 = [f1;feature];
    else
        f2 = [f2;feature];
    end
end
%W最大特征值对应的特征向量
%f1 第一类样本Num*Feature
%f2 第二类样本

%第一步：计算样本均值向量
m1=mean(f1);%第一类样本均值
m2=mean(f2);%第二类样本均值
m=mean([f1;f2]);%总样本均值
n1=size(f1,1);%第一类样本数
n2=size(f2,1);%第二类样本数

%第二步：计算类内离散度矩阵Sw
% 求第一类样本的散列矩阵s1
s1=0;
for i=1:n1
    s1=s1+(f1(i,:)-m1)'*(f1(i,:)-m1);
end
% 求第二类样本的散列矩阵s2
s2=0;
for i=1:n2
    s2=s2+(f2(i,:)-m2)'*(f2(i,:)-m2);
end
Sw=(n1*s1+n2*s2)/(n1+n2);
%第三步：计算类间离散度矩阵Sb
Sb=(n1*(m-m1)'*(m-m1)+n2*(m-m2)'*(m-m2))/(n1+n2);
%第四步：求最大特征值和特征向量
%[V,D]=eig(inv(Sw)*Sb);%特征向量V，特征值D
A = repmat(0.1,[1,size(Sw,1)]);
B = diag(A);
[V,D]=eig(inv(Sw + B)*Sb);
[a,b]=max(max(D));
W=V(:,b);%最大特征值对应的特征向量

c1 = mean(f1*W);
c2 = mean(f2*W);
%===============
% %类内离散度矩阵
% s1=cov(f1)*(n1-1);
% s2=cov(f2)*(n2-1);
% %总类内离散度矩阵
% sw=s1+s2;
%===============
% %类间离散度矩阵
% sb=(m1-m2)*(m1-m2)';
% W=inv(sw)*(m1-m2)';
% %求训练集中各类别在w上的投影
% y1=W'*f1';
% y2=W'*f2';
% 
% %求训练集中各类投影过后的均值
% c1=mean(y1');
% c2=mean(y2');
%===============

centers = [c1; c2];
y0 = (n1*c1+n2*c2)/(n1+n2);%阈值
end