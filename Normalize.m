function NormalizeImg =Normalize(Img)
[high,wide]=size(Img);
%%均值和方差限制
m0 = 100;
v0 = 100;

MeanImg = mean(Img(:));
VarImg = var(Img(:));

GMid = find(Img>MeanImg);
LMid = find(Img<MeanImg);

NormalizeImg(GMid) = m0 + sqrt((v0 * (Img(GMid)-MeanImg).^2)/VarImg);
NormalizeImg(LMid) = m0 - sqrt((v0 * (Img(LMid)-MeanImg).^2)/VarImg);
NormalizeImg = reshape(NormalizeImg,[high,wide]);
end
