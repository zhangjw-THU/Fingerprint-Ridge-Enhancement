%% 参数
%分成了71个小块
clear
close all;
w=8;%方块大小
fignum=1;

%% 读文件
OriginalImage = imread('FTIR.bmp');
OriginalImage = double(OriginalImage);
figure(fignum),imshow(OriginalImage./255);%显示原图
fignum = fignum+1;
[high,wide] = size(OriginalImage);

%% 归一化
NormalizeImg = Normalize(OriginalImage);

%% 调整大小
%ImgV1 = im2double(NormalizeImg);%使用规则化以后的图像
ImgV1 = im2double(OriginalImage);%使用原图
ImgV1 = imresize(ImgV1,[499,499],'bicubic');

%% 调整到0-1
ImgV1 = ImgV1./255;%max(ImgV1(:));
figure(fignum),imshow(ImgV1);
ImgV1 = ImgV1-mean(ImgV1(:));%%为了提取傅里叶变换，使得均值为0
fignum=fignum+1;
ImgV1Pad = padarray(ImgV1,[12,12]);%填充，为了求32*32的傅里叶变换

%% 分块：相邻两块有一个重叠；大小8*8，共71*71块
Blocks = cell(71,71);%原块：8*8
BlocksPad = cell(71,71);%扩展块：32*32

for i=1:71
    for j=1:71
        Blocks{i,j}=ImgV1(1+(i-1)*7:8+(i-1)*7 , 1+(j-1)*7:8+(j-1)*7);
        BlocksPad{i,j}=ImgV1Pad(1+(i-1)*7:32+(i-1)*7 , 1+(j-1)*7:32+7*(j-1));
    end
end

%% 求每一块的方向和频率
BlocksDFT = cell(71,71);%内一块的fft
BlocksDFTAbs = cell(71,71);%fft的幅值

Theta = zeros(71,71);%存储每一块像素块的方向角
Frequency = zeros(71,71);%求每一块的频率

BackFlag = ones(71,71);%根据幅值大小，存储是否提取到频率：0便是没有提取到
Amplitude = zeros(71,71);%频率

for i=1:71
    for j = 1:71
        BlocksDFT{i,j} = fftshift(fft2(BlocksPad{i,j}));
        BlocksDFTAbs{i,j} = abs(BlocksDFT{i,j}); 
        [x,y] = sort(BlocksDFTAbs{i,j}(:),'descend');%对幅度谱求最大值，降序排序
        for k=1:10
            [x1,y1] = ind2sub(size(BlocksPad{i,j}),y(k));
            [x2,y2] = ind2sub(size(BlocksPad{i,j}),y(k+1));
            if(BlocksDFTAbs{i,j}(x1,y1)==BlocksDFTAbs{i,j}(x2,y2)&&((x1+x2)/2==17&&(y1+y2)/2==17))
               Theta(i,j) = atan((x1-x2)/(y1-y2))+pi/2;
               Amplitude(i,j) = sqrt(((x1-x2)/2)^2+((y1-y2)/2)^2);
               Frequency(i,j) = sqrt(((x1-x2)/2)^2+((y1-y2)/2)^2)/32;
               if((Amplitude(i,j)>=4))%%如果是高频，则是噪声，角度设为0；这个限度是需要调整的
                    Amplitude(i,j) = 0;%即使有相同的点，距离太大，说明不是指纹
                    Frequency(i,j) = -1;%高频（非指纹）频率标记为-1
                    Theta(i,j)=0;%非指纹角度标位0
               end
               break;%找到就跳出
            end
        end
    end
end

%% 空域方向图滤波
figure(fignum),ShowOriImg(Theta);%滤波之前
fignum=fignum+1;
Theta = OrientationFilter(Theta);
figure(fignum),ShowOriImg(Theta)%滤波之后
fignum=fignum+1;

%% 空域频域图滤波，先插值，在滤波
figure(fignum),imshow(Frequency./max(max(Frequency)));
fignum=fignum+1;
Frequency=FrequencyFilter(Frequency);%内容包括插值和滤波
figure(fignum),imshow(Frequency./max(max(Frequency)));
fignum=fignum+1;

%% 对每一个像素块，求一个滤波器
GaborF = cell(71,71);%存储71*71个滤波器
w=11;%gabor滤波器大小
for i=1:71
    for j=1:71
        angle = pi/2-Theta(i,j);
        frq = Frequency(i,j);
        if(Frequency(i,j)<=0)
            GaborF{i,j}=zeros(w);%%如果频率值为0或者负数，择说明此块非指纹区，直接变黑
            %GaborF{i,j}=ones(w)./(w*w);
        else
            GaborF{i,j} = GaborFilter(angle,frq);
        end
    end
end

%% 使用Gobar滤波器对图像进行滤波%%%%%%%%%%%%%%%%%%%%%%%%
[m,n] = size(ImgV1);%图像大小
enImgV1 = zeros(m-2,n-2);
ww =5;%滤波器大小为11，左右个5
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

%enImgV1 = enImgV1+mean(enImgV1(:));%之前减了平均值，现在加上

%% 显示滤波之后的指纹
%原图
figure(fignum),imshow(enImgV1)
fignum = fignum+1;

% %直方图均衡
% H  =histeq(enImgV1);
% figure(fignum),imshow(H);
% fignum = fignum+1;

%直方图调整
%enImgV1 = enImgV1 - min(enImgV1(:));
IPA1 = imadjust(enImgV1./max(enImgV1(:)),[0,0.02],[0,1]);
figure(fignum),imshow(IPA1);
fignum = fignum+1;

%% 还原到原图大小显示
OEnImg = imresize(IPA1,[high,wide],'bicubic');
figure(fignum),
subplot(1,2,1),imshow(OriginalImage./255);
subplot(1,2,2),imshow(OEnImg);
fignum = fignum+1;