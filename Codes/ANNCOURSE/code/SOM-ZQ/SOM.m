% newsom���� ����som�����纯�� 
% net=newsom(PR,[D1,D2,...],TFCN,DFCN,OLR,OSTEPS,TLR,TND)
% PR:R������Ԫ�ص����ֵ����Сֵ���趨ֵ��R*2ά����
% Di����I���ά����Ĭ��Ϊ[5 8]
% TFCN�����˺�����Ĭ��Ϊhextop
% DFCN:���뺯����Ĭ��Ϊlinkdist
% OLR������׶�ѧϰ���ʣ�Ĭ��Ϊ0.9
% OSTEPS������׶εĲ�����Ĭ��Ϊ1000
% TLR����г�׶ε�ѧϰ���ʣ�Ĭ��Ϊ0.02
% TNS:��г�׶ε�������룬Ĭ��Ϊ1.

% newc�������ڴ���һ��������
% net=newc(PR,S,KLR,CLR)
% S:��Ԫ����Ŀ
% KLR��Kohonenѧϰ�ٶȣ�Ĭ��Ϊ0.01
% CLR��Conscienceѧϰ�ٶȣ�Ĭ��Ϊ0.001
% net:��������ֵ��һ���µľ����㡣

% %�������1000����ά��������Ϊ�������������ֲ� 
% p1 = rand(2,500)+1; 
% p2 = rand(2,500);
% p3 = rands(2,500)+1;
% P = [p1 p2 p3];
% plot(P(1,:),P(2,:),'+r');
% title('��ʼ���������ֲ�'); 
% xlabel('P(1)'); 
% ylabel('P(2)'); 
% %�������磬�õ���ʼȨֵ 
% net=newsom([0 1; 0 1],[5 6]); 
% w1_init=net.iw{1,1};
% %�����ʼȨֵ�ֲ�ͼ 
% figure; 
% plotsom(w1_init,net.layers{1}.distances);
% 
% net.trainParam.epochs=50; 
% net=train(net,P); 
% figure; 
% plotsom(net.iw{1,1},net.layers{1}.distances) 
% 
% %����ѵ���õ����磬ѡ���ض��������������õ������������ 
% % p=[0.5;0.3]; 
% % a=0; 
% % a = sim(net,p) ;
% % ac = vec2ind(a);
% a = sim(net,P);
% ac = vec2ind(a);
% T = rands(2,50)+1;
% y = sim(net,T);
% yc = vec2ind(y);
%plotsomhitsÿ����Ԫ����ʾ�����������������������
%====
% 1.��ʼ��
%    1)����������ʱ�䲽��iter
%    2)������Ȩֵ������ʼֵ,������Ԫ�ؿ�ѡ����(0��1)�ϵ����ֵ,����ѡ������������
%    3)ѧϰ�ʳ�ʼֵ
%    4)����뾶������Ӧ���������϶������Ԫ,�������ƽ���һ��
% 2.������ʤ��Ԫ;ŷ�����뺯�����
% 3.Ȩֵ���£�
%        ��ʤ�ڵ������Χ����Ԫ���ϵ�m���ڵ����Ȩֵ��j=1:m��    
%            wj(t+1)=wj(t)+learnfun(t)*neighborfun(t)*(x-wj);
% 4.����ѧϰ�ʣ����������� 
%        neighborfun(t)=neighbor0*exp(-dij/t1);   t1=iter/log(neighbor0)
%         learnfun(t)=learn0*exp(-t/t2);     t2=iter
% 5.������ӳ�䲻�ٷ������Ա仯ʱ��ﵽ�������ѵ������ʱ�˳�,����ת���2��
x=[1 1 1 0 1;
    0 1 1 1 1;
    0 0 1 0 1;
    0 0 0 0 1];
x_label = ['X1','X2','X3','X4','X5'];
% net=newsom([0 1; 0 1; 0 1; 0 1],[5 5],'hextop','linkdist',0.5,1000,0.04,2); 
% net=train(net,x); 
[data_row,data_clown]=size(x);
m = 5;n = 5;%����֯ӳ������m*n
w = rand(m*n, data_clown);%Ȩֵ�����ʼ��
learn0 = 0.5;
learn_rate = learn0;%ѧϰ�ʳ�ʼ��
learn_para=1000;%ѧϰ�ʲ���
iter =200;%���õ�������
%��Ԫλ��
[I,J] = ind2sub([m, n], 1:m*n);
neighbor0 =2;
neighbor_redius = neighbor0;%�����ʼ��
neighbor_para = 1000/log(neighbor_redius);%�������

%��������
for t=1:iter 
    %  ���������
    for j=1:data_row  
        %��ȡ������ֵ
        data_x = x(j,:); 
        %�ҵ���ʤ��Ԫ
        [win_row, win_som_index]=min(dist(data_x,w'));  
        %��ʤ��Ԫ������λ��
        [win_som_row,win_som_cloumn] =  ind2sub([m, n],win_som_index);
        win_som=[win_som_row,win_som_cloumn];
        %����������Ԫ�ͻ�ʤ��Ԫ�ľ���,������
        %distance_som = sum(( ([I( : ), J( : )] - repmat(win_som, som_sum,1)) .^2) ,2);
        distance_som = exp( sum(( ([I( : ), J( : )] - repmat(win_som, m*n,1)) .^2) ,2)/(-2*neighbor_redius*neighbor_redius)) ;
        %Ȩֵ����
        for i = 1:m*n
           % if distance_som(i)<neighbor_redius*neighbor_redius 
            w(i,:) = w(i,:) + learn_rate.*distance_som(i).*( data_x - w(i,:));
        end
    end

    %����ѧϰ��
    learn_rate = learn0 * exp(-t/learn_para);   
    %��������뾶
    neighbor_redius = neighbor0*exp(-t/neighbor_para);  
end
%data��������Ԫ��ӳ��
%��Ԫ����som_num�洢ͼ����
som_num=cell(1,size(w,1));
for i=1:size(w,1)
    som_num{1,i}=[];
end
%ÿ����Ԫ�ڵ��Ӧ��data�������
for num=1:data_row
    [som_row,clown]= min(sum(( (w - repmat(x(num,:), m*n,1)) .^2) ,2));
    som_num{1,clown}= [som_num{1,clown},num];    
end
