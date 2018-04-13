function [x, y, Fs] = get_GDFdata(path, Channel, Type, y_tag)
%��ȡType�����������ݡ�ȥNaNֵ������
[s,h] = sload(path);
%���Ի�ȡ
Fs=h.EVENT.SampleRate;%������

%ɸѡͨ����õ� ��������data_source
data =s(:, Channel);
%NaNֵת��Ϊ��ƽ��ֵ
data = NaN2Mean(data);
% %����ʱ������
% [num_eyes_open,eyes_open,y_eyes_open] = get_GDFdata(data_source,h,276,2);
% %����ʱ������
% [num_eyes_closed,eyes_closed,y_eyes_closed] = get_GDFdata(data_source,h,277,3);
% %����ʱ������
% [num_eyes_movement,eyes_movement,y_eyes_movement] = get_GDFdata(data_source,h,1072,4);

[~, x, y] = get_data(data, h, Type(1), y_tag(1));
if length(Type) >= 2
    for index = 2:length(Type)
        %��ȡ����i�������
        [~,onset,y_label] = get_data(data, h, Type(index), y_tag(index));
        x = [x onset];
    %     x{i}=onset;
        y = [y y_label];
    %     y{i}=y_label;
    end
end

%����
kk = randperm(length(x));
x = x(:, kk);
y = y(:, kk);  

%get_data �����ͻ�ȡ����
%������������������������ݼ�����ǩ
function [num,onset,y] = get_data(data_source,h,Type,y_tag)
POS = h.EVENT.POS;%��ǩλ��
TYP = h.EVENT.TYP;%��ǩ����
% DUR = h.EVENT.DUR;%����ʱ��
num = sum(([TYP;0] == Type).*([0;TYP] == 768));
onset_POS = POS(logical(([TYP;0] == Type).*([0;TYP] == 768)));%ȥrejectedֵ
% onset_DUR = DUR(TYP == Type);
onset = cell(1,num);%���������ĸ���
y = zeros(1,num);
for i=1 : num
    onset{i} = data_source(onset_POS(i)+250:onset_POS(i)+1000-1, :);
    y(i) = y_tag;
end
end

%ȥNaNֵ
function dataSourse = NaN2Mean(dataSourse)
smean = nanmean(dataSourse);
s1 = isnan(dataSourse);%NaNֵ����λ��
s2 = zeros(size(dataSourse));
len = size(dataSourse,2);
% for i = 1:len
%     s2(:,i) = smean(i).* s1(:,i);%��NaN��ֵΪ��ƽ��ֵ
% end
dataSourse(s1)=0;
dataSourse = dataSourse + s2;
end

end
%====for CNN=====
% function [num,onset,y] = get_GDFdata(data_source,h,Type,y_tag)
% %��������������������ݼ�����ǩ
% POS = h.EVENT.POS;%��ǩλ��
% TYP = h.EVENT.TYP;%��ǩ����
% DUR = h.EVENT.DUR;%����ʱ��
% num = sum(TYP == Type);
% onset_POS = POS(TYP == Type);
% onset_DUR = DUR(TYP == Type);
% % onset = cell(1,num);%�������ĸ���
% % y = cell(1,num);
% y = zeros(4,num);
% for i=1 : num
%     onset(:, :, i) = data_source(onset_POS(i):onset_POS(i)+onset_DUR(i)-1, :);
% %     y{i} = y_tag;
% if(y_tag==1)
%     y(1,i)=1;
% elseif(y_tag==2)
%     y(2,i)=1;
% elseif(y_tag==3)
%     y(3,i)=1;
% elseif(y_tag==4)
%     y(4,i)=1;
% end
% end
