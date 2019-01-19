function OriImgFlt = OrientationFilter(Theta)

phx = cos(2*Theta);
phy = sin(2*Theta);

%%根据论文，是5*5大小的滤波器
h = fspecial('gaussian',5,4);%高斯平滑滤波
%h=ones(5)./25;%均值滤波

phxflt = imfilter(phx,h,'conv');
phyflt = imfilter(phy,h,'conv');

OriImgFlt=0.5*atan2(phyflt,phxflt);

end