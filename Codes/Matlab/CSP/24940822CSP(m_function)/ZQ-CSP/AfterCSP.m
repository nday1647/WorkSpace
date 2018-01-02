function xAfterCSP = AfterCSP(x, F)
% 样本x, cell类型
% ===对滤波后的数据data_x做CSP处理, 经过投影矩阵F进行空间滤波===
xAfterCSP = [];
for i = 1:length(x)
    Z = F*x{i}';% 脑电信号投影后得到Z(6×750)
    feature = log(var(Z,0,2)/sum(var(Z,0,2)))';
    xAfterCSP = [xAfterCSP;feature];
end
return

