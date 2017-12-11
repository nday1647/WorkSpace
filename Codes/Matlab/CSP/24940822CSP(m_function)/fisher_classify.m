function [class,y,y0,y1,y2]=fisher_classify(sample,feature_train)
%FISHER_CLASSIFY
%function:ʹ��Fisher_LDA�����ݽ���ѵ���ͷ���
%syntax:class=FISHER_CLASSIFY(sample,feature_train)
%input--sample:���һ�����ڼ����������������һά������
%     --feature_train����ѵ������
%output--class:���

m1=(mean(feature_train{1}))';
m2=(mean(feature_train{2}))';
j1=size(feature_train{1}',2);
j2=size(feature_train{2}',2);

%������ɢ�Ⱦ���
s1=cov(feature_train{1})*(j1-1);
s2=cov(feature_train{2})*(j2-1);
%��������ɢ�Ⱦ���
sw=s1+s2;
%�����ɢ�Ⱦ���
sb=(m1-m2)*(m1-m2)';
w=inv(sw)*(m1-m2);

%��ѵ�����и������w�ϵ�ͶӰ
y1=w'*feature_train{1}';
y2=w'*feature_train{2}';

%��ѵ�����и���ͶӰ����ľ�ֵ
mean1=mean(y1');
mean2=mean(y2');
%����ֵy0
y0=(j1*mean1+j2*mean2)/(j1+j2);

y=w'*sample';

if y>y0
    class=1;
else
    class=2;
end

end