
	finPath='E:\TEST\GROUP\toNorm\norTrainStudy_all.txt';
   
    dim = 10;
    data = importdata(finPath);
    [m,n] = size(data);
    p=data(:,1:dim);      
    t=data(:,dim);     
    for i=1:1:m-1
        t(i,:)=t(i+1,:);
    end
    P=p(1:m-1,:);
    Q=t(1:m-1,:);

    X=con2seq(P');% input X
    T=con2seq(Q');% input Y
    net = narxnet(1:3,1:3,10);
    [Xs,Xi,Ai,Ts] = preparets(net,X,{},T);
    net = train(net,Xs,Ts,Xi,Ai);
    yp = sim(net,Xs,Xi);

    MSE=0;
    MAPE=0;
    num=1;
    num2=1;
    [n_1,n_2] = size(yp);
    t_Ts = cell2mat(Ts);%Y
    t_yp = cell2mat(yp);%sim

    valideN = 0;
    for i=1:1:n_2     
        if(t_Ts(i)>0)
            if t_Ts(i)>t_yp(i)
                MAPE = MAPE+abs(t_Ts(i)-t_yp(i))/t_Ts(i);%real
                MSE=MSE+(t_Ts(i)-t_yp(i))^2;
                num2=num2+1;
            else
                if t_yp(i)>0
                    MAPE = MAPE+abs(t_Ts(i)-t_yp(i))/t_yp(i);%sim
                    MSE=MSE+(t_Ts(i)-t_yp(i))^2;
                    num2=num2+1;
                else
                    if t_yp(i)==0 && t_Ts(i)==0
                        num2=num2+1;
                    end
                end
            end     
        end
    end

    MSE=MSE/num2;
    MAPE=MAPE/num2;
    RMSE = sqrt(MSE);