
% 				preResult<<dayNumTotal<<" "<<fre<<" "<<numStress<<" "<<stressRatio<<					
% 					" "<<valStress-beforeAcc<<" "<<maxStress-beforeMax<<" "<<avgStress-beforeAvg<<
% 					" "<<devAcc<<" "<<devMax<<" "<<devAvg<<
% 					" "<<pressNumA<<" "<<pressNumB<<
% 					" "<<stressorDay[1]<<" "<<stressorDay[2]<<" "<<stressorDay[3]<<" "<<stressorDay[4]<<" "<<stressorDay[5]<<
% 					" "<<valStress<<" "<<maxStress<<" "<<avgStress<<endl;//1+19 = 20
 
%统计输出
dim=[5,6,7,8,9,10,11,12,13];

foutPathAll='E:\TEST\Predict\PredictRes\124_predict.txt';
foutAll=fopen(foutPathAll,'w');
    
for DIM=1:1:9
    foutPath=['E:\TEST\Predict\PredictRes\res',num2str(dim(DIM)),'.txt'];
    disp(dim(DIM));
    disp(foutPath);
    fout=fopen(foutPath,'w');
    
    avgMSE1=0;
    avgMSE2=0;
    avgMSE3=0;

    %1、数据的输入；
    datalist_stress=dir('E:\TEST\Predict\FeaturePre\*.txt');

    for pos=1:length(datalist_stress)
        finPath=['E:\TEST\Predict\FeaturePre\',datalist_stress(pos).name];
        disp(finPath);
        data = importdata(finPath);
        [m,n] = size(data);

        p=data(:,28:30);      
        t=data(:,28:30);     
        for i=1:1:m-1
            t(i,:)=t(i+1,:);
        end
        p1=p(1:m-1,:);
        t1=t(1:m-1,:);
        P=p1';%real全集
        T=t1';%real全集

        [h,v]=size(P);
        P1=P(:,1:0.8*v);%training
        T1=T(:,1:0.8*v);
        [h1,v1]=size(P1);
        P2=P(:,v1+1:v);%testing
        T2=T(:,v1+1:v);

        [pn,minp,maxp,tn,mint,maxt]=premnmx(P1,T1);
        dx= zeros(3,2);
        for i=1:1:3
            dx(i,1)=-1;
            dx(i,2)=1;
        end

        %ANN
        net=newff(dx,[3,dim(DIM),3],{'tansig','tansig','purelin'},'traingdx');
        net.trainParam.show=200;                      %1000轮回显示一次结果
        net.trainParam.Lr=0.05;                        %学习速率为0.05
        net.trainParam.epochs=10000;                   %最大训练轮回为50000；
        net.trainParam.goal=0.65*10^(-3);              %均方误差
        net=train(net,pn,tn);%!!!!曾经有BIGBUG!!!要用归一化之后的值!!!

        pnewn=tramnmx(P2,minp,maxp);
        anewn=sim(net,pnewn);
        anew=postmnmx(anewn,mint,maxt);

        r1=anew(1,:);
        r2=anew(2,:);
        r3=anew(3,:);

        %5、预测数据和原始数据进行对比；
        x=1:v-v1;
        figure(1);
        subplot(3,1,1);plot(x,r1,'r-o',x,T2(1,:),'b--+');
        legend('Predicted stress (acc)','Observed stress');
        xlabel('day');ylabel('value');
        title(['Predicting stress value(accumulated) using ANN',datalist_stress(pos).name]);

        subplot(3,1,2);plot(x,r2,'r-o',x,T2(2,:),'b--+'); %max最佳
        legend('Predicted stress (max)','Observed stress');
        xlabel('day');ylabel('value');
        title('Predicting stress value(maximal) using ANN');

        subplot(3,1,3);plot(x,r3,'r-o',x,T2(3,:),'b--+');
        legend('Predicted stress (avg)','Observed stress');
        xlabel('day');ylabel('value');
        title('Predicting stress value(average) using ANN');

        e1=mse(r1,T2(1,:));%error
        e2=mse(r2,T2(2,:));
        e3=mse(r3,T2(3,:));
        
        avgMSE1=avgMSE1+e1;
        avgMSE2=avgMSE2+e2;
        avgMSE3=avgMSE3+e3;

        fprintf(fout,'%.4f %.4f %.4f %s\r\n',e1,e2,e3,datalist_stress(pos).name);
    end
    
    fprintf(foutAll,'%.4f %.4f %.4f Hidden=%d\r\n',avgMSE1/124,avgMSE2/124,avgMSE3/124,dim(DIM));
    fclose(fout);
disp(DIM);
end
pause;
fclose(foutAll);
