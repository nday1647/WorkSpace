function PlotSOM(x_test,test_result,x_label)
%输入参数：样本、分类结果和样本标签
%输出：神经元分类结果
m=5;n=5;
[I,J] = ind2sub([m, n], 1:m*n);
figure;plot(I,J,'o','MarkerSize',30);
axis([0 6 0 6]);
hold on;
for i=1:25
    if(test_result(i) == 0)
        text(I(i),J(i),num2str(test_result(i)))
    end
    if(test_result(i)~=0)
        t = text(I(i),J(i),x_label(test_result(i)));
        set(t,'color','red');
    end
end
hold off;
end


