%%对频率图先插值补全，再滤波
function fF = FrequencyFilter(Frequency)

h = fspecial('gaussian',7);
fF = Frequency;
FrequencyPad = padarray(Frequency,[3,3]);
w = 71;

validFrq = 20;%频率图补全重要的参数，周围的有效值大于这个数，就要给他补全latent：35；FTIR:4
cycleslimit = 10;%%之多循环10次，此值也可以调
invalidFrq = sum(sum(Frequency<=0));%%无效频率的块数

cycles=0;%%累加标志

while(((invalidFrq>0)&&cycles<cycleslimit)||cycles<cycleslimit)
  for i=1:w
    for j=1:w
        Blocks = FrequencyPad(i:i+6,j:j+6);%%取一个快7*7的领域
        msk = (Blocks>0);
        if(sum(sum(msk))>=validFrq)
            Blocks = Blocks.*msk;
            fF(i,j)=sum(sum(Blocks.*h))/sum(sum(h.*msk));
        else
            fF(i,j)=-1;
        end
    end
  end  
  Frequency=fF;
  invalidFrq=sum(sum(Frequency<=0));
  cycles = cycles+1;
end
%频率场的滤波，用高斯滤波

f=fspecial('gaussian',7,3);%%低通滤波，根据论文；大小为7*7
fF=imfilter(fF,f,'replicate');

end