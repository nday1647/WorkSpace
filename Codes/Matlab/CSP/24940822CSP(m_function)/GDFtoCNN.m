clc;clear;

%读取数据
[s,h] = sload('D:\MyFiles\EEGProject\BCICompetitionIV\BCICIV_2a_gdf\A08T.gdf');
data_source = s(:, 1:22);
%提取所有左的样本
[num_left,onset_left,y_left] = get_GDFdata(data_source,h,769,1);
%所有右的样本
[num_right,onset_right,y_right] = get_GDFdata(data_source,h,770,2);
%双脚的样本
[num_foot,onset_foot,y_foot] = get_GDFdata(data_source,h,771,3);
%舌头的样本
[num_tongue,onset_tongue,y_tongue] = get_GDFdata(data_source,h,772,4);
%cat(3,A,B):A,B为三维矩阵，在第三维上合并
train_x = cat(3,onset_left(:,:,1:60),onset_right(:,:,1:60),onset_foot(:,:,1:60),onset_tongue(:,:,1:60));
train_y = [y_left(:,1:60) y_right(:,1:60) y_foot(:,1:60) y_tongue(:,1:60)];
test_x = cat(3,onset_left(:,:,61:72),onset_right(:,:,61:72),onset_foot(:,:,61:72),onset_tongue(:,:,61:72));
test_y = [y_left(:,61:72) y_right(:,61:72) y_foot(:,61:72) y_tongue(:,61:72)];
save GDF_MI2a train_x train_y test_x test_y;