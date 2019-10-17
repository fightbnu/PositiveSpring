%step1. 生成一组随机数（正态分布）
data=normrnd(0,1,1,500);
%绘制直方图
hist(data,20); 
hold on;

%step2.
[mu,sigma]=normfit(data);%求出概率密度函数参数
[n,x]=hist(data,20);%[n,x]为返回的[每个容器中心位置x，每个容器的元素个数n]
y=normpdf(x,mu,sigma);%求概率密度函数

%step3.
y=y*max(n')/max(y');%处理一下数据，使得密度函数和最高点对齐
plot(x,y,'r-');%绘制概率密度曲线