% %test1-basic
% [X,T] = simpleseries_dataset;
% net = narxnet(1:2,1:2,10);
% [Xs,Xi,Ai,Ts] = preparets(net,X,{},T);
% net = train(net,Xs,Ts,Xi,Ai);
% Y = net(Xs,Xi,Ai);
% perf1 = perform(net,Ts,Y);
% %test1-1: +closeloop
% netc = closeloop(net);
% [Xs,Xi,Ai,Ts] = preparets(netc,X,{},T);
% y = netc(Xs,Xi,Ai);
% perf2 = perform(netc,Ts,y);

%test2-multi-variable-succeed
datalist_stress=dir('E:\TEST\Predict\FeaturePre\*.txt');
A=[];
for pos=1:length(datalist_stress)
    finPath=['E:\TEST\Predict\FeaturePre\',datalist_stress(pos).name];
    data = importdata(finPath);
    [s1,s2]=size(data);
    B=A;
    A=[B;data(1:s1-1,:)];
end

P=A(:,28:31);
Q=A(:,28:30);
X=con2seq(P');
T=con2seq(Q');
net = narxnet(1:2,1:2,10);
[Xs,Xi,Ai,Ts] = preparets(net,X,{},T);
net = train(net,Xs,Ts,Xi,Ai);
%Y = net(Xs,Xi,Ai);
yp = sim(net,Xs,Xi);
%perf1 = perform(net,Ts,Y);
e = cell2mat(yp)-cell2mat(Ts);
plot(e(1,:));


MSE=[0,0,0];
MAPE=[0,0,0];
num=[1,1,1];
num2=[1,1,1];
[n_1,n_2] = size(e);
t_Ts = cell2mat(Ts);
t_yp = cell2mat(yp);
for k=1:1:3
    for i=1:1:n_2
        if(e(k,i)>5 || e(k,i)<-5)
            continue;
        end
         
        MSE(k)=MSE(k)+(t_Ts(k,i)-t_yp(k,i))^2;
        num2(k)=num2(k)+1;
        
        if(t_Ts(k,i)>0)
            MAPE(k)=MAPE(k)+abs(t_Ts(k,i)-t_yp(k,i))/t_Ts(k,i);
            num(k)=num(k)+1;
        else
            if(t_yp(k,i)>0)
                MAPE(k)=MAPE(k)+abs(t_Ts(k,i)-t_yp(k,i))/t_yp(k,i);
                num(k)=num(k)+1;
            end
        end        
    end
end

for k=1:1:3
    MAPE(k)=MAPE(k)/num(k);
    MSE(k)=MSE(k)/num2(k);
end

%test3---succeed
% load magdata
% y = con2seq(y);
% u = con2seq(u);
% d1 = [1:2];
% d2 = [1:2];
% narx_net = narxnet(d1,d2,10);
% narx_net.divideFcn = '';
% narx_net.trainParam.min_grad = 1e-10;
% [p,Pi,Ai,t] = preparets(narx_net,u,{},y);
% narx_net = train(narx_net,p,t,Pi);
% yp = sim(narx_net,p,Pi);
% e = cell2mat(yp)-cell2mat(t);
% plot(e);
%-------

