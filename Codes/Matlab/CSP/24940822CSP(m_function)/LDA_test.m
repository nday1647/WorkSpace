function predict_y = LDA_test(test_xAfterCSP, test_size, W, y0)
% 测试样本test_x, cell类型
% ===对滤波后的数据data_x做CSP处理，并将得到的特征做LDA分类===
predict_y = [];
for i = 1:test_size
    if test_xAfterCSP(i,:)*W > y0
        predict_y = [predict_y;0];
    else
        predict_y = [predict_y;1];
    end
end
return