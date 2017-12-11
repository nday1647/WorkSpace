function [ truerate_ave ] = preprocess_2( data )
%ԭʼ����+��ͨ�˲���+CSP+LDA
%   �˴���ʾ��ϸ˵��
load(data);
X = X_DATA_POSTPRE;%ԭʼ�ź�����
Y = Y_DATA_POSTPRE;%������Ӧ�ı�ǩ
left = find(Y==0);%��������λ��
right = find(Y==1);%��������λ��

% %����������Ƿ�����Чֵ
% bad_sample = 0;
% for i =1: length(X)
%     empty = isnan(X{i});
% %     X{i}(empty) = 0;
%     if sum(sum(empty)) ~= 0 
%         bad_sample = i;
%         bad_ch = find(sum(empty));
%     end
% end
% % if bad_sample ~= 0
% %    X{bad_sample}(:,bad_ch) = [];
% % end

%% Ԥ����1����ͨ�˲���Ƶ��8-14HZ
X_DATA_POSTPRE1=cell(1,1);
filtwts = firls(2,[0 15 30 40]/128,[0 1 1 0]);%�����˲���������8-14Hz�ɷֵ��ź�
for i=1:length(X)
%     X{1,i} = X{1,i}(1:300,:);
    for j=1:size(X{i},2)
      X_DATA_POSTPRE1{1,i}(:,j)=filtfilt(filtwts,1,X{1,i}(:,j));%��ÿһ�����˲�
    end
end
X = X_DATA_POSTPRE1;

%% ���ռ�ģʽ CSP
R=X;%��ʼ��Э�������
for i=1:length(X)%����ÿ��������Э�������
    R{i} = X{i}*X{i}' / trace(X{i}*X{i}');
end

R1 = R(left);%����������Э�������
R2 = R(right);%����������Э�������

% ������֤
k=3;%���ý�����֤������
indices = crossvalind('kfold',min(length(R1),length(R2)),k);%������֤�����������k��ʾk�ۣ�����ѵ�����������ֳ�k�顣
truerate = zeros(1,k);%��������۵���ȷ��
for Fold = 1:k
    test = (indices == Fold);%�߼��жϣ�ÿ��ѭ��ѡȡһ��fold��Ϊ���Լ�
    train = ~test; %ȡtest�Ĳ�����Ϊѵ��������ʣ�µ�5��fold��ע�������test��train��Ϊ�߼�ֵ,��ζ�������������һ���õ�
    
    % ��������
    x_train_L = R1(train');  %��ѵ����
    x_train_R = R2(train');%��ѵ����
%     x_test_L = R1(test'); %����Լ�
%     x_test_R = R2(test');%�Ҳ��Լ�
    
%% ����ƽ��Э�������
R1_ave = 0; R2_ave = 0;
for i=1:length(x_train_L)
    R1_ave = R1_ave + x_train_L{i};
end
for i=1:length(x_train_R)
    R2_ave = R2_ave + x_train_R{i};
end
R1_ave = R1_ave/length(x_train_L);%������ƽ��Э�������
R2_ave = R2_ave/length(x_train_R);%������ƽ��Э�������

R = R1_ave +R2_ave;%���Э�������
[U,E] = eig(R);%�������ֽ⣺UΪR������������EΪR������ֵ�ĶԽǾ���
P = E^(-1/2) * U';%����׻��任����
S1 = P * R1_ave * P';%�׻��任R1_ave
S2 = P * R2_ave * P';%�׻��任R2_ave

[U1,E1] = eig(S1);%�������ֽ�S1
[U2,E2] = eig(S2);%�������ֽ�S2

m=2;%ȷ��ѡȡ������������m���˲���
%ȡE1�����m������ֵ��Ӧ����������V1�������1�ռ��˲���SF1��
[Y1,I1] = sort(diag(E1),'descend');
V1 = U1(:,I1(1:m));
SF1 = V1' *P;
%ȡE2�����m������ֵ��Ӧ����������V2�������2�ռ��˲���SF2��
[Y2,I2] = sort(diag(E2),'descend');
V2 = U2(:,I2(1:m));
SF2 = V2' *P;

%ԭʼ�ź������ֱ��˲��õ���������ź�
Z1 = X;
for i=1:length(X)
    Z1{i} = SF1 * X{i};
end
Z2 = X;
for i=1:length(X)
    Z2{i} = SF2 * X{i};
end
%% ������ȡ
f1 = zeros(1,length(Z1));%���1������
f2 = zeros(1,length(Z2));%���2������
for i=1:length(Z1)
    f1(i) = log(var(Z1{i}) / (var(Z1{i})+var(Z2{i})));%logΪ��f1��f2���ӽ���̬�ֲ�
    f2(i) = log(var(Z2{i}) / (var(Z1{i})+var(Z2{i})));
end

feature = [f1;f2];%��ά��������
f_L = feature(:,left);%��������
f_R = feature(:,right);%��������

Train_L = f_L(:, train');%ȡǰT_l������������Ϊѵ����
Train_R = f_R(:, train');%ȡǰT_l������������Ϊѵ����
Test_L = f_L(:, test');%ȡ��T_l������������Ϊѵ����
Test_R = f_R(:,test');%ȡ��T_l������������Ϊѵ����

%% �����б���� LDA
mean_L = mean(Train_L,2);%��һ�������
mean_R = mean(Train_R,2);%�ڶ��������

s1 = (Train_L - repmat(mean_L,1,length(Train_L))) * (Train_L - repmat(mean_L,1,length(Train_L)))' ;%��һ������ھ�
s2 = (Train_R - repmat(mean_R,1,length(Train_R))) * (Train_R - repmat(mean_R,1,length(Train_R)))' ;%�ڶ�������ھ�
Sw = s1 +s2;%
w = inv(Sw) * (mean_L - mean_R);%w=Sw^(-1) *(mean1 - mean2)

t_L = mean_L' * w;%ѵ��������1���ĵ�ӳ���
t_R = mean_R' * w;%ѵ��������2���ĵ�ӳ���
p_L = (Test_L' * w - t_L) < (Test_L' * w - t_R);%����Լ���ӳ��㵽ѵ��������1���ĵ�ӳ���ľ���<�䵽ѵ��������2���ĵ�ӳ���ľ��룬˵��Ԥ����Ϊ��1���󣩡�
p_R = abs(Test_R' * w - t_L) > (Test_R' * w - t_R);%�Ҳ��Լ���ӳ��㵽ѵ��������1���ĵ�ӳ���ľ���>�䵽ѵ��������2���ĵ�ӳ���ľ��룬˵��Ԥ����Ϊ��2���ң���

truerate(Fold) = (sum(p_L==1) + sum(p_R==1)) / (length(p_L) + length(p_R));
end
truerate_ave = sum(truerate)/length(truerate);
return

