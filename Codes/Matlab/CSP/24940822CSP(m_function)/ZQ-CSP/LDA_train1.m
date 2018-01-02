function [W,centers]=LDA_train1(train_xAfterCSP,train_y)
% Ipuut:    n*d matrix,each row is a sample;
% Target:   n*1 matrix,each is the class label 
% W:        d*(k-1) matrix,to project samples to (k-1) dimention
% centers:  k*(k-1) matrix,the means of each after projection 


% ��ʼ��
[n,dim]=size(train_xAfterCSP);
ClassLabel=unique(train_y);
k=length(ClassLabel);

nGroup=NaN(k,1);            % group count
GroupMean=NaN(k,dim);       % the mean of each value
W=NaN(k-1,dim);             % the final transfer matrix
centers=zeros(k,k-1);       % the centers of mean after projection
SB=zeros(dim,dim);          % �����ɢ�Ⱦ���
SW=zeros(dim,dim);          % ������ɢ�Ⱦ���

% ����������ɢ�Ⱦ���������ɢ�Ⱦ���
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

% % W �任������v������K-1������ֵ����Ӧ��������������
% v=inv(SW)*SB;
% [evec,eval]=eig(v);
% [x,d]=cdf2rdf(evec,eval);
% W=v(:,1:k-1);

% ͨ��SVDҲ�������
% ��K=(Hb,Hw)'��������ֵ�ֽ����ת��Ϊ��Ht��������ֵ�ֽ�.P��ͨ��K,U,sigmak�����
% [P,sigmak,U]=svd(K,'econ');=>[U,sigmak,V]=svd(Ht,0);
[U,sigmak,V]=svd(SW,0);
t=rank(SW);
R=sigmak(1:t,1:t);
P=SB'*U(:,1:t)*inv(R);
[Q,sigmaa,W]=svd(P(1:k,1:t));
Y(:,1:t)=U(:,1:t)*inv(R)*W;
W=Y(:,1:k-1);

% ����ͶӰ�������ֵ
for i=1:k
    group=(train_y==ClassLabel(i));
    centers(i,:)=mean(train_xAfterCSP(group,:)*W);
end

