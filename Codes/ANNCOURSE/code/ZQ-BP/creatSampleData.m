function [inputX, dsrOp]=creatSampleData(num, xMax, rate)
%输入参数
%num 创建样本数据的个数
%xMax 样本的最大值,
%rate 中心对称样本所占比例
%输出参数
%inputX 输入样本 每列为一个样本数据 6行
%dsrOp 期望输出 行向量
inputX = randi(xMax, 6, num);
dsrOp = zeros(1, num);
centralSymNum = round(rate*num);
%randint(M,N,[A B]),产生M行N列范围在A~B之间的整数 
set = randperm(num, centralSymNum);
for i =1:centralSymNum
    dsrOp(set(i)) = 1;
    inputX(4,set(i))=inputX(3,set(i));
    inputX(5,set(i))=inputX(2,set(i));
    inputX(6,set(i))=inputX(1,set(i));
end
end