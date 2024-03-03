function [x, y] = positionEstimator(test_data, modelParameters)

  % **********************************************************
  %
  % You can also use the following function header to keep your state
  % from the last iteration
  %
  % function [x, y, newModelParameters] = positionEstimator(test_data, modelParameters)
  %                 ^^^^^^^^^^^^^^^^^^
  % Please note that this is optional. You can still use the old function
  % declaration without returning new model parameters. 
  %
  % *********************************************************

  % - test_data:
  %     test_data(m).trialID
  %         unique trial ID
  %     test_data(m).startHandPos
  %         2x1 vector giving the [x y] position of the hand at the start
  %         of the trial
  %     test_data(m).decodedHandPos
  %         [2xN] vector giving the hand position estimated by your
  %         algorithm during the previous iterations. In this case, N is 
  %         the number of times your function has been called previously on
  %         the same data sequence.
  %     test_data(m).spikes(i,t) (m = trial id, i = neuron id, t = time)
  %     in this case, t goes from 1 to the current time in steps of 20
  %     Example:
  %         Iteration 1 (t = 320):
  %             test_data.trialID = 1;
  %             test_data.startHandPos = [0; 0]
  %             test_data.decodedHandPos = []
  %             test_data.spikes = 98x320 matrix of spiking activity
  %         Iteration 2 (t = 340):
  %             test_data.trialID = 1;
  %             test_data.startHandPos = [0; 0]
  %             test_data.decodedHandPos = [2.3; 1.5]
  %             test_data.spikes = 98x340 matrix of spiking activity
  
  
  
  % ... compute position at the given timestep.
  
  % Return Value:
  
  % - [x, y]:
  %     current position of the hand
  X_train=modelParameters.X;
  k=modelParameters.k;
  training_data=modelParameters.training_data;
  a=modelParameters.a;
  b=modelParameters.b;

   test_spikes=test_data.spikes;
 X_test=zeros(1,98);
 spike_number=0;
 time_length=length(test_spikes(1,:))
 
 for m = 1:time_length
 spike_number=spike_number+test_spikes(:,m);
 end
 f_rate=spike_number./time_length;
 X_test(1,:)=f_rate;
 horizontal_mov=0;
 vertical_mov=0;
 if modelParameters.ID ~= test_data.trialId
 predict_direction_index=knn(X_train, X_test, k,b);
 modelParameters.direction=[];
 else
 predict_direction_index=knn(X_train, X_test, k,b);
 modelParameters.direction(end+1)=predict_direction_index;
 predict_direction_index=modelParameters.direction(end);
 modelParameters.ID=test_data.trialId;
 end
 
 for i = 1:a
 if (size(training_data(i,predict_direction_index).handPos,2)>=time_length)
    horizontal_mov = horizontal_mov+training_data(i,predict_direction_index).handPos(1,time_length)-training_data(i,predict_direction_index).handPos(1,300);
    vertical_mov = vertical_mov+training_data(i,predict_direction_index).handPos(2,time_length)-training_data(i,predict_direction_index).handPos(2,300);
 else
     horizontal_mov = horizontal_mov+training_data(i,predict_direction_index).handPos(1,end-100)-training_data(i,predict_direction_index).handPos(1,300);
     vertical_mov = vertical_mov+training_data(i,predict_direction_index).handPos(2,end-100)-training_data(i,predict_direction_index).handPos(2,300);
 end
 end
 horizontal_mov=horizontal_mov/size(training_data,1);
 vertical_mov=vertical_mov/size(training_data,1);
 x=test_data.startHandPos(1)+horizontal_mov;
 y=test_data.startHandPos(2)+vertical_mov;
   
end