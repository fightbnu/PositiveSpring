%step 1 simulate ->arima(); simulate();
modSim = arima('Constant',0.2,'AR',{0.75,-0.4},...
               'MA',0.7,'Variance',0.1);
rng('default')
Y = simulate(modSim,100);

figure
plot(Y)
xlim([0,100])
title('Simulated ARMA(2,1) Series')

%step 2 ACF and PACF ->autocorr();parcorr()
figure
subplot(2,1,1)
autocorr(Y)
subplot(2,1,2)
parcorr(Y)

%step 3 fit and record ->estimate()
LOGL = zeros(4,4);
PQ = zeros(4,4);
for p = 1:4
    for q = 1:4
        mod = arima(p,0,q);
        [fit,~,logL] = estimate(mod,Y,'print',false); % fit is a model
        LOGL(p,q) = logL;
        PQ(p,q) = p+q;
     end
end

%step 4 choose BIC ->aicbic()
LOGL = reshape(LOGL,16,1);
PQ = reshape(PQ,16,1);
[~,bic] = aicbic(LOGL,PQ+1,100); 
A = reshape(bic,4,4);

%namely, p = 2, q = 1, is the best choose