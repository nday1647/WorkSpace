function csp_make(y)
%输入参数为标签
global Fs;%采样频率
global N;%提取特征对数
global DATA_CHANNEL;%通道数
global DATA_LENGTH;%样本长度
global time_start;%开始时间
global time_end;%结束时间
global data_source;%存放原始数据
global data_x;%存放滤波后的数据
global data_y;%存放数据对应标签
global R;%样本的相关系数
global data_size;%样本数量
global data_index;%数据池指针
global F;%CSP所寻找到的投影方向
global w;%LDA权值
global b;%LDA偏移
global filter_a;%滤波系数a
global filter_b;%滤波系数b

%R=X'*X 协方差矩阵(对称矩阵)
R{data_size}=data_x{data_size}(time_start:time_end,:)'*data_x{data_size}(time_start:time_end,:);
%标签赋值
data_y(data_size)=y{1};
if data_size<40
    return;
end


%初始化R1，R2
R1=zeros(DATA_CHANNEL,DATA_CHANNEL);
R2=zeros(DATA_CHANNEL,DATA_CHANNEL);

%按数据标签分类，分别赋给R1,R2，类1 y=1,类2 y=-1
for i=1:data_size
    if data_y(i)>0
        R1=R1+R{i};%求和
    else
        R2=R2+R{i};
    end
end
%协方差矩阵的归一化
R1=R1/trace(R1);
R2=R2/trace(R2);
R3=R1+R2;
close all
%figure()创建一个窗口 surf(Z)绘三维曲面图
% figure();surf(R1);
% figure();surf(R2);
% figure();surf(R3);
%[V,D]=eig(A)返回矩阵A的全部特征值构成的对角阵D和特征向量V
[U0,Sigma]=eig(R3);
%构造白化变换矩阵P
P=Sigma^(-0.5)*U0';
%利用P对R1进行变换
YL=P*R1*P';
%特征值分解
[UL,SigmaL]=eig(YL);
%x=diag(v,k)以向量v的元素作为矩阵X的第k条对角线元素
%当k=0时，v为X的主对角线
%当k>0时，v为上方第k条对角线
%当k<0时，v为下方第k条对角线
%descend降序 [B,I]=sort(A)默认对列进行排序返回排序后矩阵B
%I为返回的排序后元素在原数组中的行位置或列位置
[Y,I]=sort(diag(SigmaL), 'descend');
%取降序排序后前N  ？？？
F=P'*UL(:,I([1:N,DATA_CHANNEL-N+1:DATA_CHANNEL]));
%原样本数据按列投影并分类(变换->乘方->求和->对数变换->转置=>新样本矩阵
f1=[];f2=[];
for i=1:data_size
    if data_y(i)==1
        f1=[f1,log(sum((data_x{i}(time_start:time_end,:)*F).^2))'];
    end
    if data_y(i)==-1
        f2=[f2,log(sum((data_x{i}(time_start:time_end,:)*F).^2))'];
    end
end

%制作LDA分类器
F1=f1';F2=f2';
%mean()求矩阵的均值(各列)
M1=mean(F1,1)';M2=mean(F2,1)';


count1=size(f1,2)-1;count2=size(f2,2)-1;
w=(inv((count1*cov(F1)+count2*cov(F2))/(count1+count2))*(M2-M1))';
b=-w*(M1+M2)/2;
return