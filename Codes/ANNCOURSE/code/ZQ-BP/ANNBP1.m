%����200�����ֵΪ1000���������ݣ��������ĶԳ�����ռ��0.5
[inputX, dsrOp] = creatSampleData(200,100,0.5);
%a = sample_data1(1000);
%��һ��
%[inputNormal,minI,maxI] = premnmx(inputX);
%����ǰ��BP����
%trainlm��traingdx����� ���ܽ�performance����10^-5
BPNet = newff(inputX, dsrOp, 2, { 'tansig' 'purelin' } , 'trainlm' );
%����ѵ������
BPNet.iw=iw;
BPNet.b = b;
BPNet.trainparam.show = 50;%��ʾ�м���������
BPNet.trainparam.epochs = 20000;%����������
BPNet.trainparam.goal = 0.000001;%Ŀ�����
BPNet.trainParam.lr = 0.01;%ѧϰ��
BPNet.trainParam.mc=0.95;%���ö�������
BPNet.trainParam.min_grad=5e-7;%������С�����ݶ�
%BPNet.trainParam.max_fail = 6;
BPNet.divideFcn = '';
BPNet = train(BPNet, inputX, dsrOp);
%=====����======
testNum = 10000;
[testX, testOp]= creatSampleData(testNum,100,0.4);
%test=premnmx(testX);
result=sim(BPNet,testX);
% load filename net;
% [net,~]=train(net,X,T);
% result=sim(net,X);
plot(1:testNum,result,'b*');
hold on;
plot(1:testNum,testOp,'ro');
legend('Ԥ����', '����Ŀ��');

%======Ԥ����ȷ��=======
rightNum = 0;
for i = 1:testNum
    if((testOp(i)==0&&result(i)<0.5)||(testOp(i)==1&&result(i)>0.5))
        rightNum=rightNum+1;
    end
end
rate = rightNum/testNum;
title(['������ȷ�ʣ�',num2str(rate)]);