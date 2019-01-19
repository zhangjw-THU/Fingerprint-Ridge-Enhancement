%%œ‘ æ∑ΩœÚÕº

function ShowOriImg(OriImg)

[m,n] = size(OriImg);
x = 0:n-1;
y = 0:m-1;
quiver(x,y,cos(OriImg),sin(OriImg)); 
axis([0 n 0 m]),axis image, axis ij;
end
