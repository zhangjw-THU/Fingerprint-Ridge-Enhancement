function Gabor = GaborFilter(theta,frq)
w =11;
%%根据论文，设为11；但是像latent那样大小的，就应该小一点
%%或者下面的sigma改变大小，总之，指纹要是小于传统的照片，应该在这里调整一下

ww=5;

[x,y]=meshgrid(-ww:ww);

kx=0.5;
ky=0.5;
sigma = 5;
% sigmax=fix(kx/frq);%%这是根据不同的频率，会有不同的sigma值
% sigmay=fix(ky/frq);
sigmax = sigma;
sigmay = sigma;
Gabor = exp(-(x.^2/sigmax^2 + y.^2/sigmay^2)/2).*cos(2*pi*(frq)*x);

Gabor = imrotate(Gabor, theta*180/pi, 'bilinear','crop'); 
end
