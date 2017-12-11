function csp_make(y)
%�������Ϊ��ǩ
global Fs;%����Ƶ��
global N;%��ȡ��������
global DATA_CHANNEL;%ͨ����
global DATA_LENGTH;%��������
global time_start;%��ʼʱ��
global time_end;%����ʱ��
global data_source;%���ԭʼ����
global data_x;%����˲��������
global data_y;%������ݶ�Ӧ��ǩ
global R;%���������ϵ��
global data_size;%��������
global data_index;%���ݳ�ָ��
global F;%CSP��Ѱ�ҵ���ͶӰ����
global w;%LDAȨֵ
global b;%LDAƫ��
global filter_a;%�˲�ϵ��a
global filter_b;%�˲�ϵ��b

%R=X'*X Э�������(�Գƾ���)
R{data_size}=data_x{data_size}(time_start:time_end,:)'*data_x{data_size}(time_start:time_end,:);
%��ǩ��ֵ
data_y(data_size)=y{1};
if data_size<40
    return;
end


%��ʼ��R1��R2
R1=zeros(DATA_CHANNEL,DATA_CHANNEL);
R2=zeros(DATA_CHANNEL,DATA_CHANNEL);

%�����ݱ�ǩ���࣬�ֱ𸳸�R1,R2����1 y=1,��2 y=-1
for i=1:data_size
    if data_y(i)>0
        R1=R1+R{i};%���
    else
        R2=R2+R{i};
    end
end
%Э�������Ĺ�һ��
R1=R1/trace(R1);
R2=R2/trace(R2);
R3=R1+R2;
close all
%figure()����һ������ surf(Z)����ά����ͼ
% figure();surf(R1);
% figure();surf(R2);
% figure();surf(R3);
%[V,D]=eig(A)���ؾ���A��ȫ������ֵ���ɵĶԽ���D����������V
[U0,Sigma]=eig(R3);
%����׻��任����P
P=Sigma^(-0.5)*U0';
%����P��R1���б任
YL=P*R1*P';
%����ֵ�ֽ�
[UL,SigmaL]=eig(YL);
%x=diag(v,k)������v��Ԫ����Ϊ����X�ĵ�k���Խ���Ԫ��
%��k=0ʱ��vΪX�����Խ���
%��k>0ʱ��vΪ�Ϸ���k���Խ���
%��k<0ʱ��vΪ�·���k���Խ���
%descend���� [B,I]=sort(A)Ĭ�϶��н������򷵻���������B
%IΪ���ص������Ԫ����ԭ�����е���λ�û���λ��
[Y,I]=sort(diag(SigmaL), 'descend');
%ȡ���������ǰN  ������
F=P'*UL(:,I([1:N,DATA_CHANNEL-N+1:DATA_CHANNEL]));
%ԭ�������ݰ���ͶӰ������(�任->�˷�->���->�����任->ת��=>����������
f1=[];f2=[];
for i=1:data_size
    if data_y(i)==1
        f1=[f1,log(sum((data_x{i}(time_start:time_end,:)*F).^2))'];
    end
    if data_y(i)==-1
        f2=[f2,log(sum((data_x{i}(time_start:time_end,:)*F).^2))'];
    end
end

%����LDA������
F1=f1';F2=f2';
%mean()�����ľ�ֵ(����)
M1=mean(F1,1)';M2=mean(F2,1)';


count1=size(f1,2)-1;count2=size(f2,2)-1;
w=(inv((count1*cov(F1)+count2*cov(F2))/(count1+count2))*(M2-M1))';
b=-w*(M1+M2)/2;
return