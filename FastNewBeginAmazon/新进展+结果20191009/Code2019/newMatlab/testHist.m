%step1. ����һ�����������̬�ֲ���
data=normrnd(0,1,1,500);
%����ֱ��ͼ
hist(data,20); 
hold on;

%step2.
[mu,sigma]=normfit(data);%��������ܶȺ�������
[n,x]=hist(data,20);%[n,x]Ϊ���ص�[ÿ����������λ��x��ÿ��������Ԫ�ظ���n]
y=normpdf(x,mu,sigma);%������ܶȺ���

%step3.
y=y*max(n')/max(y');%����һ�����ݣ�ʹ���ܶȺ�������ߵ����
plot(x,y,'r-');%���Ƹ����ܶ�����