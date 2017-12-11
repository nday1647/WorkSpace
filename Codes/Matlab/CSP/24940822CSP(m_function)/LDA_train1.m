function [W,centers]=LDA_train1(train_xAfterCSP,train_y)
% Ipuut:    n*d matrix,each row is a sample;
% Target:   n*1 matrix,each is the class label 
% W:        d*(k-1) matrix,to project samples to (k-1) dimention
% centers:  k*(k-1) matrix,the means of each after projection 


% 初始化
[n,dim]=size(train_xAfterCSP);
ClassLabel=unique(train_y);
k=length(ClassLabel);

nGroup=NaN(k,1);            % group count
GroupMean=NaN(k,dim);       % the mean of each value
W=NaN(k-1,dim);             % the final transfer matrix
centers=zeros(k,k-1);       % the centers of mean after projection
SB=zeros(dim,dim);          % 类间离散度矩阵
SW=zeros(dim,dim);          % 类内离散度矩阵

% 计算类内离散度矩阵和类间离散度矩阵
for i=1:k    
    group=(train_y==ClassLabel(i));
    nGroup(i)=sum(double(group));
    GroupMean(i,:)=mean(train_xAfterCSP(group,:));
    tmp=zeros(dim,dim);
    for j=1:n
        if group(j)==1
            t=train_xAfterCSP(j,:)-GroupMean(i,:);
            tmp=tmp+t'*t;
        end
    end
    SW=SW+tmp;
end
m=mean(GroupMean);    
for i=1:k
    tmp=GroupMean(i,:)-m;
    SB=SB+nGroup(i)*tmp'*tmp;
end

% % W 变换矩阵由v的最大的K-1个特征值所对应的特征向量构成
% v=inv(SW)*SB;
% [evec,eval]=eig(v);
% [x,d]=cdf2rdf(evec,eval);
% W=v(:,1:k-1);

% 通过SVD也可以求得
% 对K=(Hb,Hw)'进行奇异值分解可以转换为对Ht进行奇异值分解.P再通过K,U,sigmak求出来
% [P,sigmak,U]=svd(K,'econ');=>[U,sigmak,V]=svd(Ht,0);
[U,sigmak,V]=svd(SW,0);
t=rank(SW);
R=sigmak(1:t,1:t);
P=SB'*U(:,1:t)*inv(R);
[Q,sigmaa,W]=svd(P(1:k,1:t));
Y(:,1:t)=U(:,1:t)*inv(R)*W;
W=Y(:,1:k-1);

% 计算投影后的中心值
for i=1:k
    group=(train_y==ClassLabel(i));
    centers(i,:)=mean(train_xAfterCSP(group,:)*W);
end

