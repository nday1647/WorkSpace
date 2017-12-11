function re=text_data1(number)
max_i=number;
b=zeros(max_i,6);
for i=1:max_i
 a=rand(1,6) ;
 b(i,:)=a; 
end
   y=zeros(max_i,1);
   c=[b,y];
re=c;