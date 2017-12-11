function [class,y,y0,y1,y2]=fisher_classify(sample,feature_train)
%FISHER_CLASSIFY
%function:使用Fisher_LDA对数据进行训练和分类
%syntax:class=FISHER_CLASSIFY(sample,feature_train)
%input--sample:存放一个窗内肌电的特征向量，是一维行向量
%     --feature_train：待训练数据
%output--class:类别

m1=(mean(feature_train{1}))';
m2=(mean(feature_train{2}))';
j1=size(feature_train{1}',2);
j2=size(feature_train{2}',2);

%类内离散度矩阵
s1=cov(feature_train{1})*(j1-1);
s2=cov(feature_train{2})*(j2-1);
%总类内离散度矩阵
sw=s1+s2;
%类间离散度矩阵
sb=(m1-m2)*(m1-m2)';
w=inv(sw)*(m1-m2);

%求训练集中各类别在w上的投影
y1=w'*feature_train{1}';
y2=w'*feature_train{2}';

%求训练集中各类投影过后的均值
mean1=mean(y1');
mean2=mean(y2');
%求阈值y0
y0=(j1*mean1+j2*mean2)/(j1+j2);

y=w'*sample';

if y>y0
    class=1;
else
    class=2;
end

end