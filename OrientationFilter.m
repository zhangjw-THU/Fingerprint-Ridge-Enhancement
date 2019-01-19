function OriImgFlt = OrientationFilter(Theta)

phx = cos(2*Theta);
phy = sin(2*Theta);

%%�������ģ���5*5��С���˲���
h = fspecial('gaussian',5,4);%��˹ƽ���˲�
%h=ones(5)./25;%��ֵ�˲�

phxflt = imfilter(phx,h,'conv');
phyflt = imfilter(phy,h,'conv');

OriImgFlt=0.5*atan2(phyflt,phxflt);

end