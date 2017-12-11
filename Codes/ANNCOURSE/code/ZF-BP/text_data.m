function re=text_data(number)
max_i=number;
b=zeros(max_i,6);
for i=1:max_i
 x=rand(1,3);
 y=fliplr(x);
 a=[x,y]; 
 b(i,:)=a; 
end
c=ones(max_i,1);
d=[b,c];
b=zeros(max_i,6);
for i=1:max_i
 x=rand(1,3);
 y=fliplr(x);
 a=[x,y]; 
 b(i,:)=a; 
end
c=ones(max_i,1);
d=[b,c];
re=d;