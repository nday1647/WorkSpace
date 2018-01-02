function F = csp_train(AfterFilter_x, y, train_size)
% �������Ϊ��������AfterFilter_x ��ǩy ѵ����Ŀtrain_size
% AfterFilter_xΪcell���� ÿ��cell����һ��trial ��Ӧһ����ǩy
% ÿ��cell�ṹΪT��N, T��������, Nͨ����
% ����ͶӰ����F ������f1 f2(DataNum*FeatureNum)

channel_num=size(AfterFilter_x{1},2);
N=3;% ��ȡ��������
for i = 1:train_size
    % R=X'*X/tr(X'*X) Э�������(�Գƾ���)
    R{i}=AfterFilter_x{i}'*AfterFilter_x{i}/trace(AfterFilter_x{i}'*AfterFilter_x{i});
%     R{i}=AfterFilter_x{i}'*AfterFilter_x{i};
end
% ��ʼ��R1��R2
R1=zeros(channel_num);
R2=zeros(channel_num);
countL=0;countR=0;
% �����ݱ�ǩ���࣬�ֱ𸳸�R1,R2, ��1 y=1,��2 y=-1
for i=1:train_size
    if y{i} == 1
        R1 = R1+R{i};% ���
        countL = countL+1;
    else
        R2 = R2+R{i};
        countR = countR+1;
    end
end
% Э�������Ĺ�һ��
% R1=R1/trace(R1);
% R2=R2/trace(R2);
R1=R1/countL;
R2=R2/countR;
R3=R1+R2;
% close all%�ر�����figure����
% figure()����һ������ surf(Z)����ά����ͼ
% figure();surf(R1);figure();surf(R2);figure();surf(R3);
% [V,D]=eig(A)���ؾ���A��ȫ������ֵ���ɵĶԽ���D����������V
[U0,Sigma]=eig(R3);
% ����׻��任����P
P=Sigma^(-0.5)*U0';
% ����P��R1���б任
YL=P*R1*P';
YR=P*R2*P';
% ����ֵ�ֽ�(ͬʱ�Խǻ���
[UL,SigmaL]=eig(YL,YR);
% [UL,SigmaL]=eig(YL);
% [UR,SigmaR]=eig(YR);
% x=diag(v,k)������v��Ԫ����Ϊ����X�ĵ�k���Խ���Ԫ��
% ��k=0ʱ��vΪX�����Խ���
% ��k>0ʱ��vΪ�Ϸ���k���Խ���
% ��k<0ʱ��vΪ�·���k���Խ���
% descend���� [B,I]=sort(A)Ĭ�϶��н������򷵻���������B
% IΪ���ص������Ԫ����ԭ�����е���λ�û���λ�� 22x1
[~,I]=sort(diag(SigmaL), 'descend');
% [~,IR]=sort(diag(SigmaR), 'descend');
% ȡ�����������������UL����������ǰN�ͺ�N�������N��&��СN����
F=UL(:,I([1:N,channel_num-N+1:channel_num]))'*P;
% FL=P'*UL(:,I(1:N));
% FR=P'*UL(:,I(DATA_CHANNEL-N+1:DATA_CHANNEL));
% ԭ�������ݰ���ͶӰ������(�任->�˷�->���->�����任->ת��=>����������
% f1=[];f2=[];
% for i=1:train_size
%     Z = F*AfterFilter_x{i}';% �Ե��ź�ͶӰ��õ�z 6*750
%     feature = log(var(Z,0,2)/sum(var(Z,0,2)))';% �����󷽲�
%     if y{i}==1
%         f1 = [f1;feature];
%     else
%         f2 = [f2;feature];
%     end
% end
return