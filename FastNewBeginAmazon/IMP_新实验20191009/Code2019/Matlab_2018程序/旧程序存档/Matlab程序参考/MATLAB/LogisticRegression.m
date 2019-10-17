datalist_stress=dir('E:\TEST\Predict\FeaturePre\*.txt');
A=[];
for pos=1:length(datalist_stress)
    finPath=['E:\TEST\Predict\FeaturePre\',datalist_stress(pos).name];
    data = importdata(finPath);
    [s1,s2]=size(data);
    B=A;
    A=[B;data(1:s1-1,:)];
end

M1=A(:,2:27);
M2=A(:,30);

[size1,size2]=size(A);

for i=1:1:size1-1
    M2(i,:)=M2(i+1,:);
end

x=M1(1:size1-1,:);
y=M2(1:size1-1,:);    

model =glmfit(x,y);
p = glmval(model,x, 'logit');

MSE_LR=0;
MAPE=0;
[num,num_2] = size(p);
num3=1;
for i=1:1:num
    MSE_LR = MSE_LR+(p(i)-y(i))^2;
    if(y(i)>0)
        MAPE=MAPE+abs(p(i)-y(i))/y(i);
        num3=num3+1;
    end
end

MSE_LR=MSE_LR/num;
MAPE = MAPE/num3;
