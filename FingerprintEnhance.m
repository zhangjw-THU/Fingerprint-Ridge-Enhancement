%% ����
%�ֳ���71��С��
clear
close all;
w=8;%�����С
fignum=1;

%% ���ļ�
OriginalImage = imread('FTIR.bmp');
OriginalImage = double(OriginalImage);
figure(fignum),imshow(OriginalImage./255);%��ʾԭͼ
fignum = fignum+1;
[high,wide] = size(OriginalImage);

%% ��һ��
NormalizeImg = Normalize(OriginalImage);

%% ������С
%ImgV1 = im2double(NormalizeImg);%ʹ�ù����Ժ��ͼ��
ImgV1 = im2double(OriginalImage);%ʹ��ԭͼ
ImgV1 = imresize(ImgV1,[499,499],'bicubic');

%% ������0-1
ImgV1 = ImgV1./255;%max(ImgV1(:));
figure(fignum),imshow(ImgV1);
ImgV1 = ImgV1-mean(ImgV1(:));%%Ϊ����ȡ����Ҷ�任��ʹ�þ�ֵΪ0
fignum=fignum+1;
ImgV1Pad = padarray(ImgV1,[12,12]);%��䣬Ϊ����32*32�ĸ���Ҷ�任

%% �ֿ飺����������һ���ص�����С8*8����71*71��
Blocks = cell(71,71);%ԭ�飺8*8
BlocksPad = cell(71,71);%��չ�飺32*32

for i=1:71
    for j=1:71
        Blocks{i,j}=ImgV1(1+(i-1)*7:8+(i-1)*7 , 1+(j-1)*7:8+(j-1)*7);
        BlocksPad{i,j}=ImgV1Pad(1+(i-1)*7:32+(i-1)*7 , 1+(j-1)*7:32+7*(j-1));
    end
end

%% ��ÿһ��ķ����Ƶ��
BlocksDFT = cell(71,71);%��һ���fft
BlocksDFTAbs = cell(71,71);%fft�ķ�ֵ

Theta = zeros(71,71);%�洢ÿһ�����ؿ�ķ����
Frequency = zeros(71,71);%��ÿһ���Ƶ��

BackFlag = ones(71,71);%���ݷ�ֵ��С���洢�Ƿ���ȡ��Ƶ�ʣ�0����û����ȡ��
Amplitude = zeros(71,71);%Ƶ��

for i=1:71
    for j = 1:71
        BlocksDFT{i,j} = fftshift(fft2(BlocksPad{i,j}));
        BlocksDFTAbs{i,j} = abs(BlocksDFT{i,j}); 
        [x,y] = sort(BlocksDFTAbs{i,j}(:),'descend');%�Է����������ֵ����������
        for k=1:10
            [x1,y1] = ind2sub(size(BlocksPad{i,j}),y(k));
            [x2,y2] = ind2sub(size(BlocksPad{i,j}),y(k+1));
            if(BlocksDFTAbs{i,j}(x1,y1)==BlocksDFTAbs{i,j}(x2,y2)&&((x1+x2)/2==17&&(y1+y2)/2==17))
               Theta(i,j) = atan((x1-x2)/(y1-y2))+pi/2;
               Amplitude(i,j) = sqrt(((x1-x2)/2)^2+((y1-y2)/2)^2);
               Frequency(i,j) = sqrt(((x1-x2)/2)^2+((y1-y2)/2)^2)/32;
               if((Amplitude(i,j)>=4))%%����Ǹ�Ƶ�������������Ƕ���Ϊ0������޶�����Ҫ������
                    Amplitude(i,j) = 0;%��ʹ����ͬ�ĵ㣬����̫��˵������ָ��
                    Frequency(i,j) = -1;%��Ƶ����ָ�ƣ�Ƶ�ʱ��Ϊ-1
                    Theta(i,j)=0;%��ָ�ƽǶȱ�λ0
               end
               break;%�ҵ�������
            end
        end
    end
end

%% ������ͼ�˲�
figure(fignum),ShowOriImg(Theta);%�˲�֮ǰ
fignum=fignum+1;
Theta = OrientationFilter(Theta);
figure(fignum),ShowOriImg(Theta)%�˲�֮��
fignum=fignum+1;

%% ����Ƶ��ͼ�˲����Ȳ�ֵ�����˲�
figure(fignum),imshow(Frequency./max(max(Frequency)));
fignum=fignum+1;
Frequency=FrequencyFilter(Frequency);%���ݰ�����ֵ���˲�
figure(fignum),imshow(Frequency./max(max(Frequency)));
fignum=fignum+1;

%% ��ÿһ�����ؿ飬��һ���˲���
GaborF = cell(71,71);%�洢71*71���˲���
w=11;%gabor�˲�����С
for i=1:71
    for j=1:71
        angle = pi/2-Theta(i,j);
        frq = Frequency(i,j);
        if(Frequency(i,j)<=0)
            GaborF{i,j}=zeros(w);%%���Ƶ��ֵΪ0���߸�������˵���˿��ָ������ֱ�ӱ��
            %GaborF{i,j}=ones(w)./(w*w);
        else
            GaborF{i,j} = GaborFilter(angle,frq);
        end
    end
end

%% ʹ��Gobar�˲�����ͼ������˲�%%%%%%%%%%%%%%%%%%%%%%%%
[m,n] = size(ImgV1);%ͼ���С
enImgV1 = zeros(m-2,n-2);
ww =5;%�˲�����СΪ11�����Ҹ�5
for i=1:m-2
    for j=1:n-2
        if(Frequency(floor((i+6)/7),floor((j+6)/7))>0)
        s = ImgV1Pad(i+13-ww:i+13+ww,j+13-ww:j+13+ww).*GaborF{floor((i+6)/7),floor((j+6)/7)};
        enImgV1(i,j) = sum(sum(s));
        else
            enImgV1(i,j)=255;
        end
    end
end

%enImgV1 = enImgV1+mean(enImgV1(:));%֮ǰ����ƽ��ֵ�����ڼ���

%% ��ʾ�˲�֮���ָ��
%ԭͼ
figure(fignum),imshow(enImgV1)
fignum = fignum+1;

% %ֱ��ͼ����
% H  =histeq(enImgV1);
% figure(fignum),imshow(H);
% fignum = fignum+1;

%ֱ��ͼ����
%enImgV1 = enImgV1 - min(enImgV1(:));
IPA1 = imadjust(enImgV1./max(enImgV1(:)),[0,0.02],[0,1]);
figure(fignum),imshow(IPA1);
fignum = fignum+1;

%% ��ԭ��ԭͼ��С��ʾ
OEnImg = imresize(IPA1,[high,wide],'bicubic');
figure(fignum),
subplot(1,2,1),imshow(OriginalImage./255);
subplot(1,2,2),imshow(OEnImg);
fignum = fignum+1;