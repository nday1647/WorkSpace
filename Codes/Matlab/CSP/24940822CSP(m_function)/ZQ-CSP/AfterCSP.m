function xAfterCSP = AfterCSP(x, F)
% ����x, cell����
% ===���˲��������data_x��CSP����, ����ͶӰ����F���пռ��˲�===
xAfterCSP = [];
for i = 1:length(x)
    Z = F*x{i}';% �Ե��ź�ͶӰ��õ�Z(6��750)
    feature = log(var(Z,0,2)/sum(var(Z,0,2)))';
    xAfterCSP = [xAfterCSP;feature];
end
return

