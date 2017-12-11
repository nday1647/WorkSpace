function [num,onset,y] = get_DATdata(data_source,duration,data_label)
%输出样本个数、样本数据集、标签
count=length(data_label);
j=1;
a=[];
y={};
for i=1 :count 
    if  strcmp(data_label(i).type,'StimulusCode')        
            a(j)=data_label(i).latency;
            y{j}=3-2*data_label(i).position;
            j=j+1;           
    end
        
end  
num =length(a);
onset = cell(1,num);%右样本的个数
for i=1 : num
    onset{i} = data_source(a(i):a(i)+duration-1, :);%%一次持续多久
end

end