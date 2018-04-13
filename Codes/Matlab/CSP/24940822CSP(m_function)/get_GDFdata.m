function [x, y, Fs] = get_GDFdata(path, Channel, Type, y_tag)
%提取Type数组类型数据、去NaN值、乱序
[s,h] = sload(path);
%属性获取
Fs=h.EVENT.SampleRate;%采样率

%筛选通道后得到 样本数据data_source
data =s(:, Channel);
%NaN值转化为列平均值
data = NaN2Mean(data);
% %睁眼时的数据
% [num_eyes_open,eyes_open,y_eyes_open] = get_GDFdata(data_source,h,276,2);
% %闭眼时的数据
% [num_eyes_closed,eyes_closed,y_eyes_closed] = get_GDFdata(data_source,h,277,3);
% %动眼时的数据
% [num_eyes_movement,eyes_movement,y_eyes_movement] = get_GDFdata(data_source,h,1072,4);

[~, x, y] = get_data(data, h, Type(1), y_tag(1));
if length(Type) >= 2
    for index = 2:length(Type)
        %提取所有i类的样本
        [~,onset,y_label] = get_data(data, h, Type(index), y_tag(index));
        x = [x onset];
    %     x{i}=onset;
        y = [y y_label];
    %     y{i}=y_label;
    end
end

%乱序
kk = randperm(length(x));
x = x(:, kk);
y = y(:, kk);  

%get_data 按类型获取数据
%输出该类样本个数、样本数据集、标签
function [num,onset,y] = get_data(data_source,h,Type,y_tag)
POS = h.EVENT.POS;%标签位置
TYP = h.EVENT.TYP;%标签类型
% DUR = h.EVENT.DUR;%持续时间
num = sum(([TYP;0] == Type).*([0;TYP] == 768));
onset_POS = POS(logical(([TYP;0] == Type).*([0;TYP] == 768)));%去rejected值
% onset_DUR = DUR(TYP == Type);
onset = cell(1,num);%该类样本的个数
y = zeros(1,num);
for i=1 : num
    onset{i} = data_source(onset_POS(i)+250:onset_POS(i)+1000-1, :);
    y(i) = y_tag;
end
end

%去NaN值
function dataSourse = NaN2Mean(dataSourse)
smean = nanmean(dataSourse);
s1 = isnan(dataSourse);%NaN值所在位置
s2 = zeros(size(dataSourse));
len = size(dataSourse,2);
% for i = 1:len
%     s2(:,i) = smean(i).* s1(:,i);%将NaN赋值为列平均值
% end
dataSourse(s1)=0;
dataSourse = dataSourse + s2;
end

end
%====for CNN=====
% function [num,onset,y] = get_GDFdata(data_source,h,Type,y_tag)
% %输出样本个数、样本数据集、标签
% POS = h.EVENT.POS;%标签位置
% TYP = h.EVENT.TYP;%标签类型
% DUR = h.EVENT.DUR;%持续时间
% num = sum(TYP == Type);
% onset_POS = POS(TYP == Type);
% onset_DUR = DUR(TYP == Type);
% % onset = cell(1,num);%右样本的个数
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
