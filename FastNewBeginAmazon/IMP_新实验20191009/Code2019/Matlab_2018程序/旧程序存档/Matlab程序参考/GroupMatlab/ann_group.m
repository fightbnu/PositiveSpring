%foutPathAll='E:\TEST\GROUP\RES\124_ANNres.txt';
%foutAll=fopen(foutPathAll,'w');
     
    %1、数据的输入；
		finPath='E:\TEST\GROUP\toNorm\norTrainStudy_all.txt';

        data = importdata(finPath);
        [m,n] = size(data);

        p=data(:,1:9);      
        t=data(:,10);     
        for i=1:1:m-1
            t(i,:)=t(i+1,:);
        end
        p1=p(1:m-1,:);
        t1=t(1:m-1,:);
        P=p1';%real全集!!!!矩阵翻转
        T=t1';%real全集!!!!矩阵翻转

        [h,v]=size(P);
        P1=P(:,1:0.8*v);%training
        T1=T(:,1:0.8*v);
        [h1,v1]=size(P1);
        P2=P(:,v1+1:v);%testing
        T2=T(:,v1+1:v);

        [pn,minp,maxp,tn,mint,maxt]=premnmx(P1,T1);
      %  dx= zeros(1,2);
      %  for i=1:1:1
      %      dx(i,1)=-1;
      %      dx(i,2)=1;
      %  end

        %ANN
       % net=newff(dx,[3,dim(DIM),3],{'tansig','tansig','purelin'},'traingdx');
		net=newff(P1,T1,5,{'tansig','tansig','purelin'},'traingdx');
        net.trainParam.show=200;                      %1000轮回显示一次结果
        net.trainParam.Lr=0.05;                        %学习速率为0.05
        net.trainParam.epochs=10000;                   %最大训练轮回为50000；
        net.trainParam.goal=0.65*10^(-3);              %均方误差
        net=train(net,pn,tn);%!!!!曾经有BIGBUG!!!要用归一化之后的值!!!

        pnewn=tramnmx(P2,minp,maxp);
        anewn=sim(net,pnewn);
        anew=postmnmx(anewn,mint,maxt);

        r1=anew(1,:);

        %5、预测数据和原始数据进行对比；
        x=1:v-v1;
        figure(1);
        subplot(3,1,1);plot(x,r1,'r-o',x,T2(1,:),'b--+');
        legend('Predicted stress (acc)','Observed stress');
        xlabel('day');ylabel('value');
       % title(['Predicting stress value(accumulated) using ANN',datalist_stress(pos).name]);

       % MSE=mse(r1,T2(1,:));%error
        mape=0;
        MSE = 0;
        [x1,x2] = size(r1);
        for i=1:1:x2
            if T2(1,i)>0
             %   if r1(1,i)<T2(1,i)
                    mape = mape + abs(r1(1,i)-T2(1,i))/T2(1,i);
             %   else
             %       mape = mape + abs(r1(1,i)-T2(1,i))/r1(1,i);
             %   end
                MSE = MSE + (r1(1,i)-T2(1,i))^2;
            end
        end
        
        if x2>0
            mape = mape/x2;
            MSE = MSE/x2;
            RMSE = sqrt(MSE);
        end
%fprintf(foutAll,'%.4f %0.4f\r\n',MSE,mape);
%fclose(foutAll);
