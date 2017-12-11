function [I,result]=TrainData(n)
right_num=fix(fix(n/2)+fix(n/2)*rand);
array=zeros(n,1);
for k=1:n
    for m=1:6
        
I(k,m)=fix(10*rand);
    end
end

for i=1:right_num
    num=fix(1+(n-1)*rand);
    array(num,1)=1;
    I(num,6)=I(num,1);
    I(num,5)=I(num,2);
    I(num,4)=I(num,3);
end

for j=1:n
    %a=logical(I(i,6)==I(i,1));
    %b=logical(I(i,5)==I(i,2));
    %c=logical(I(i,4)==I(i,3));
    if((I(j,6)==I(j,1))&&(I(j,5)==I(j,2))&&(I(j,4)==I(j,3)))
        array(j,1)=1;
    end
end
result=array;
end


        
