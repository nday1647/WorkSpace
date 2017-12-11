function net = cnnsetup(net, x, y)
% cnnsetup���ڳ�ʼ��CNN�Ĳ���������net
% ���ø����mapsize��С 
% assert(~isOctave() || compare_versions(OCTAVE_VERSION, '3.8.0', '>='), ['Octave 3.8.0 or greater is required for CNNs as there is a bug in convolution in previous versions. See http://savannah.gnu.org/bugs/?39314. Your version is ' myOctaveVersion]);
numInputmaps = 1;
mapsize = size(squeeze(x(:, :, 1)));%[28, 28];һ����������x(:, :, 1)��һ��ѵ������,squeeze ��ȥsizeΪ1��ά��
% ����ͨ������net����ṹ������㹹��CNN����
% ��ʼ�������ľ���ˡ�bias 
for l = 1 : numel(net.layers)   %  layer=5
    %s:��������
    if strcmp(net.layers{l}.type, 's')
        %������ͼ�Ĵ�Сmapsize��28*28��Ϊ14*14��net.layers{l}.scale = 2��
        %mapsize = mapsize / net.layers{l}.scale;
        mapsize(1) = mapsize(1) / net.layers{l}.scale(1)
        mapsize(2) = mapsize(2) / net.layers{l}.scale(2);
        
        assert(all(floor(mapsize)==mapsize), ['Layer ' num2str(l) ' size must be integer. Actual: ' num2str(mapsize)]);
        for j = 1 : numInputmaps % һ�������������������map
            % biasͳһ��ʼ��Ϊ0
            net.layers{l}.b{j} = 0;
        end
    end
    %c:�����
    if strcmp(net.layers{l}.type, 'c')
        %�õ�������featuremap��size�������fm�Ĵ�С Ϊ ��һ���С - ����˴�С + 1������Ϊ1�������
        mapsize = mapsize - [net.layers{l}.kernelsize(1),net.layers{l}.kernelsize(2)] + 1;
        %fan_out�ò���������ӵ����� = ������� * �����size = 6*(5*5)��12*(5*5)
        fan_out = net.layers{l}.outputmaps * net.layers{l}.kernelsize(1)*net.layers{l}.kernelsize(2);
        %����˳�ʼ����1����Ϊ1*6������ˣ�2����һ����6*12=72������ˡ�
        for j = 1 : net.layers{l}.outputmaps  %  ÿ�������
            %���������
            % fan_in = �����һ�����map����Ӧ�����о���ˣ�������Ȩֵ������ = 1*25,6*25
            fan_in = numInputmaps * net.layers{l}.kernelsize(1)*net.layers{l}.kernelsize(2);
            for i = 1 : numInputmaps  %  input map
                %����˵ĳ�ʼ������һ��5*5�ľ���ˣ�ֵΪ-1~1֮��������
                %�ٳ���sqrt(6/(7*25))��sqrt(6/(18*25))
                net.layers{l}.k{i}{j} = (rand(net.layers{l}.kernelsize(1),net.layers{l}.kernelsize(2)) - 0.5) * 2 * sqrt(6 / (fan_in + fan_out));
            end
            % biasͳһ��ʼ��Ϊ0��ÿ�����mapֻ��һ��bias������ÿ��filterһ��bias
            net.layers{l}.b{j} = 0;
        end
        numInputmaps = net.layers{l}.outputmaps;
    end
end
% β�������֪���Ĳ������ã�ȫ���Ӳ�)
% 'onum' is the number of labels, that's why it is calculated using size(y, 1). If you have 20 labels so the output of the network will be 20 neurons.
% 'fvnum' is the number of output neurons at the last layer, the layer just before the output layer.
% 'ffb' is the biases of the output neurons.
% 'ffW' is the weights between the last layer and the output neurons. Note that the last layer is fully connected to the output layer, that's why the size of the weights is (onum * fvnum)
fvnum = prod(mapsize) * numInputmaps;%prod��������������Ԫ�صĳ˻���fvnum = 4*4*12 = 192����ȫ���Ӳ����������
onum = size(y, 1);%����ڵ������
net.ffb = zeros(onum, 1);
net.ffW = (rand(onum, fvnum) - 0.5) * 2 * sqrt(6 / (onum + fvnum));
end
