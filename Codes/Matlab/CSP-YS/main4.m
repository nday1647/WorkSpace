
clc;clear
n = 9;
% T = zeros(1,n);
% for d= 1:n
%     str_read = ['A0' int2str(int8(d)) 'T'];
%     truerate = preprocess_2(str_read);
%     T(d) = truerate;
% end
% T

% truerate1 = preprocess_1('ZJJ_2_online')

truerate1 = preprocess_2('xkd1')
% truerate2 = preprocess_2('A02T')
% truerate3 = preprocess_2('A03T')

% truerate3 = preprocess_3('ZJJ_1_acquisition')