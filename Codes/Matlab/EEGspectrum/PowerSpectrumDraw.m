%% 画功率谱
PSFPath='D:\Myfiles\WorkSpace\Codes\Matlab\EEGspectrum\';%功率谱数据路径
load([PSFPath,'\label'])%手势数据
index=find(label==769);

windowlegth=100;
pretime=10;  %bin前10个时刻
postime=20;  %bin后50个时刻
total_channel=8;
%PSFch=cat(3);
for Channel=1:total_channel       %要画功率谱的通道
    load([PSFPath,'PSF',num2str(Channel),'.mat']); %加载功率谱数据
    cuttime=round(index/windowlegth)';          % 600为一个窗的大小
    cutdata=zeros(513,(pretime+postime+1));    %为什么+1？？，513要根据nfft大小来确定，一般为nfft/2+1
    for loop=1:size(cuttime,2)
        if (cuttime(1,loop)>pretime)
            cutdata=cutdata+PowerSpe(:,int32(cuttime(1,loop)-pretime):int32(cuttime(1,loop)+postime));
        end
    end
    
%     PSFch(:,:,Channel)=cutdata;
    
    imagesc(zscore(cutdata(1:100,:),1,2));
    title(['ch=',num2str(Channel)]);
%     title('x1');
    saveas(gcf,strcat('CH',num2str(Channel),'.jpg'));
    axis xy;
    line([pretime+1,pretime+1],[0,513])
    hold on;
    pause;
    clf;
end

% for i=1:4
%     subplot(2,2,i);
%     imagesc(zscore(PSFch(1:300,:,i),1,2));
%     title(['Channel ',num2str(i)]);
%     axis xy;
%     line([pretime+1,pretime+1],[0,513])
%     hold on;
% end
