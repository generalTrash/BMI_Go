% training function
function [modelParameters] = positionEstimatorTraining(training_data)
  % Arguments:
  
  % - training_data:
  %     training_data(n,k)              (n = trial id,  k = reaching angle)
  %     training_data(n,k).trialId      unique number of the trial
  %     training_data(n,k).spikes(i,t)  (i = neuron id, t = time)
  %     training_data(n,k).handPos(d,t) (d = dimension [1-3], t = time)
  
  % ... train your model
  
  % Return Value:
  
  % - modelParameters:
  %     single structure containing all the learned parameters of your
  %     model and which can be used by the "positionEstimator" function.
  data_number=size(training_data,1)*size(training_data,2);
  X=zeros(data_number,98);
  y1=zeros(data_number,1);
  y2=zeros(data_number,1);
  y3=zeros(data_number,1);
  Index=0;
  for i = 1:1:size(training_data,1)
    for n = 1:1:size(training_data,2)
        spike_number=0;
        for m = 1:1:length(training_data(i,n).spikes(1,:))
            spike_number=spike_number+training_data(i,n).spikes(:,m);
        end
        f_rate=spike_number/length(training_data(i,n).spikes(1,:));
        Index=Index+1;
        X(Index,:)=f_rate;
        [coeff, score] = pca(X);
    end
  end
 kernel = 'polynomial';
 
 model1=fitcsvm(X,y1,'BoxConstraint',10000,'KernelFunction',kernel,'PolynomialOrder',100);
 
 model2=fitcsvm(X,y2,'BoxConstraint',10000,'KernelFunction',kernel,'PolynomialOrder',100);
 
 model3=fitcsvm(X,y3,'BoxConstraint',10000,'KernelFunction',kernel,'PolynomialOrder',100);
 modelParameters.model1=model1;
 modelParameters.model2=model2;
 modelParameters.model3=model3;
 modelParameters.trainingdata=training_data;
  
end