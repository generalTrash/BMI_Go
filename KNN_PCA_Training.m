function [modelParameters] = positionEstimatorTraining(training_data)
 spikesMatrix = [training_data.spikes];
 length(training_data(1,2).spikes(1,:))
 [coeff, score] = pca(training_data);
 data = score(:,1);

 data_number = size(data)
 X=zeros(data_number,98);
 y=zeros(data_number,1);
 for i = 1:1:data_number
    spike_number=0;
    for m = 1:1:length(data(i).spikes(1,:))
        spike_number= spike_number+data(i).spikes(:,m);
    end
    f_rate=spike_number/length(training_data(i,n).spikes(1,:));
    X(i,:)=f_rate;
    y(i,:)=n;
 end
 k=1*size(X,1)/8;
 modelParameters.X=X;
 modelParameters.y=y;
 modelParameters.k=k;
 modelParameters.trainingdata=training_data;
 modelParameters.ID=-1;
 modelParameters.direction=[];
end