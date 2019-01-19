function Gabor = GaborFilter(theta,frq)
w =11;
%%�������ģ���Ϊ11��������latent������С�ģ���Ӧ��Сһ��
%%���������sigma�ı��С����֮��ָ��Ҫ��С�ڴ�ͳ����Ƭ��Ӧ�����������һ��

ww=5;

[x,y]=meshgrid(-ww:ww);

kx=0.5;
ky=0.5;
sigma = 5;
% sigmax=fix(kx/frq);%%���Ǹ��ݲ�ͬ��Ƶ�ʣ����в�ͬ��sigmaֵ
% sigmay=fix(ky/frq);
sigmax = sigma;
sigmay = sigma;
Gabor = exp(-(x.^2/sigmax^2 + y.^2/sigmay^2)/2).*cos(2*pi*(frq)*x);

Gabor = imrotate(Gabor, theta*180/pi, 'bilinear','crop'); 
end
