function predict_y = LDA_test(test_xAfterCSP, test_size, W, y0)
% ��������test_x, cell����
% ===���˲��������data_x��CSP���������õ���������LDA����===
predict_y = [];
for i = 1:test_size
    if test_xAfterCSP(i,:)*W > y0
        predict_y = [predict_y;0];
    else
        predict_y = [predict_y;1];
    end
end
return