%step1 load
load(fullfile(matlabroot,'examples','econ','Data_Airline.mat')) %full file path
dat = log(Data);
T = size(dat,1); %total size
y = dat(1:103); %choose from 1-103

%step2 Define and fit the model specifying seasonal lags
model1 = arima('MALags', 1, 'D', 1, 'SMALags', 12,...
'Seasonality',12, 'Constant', 0);
fit1 = estimate(model1,y);

%step3 Define and fit the model using seasonal dummies
X  = dummyvar(repmat((1:12)', 12, 1));
X0 = [zeros(1,11) 1 ; dummyvar((1:12)')];
model2 = arima('MALags', 1, 'D', 1, 'Seasonality',...
			12, 'Constant', 0);
fit2   = estimate(model2,y, 'X', [X0 ; X]);

%Step 4. Forecast using both models
yF1 = forecast(fit1,41,'Y0',y); %41 means we cut down the 41 series..!!!
yF2 = forecast(fit2,41,'Y0',y,'X0',X(1:103,:),...
			'XF',X(104:end,:));
l1 = plot(100:T,dat(100:end),'k','LineWidth',3); %T is size; dat is the whole data;
hold on %or l1 and l2 will be covered
l2 = plot(104:144,yF1,'-r','LineWidth',2);
l3 = plot(104:144,yF2,'-b','LineWidth',2);
hold off
title('Passenger Data: Actual vs. Forecasts')
xlabel('Month')
ylabel('Logarithm of Monthly Passenger Data')
legend({'Actual Data','Polynomial Forecast','Regression Forecast'},'Location','NorthWest')

% MSE_LR=0;
% MAPE=0;
% [num,num_2] = size(p);
% num3=1;
% for i=1:1:num
%     MSE_LR = MSE_LR+(p(i)-y(i))^2;
%     if(y(i)>0)
%         MAPE=MAPE+abs(p(i)-y(i))/y(i);
%         num3=num3+1;
%     end
% end
% 
% MSE_LR=MSE_LR/num;
% MAPE = MAPE/num3;
