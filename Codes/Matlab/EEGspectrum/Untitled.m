load GH-171225-acquisition-2.mat;
label = [769,770];
for labelindex = 1:length(label)
    index = find(stims(:,2)==label(labelindex));
    len = size(index,1);
    label_time = stims(index,1);
    pos = [];
    for i = 1:size(label_time,1)
        for j = 1:size(sampleTime,1)
            if sampleTime(j,1) > label_time(i,1)
                pos = [pos; j];
                break
            end
        end
    end
    for i = 1:len
        samples(pos(i, 1), 9) = label(labelindex);
    end
end
save GH-171225-acquisition-2-samples samples
% load competitionA03T.mat;
% trialsize = length(x);
% data = [];
% for i = 1:trialsize
%     x{i}(:,23) = 0;
%     data = [data; x{i}];
%     data(750*(i-1)+1, 23) = y{i};
% end
% save competitionA03T_data data 

