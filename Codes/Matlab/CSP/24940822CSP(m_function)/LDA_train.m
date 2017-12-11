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
%W�������ֵ��Ӧ����������
%f1 ��һ������Num*Feature
%f2 �ڶ�������

%��һ��������������ֵ����
m1=mean(f1);%��һ��������ֵ
m2=mean(f2);%�ڶ���������ֵ
m=mean([f1;f2]);%��������ֵ
n1=size(f1,1);%��һ��������
n2=size(f2,1);%�ڶ���������

%�ڶ���������������ɢ�Ⱦ���Sw
% ���һ��������ɢ�о���s1
s1=0;
for i=1:n1
    s1=s1+(f1(i,:)-m1)'*(f1(i,:)-m1);
end
% ��ڶ���������ɢ�о���s2
s2=0;
for i=1:n2
    s2=s2+(f2(i,:)-m2)'*(f2(i,:)-m2);
end
Sw=(n1*s1+n2*s2)/(n1+n2);
%�����������������ɢ�Ⱦ���Sb
Sb=(n1*(m-m1)'*(m-m1)+n2*(m-m2)'*(m-m2))/(n1+n2);
%���Ĳ������������ֵ����������
%[V,D]=eig(inv(Sw)*Sb);%��������V������ֵD
A = repmat(0.1,[1,size(Sw,1)]);
B = diag(A);
[V,D]=eig(inv(Sw + B)*Sb);
[a,b]=max(max(D));
W=V(:,b);%�������ֵ��Ӧ����������

c1 = mean(f1*W);
c2 = mean(f2*W);
%===============
% %������ɢ�Ⱦ���
% s1=cov(f1)*(n1-1);
% s2=cov(f2)*(n2-1);
% %��������ɢ�Ⱦ���
% sw=s1+s2;
%===============
% %�����ɢ�Ⱦ���
% sb=(m1-m2)*(m1-m2)';
% W=inv(sw)*(m1-m2)';
% %��ѵ�����и������w�ϵ�ͶӰ
% y1=W'*f1';
% y2=W'*f2';
% 
% %��ѵ�����и���ͶӰ����ľ�ֵ
% c1=mean(y1');
% c2=mean(y2');
%===============

centers = [c1; c2];
y0 = (n1*c1+n2*c2)/(n1+n2);%��ֵ
end