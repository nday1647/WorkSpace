%生成200个最大值为1000的样本数据，其中中心对称样本占比0.5
[inputX, dsrOp] = creatSampleData(200,100,0.5);
%a = sample_data1(1000);
%归一化
%[inputNormal,minI,maxI] = premnmx(inputX);
%创建前向BP网络
%trainlm比traingdx快许多 且能将performance降到10^-5
BPNet = newff(inputX, dsrOp, 2, { 'tansig' 'purelin' } , 'trainlm' );
%设置训练参数
BPNet.iw=iw;
BPNet.b = b;
BPNet.trainparam.show = 50;%显示中间结果的周期
BPNet.trainparam.epochs = 20000;%最大迭代次数
BPNet.trainparam.goal = 0.000001;%目标误差
BPNet.trainParam.lr = 0.01;%学习率
BPNet.trainParam.mc=0.95;%设置动量因子
BPNet.trainParam.min_grad=5e-7;%设置最小性能梯度
%BPNet.trainParam.max_fail = 6;
BPNet.divideFcn = '';
BPNet = train(BPNet, inputX, dsrOp);
%=====测试======
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
legend('预测结果', '期望目标');

%======预测正确率=======
rightNum = 0;
for i = 1:testNum
    if((testOp(i)==0&&result(i)<0.5)||(testOp(i)==1&&result(i)>0.5))
        rightNum=rightNum+1;
    end
end
rate = rightNum/testNum;
title(['分类正确率：',num2str(rate)]);