function [inputX, dsrOp]=creatSampleData(num, xMax, rate)
%�������
%num �����������ݵĸ���
%xMax ���������ֵ,
%rate ���ĶԳ�������ռ����
%�������
%inputX �������� ÿ��Ϊһ���������� 6��
%dsrOp ������� ������
inputX = randi(xMax, 6, num);
dsrOp = zeros(1, num);
centralSymNum = round(rate*num);
%randint(M,N,[A B]),����M��N�з�Χ��A~B֮������� 
set = randperm(num, centralSymNum);
for i =1:centralSymNum
    dsrOp(set(i)) = 1;
    inputX(4,set(i))=inputX(3,set(i));
    inputX(5,set(i))=inputX(2,set(i));
    inputX(6,set(i))=inputX(1,set(i));
end
end