%% ��������
PSFPath='D:\Myfiles\WorkSpace\Codes\Matlab\EEGspectrum\';%����������·��
load([PSFPath,'\label'])%��������
index=find(label==769);

windowlegth=100;
pretime=10;  %binǰ10��ʱ��
postime=20;  %bin��50��ʱ��
total_channel=8;
%PSFch=cat(3);
for Channel=1:total_channel       %Ҫ�������׵�ͨ��
    load([PSFPath,'PSF',num2str(Channel),'.mat']); %���ع���������
    cuttime=round(index/windowlegth)';          % 600Ϊһ�����Ĵ�С
    cutdata=zeros(513,(pretime+postime+1));    %Ϊʲô+1������513Ҫ����nfft��С��ȷ����һ��Ϊnfft/2+1
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
