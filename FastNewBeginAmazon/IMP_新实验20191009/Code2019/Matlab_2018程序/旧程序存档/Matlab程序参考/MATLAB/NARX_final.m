foutPathAll='E:\TEST\Predict\PredictRes\predict1108.txt';
foutAll=fopen(foutPathAll,'w');
fprintf(foutAll,'MSE1 MSE2 MSE3 MAPE1 MAPE2 MAPE3\r\n');

datalist_stress=dir('E:\TEST\Predict\FeaturePre\*.txt');
A=[];
for pos=1:length(datalist_stress)
    finPath=['E:\TEST\Predict\FeaturePre\',datalist_stress(pos).name];
    data = importdata(finPath);
    [s1,s2]=size(data);
    B=A;
    A=[B;data(1:s1-1,:)];
end

a=[25,20,17,15,10];
b=[26,21,23,16,11];
c=[27,22,27,17,12];

a1=[13,14,15,16,17];
b1=[18,19,20,21,22];
c1=[23,24,25,26,27];
        
for iter=1:1:10
    if(iter<=5)
        fprintf(foutAll,'%d %d %d\r\n',a(iter),b(iter),c(iter));
        d1=2:a(iter);
        d1_2=b(iter):c(iter);
        P=A(:,[d1,d1_2]);
        Q=A(:,28:30);
    end
    
    if(iter>5 && iter<=10)
        new = iter-5;
        fprintf(foutAll,'type %d %d %d\r\n',a1(new),b1(new),c1(new));
        d1=2:12;
        P=A(:,[d1,a1(new),b1(new),c1(new)]);
        Q=A(:,28:30);   
    end
    
    X=con2seq(P');
    T=con2seq(Q');
    net = narxnet(1:2,1:2,10);
    [Xs,Xi,Ai,Ts] = preparets(net,X,{},T);
    net = train(net,Xs,Ts,Xi,Ai);
    yp = sim(net,Xs,Xi);
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
            end        
        end
    end

    for k=1:1:3
        MSE(k)=MSE(k)/num2(k);
        fprintf(foutAll,'%.4f ',MSE(k));
    end
    for k=1:1:3
        MAPE(k)=MAPE(k)/num(k);
        fprintf(foutAll,'%.4f ',MAPE(k));
    end
    fprintf(foutAll,'\r\n');
end
fclose(foutAll);
