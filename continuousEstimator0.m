%%% Team Members: WRITE YOUR TEAM MEMBERS' NAMES HERE
%%% BMI Spring 2015 (Update 17th March 2015)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %         PLEASE READ BELOW            %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Function positionEstimator has to return the x and y coordinates of the
% monkey's hand position for each trial using only data up to that moment
% in time.
% You are free to use the whole trials for training the classifier.

% To evaluate performance we require from you two functions:

% A training function named "positionEstimatorTraining" which takes as
% input the entire (not subsampled) training data set and which returns a
% structure containing the parameters for the positionEstimator function:
% function modelParameters = positionEstimatorTraining(training_data)
% A predictor named "positionEstimator" which takes as input the data
% starting at 1ms and UP TO the timepoint at which you are asked to
% decode the hand position and the model parameters given by your training
% function:

% function [x y] = postitionEstimator(test_data, modelParameters)
% This function will be called iteratively starting with the neuronal data 
% going from 1 to 320 ms, then up to 340ms, 360ms, etc. until 100ms before 
% the end of trial.


% Place the positionEstimator.m and positionEstimatorTraining.m into a
% folder that is named with your official team name.

% Make sure that the output contains only the x and y coordinates of the
% monkey's hand.


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
  y_velocity=zeros(data_number,1);
  Index=0;
  mov=zeros(2,8);
  for i = 1:1:size(training_data,1)
    for n = 1:1:size(training_data,2)
        spike_number=0;
        for m = 1:1:length(training_data(i,n).spikes(1,:))
            spike_number=spike_number+training_data(i,n).spikes(:,m);
        end
        f_rate=spike_number/length(training_data(i,n).spikes(1,:));
        Index=Index+1;
        X(Index,:)=f_rate;
        if n==1
            y1(Index,:)=0;
            y2(Index,:)=0;
            y3(Index,:)=0;
        elseif n==2
            y1(Index,:)=1;
            y2(Index,:)=0;
            y3(Index,:)=0;
        elseif n==3
            y1(Index,:)=0;
            y2(Index,:)=1;
            y3(Index,:)=0;
        elseif n==4
            y1(Index,:)=1;
            y2(Index,:)=1;
            y3(Index,:)=0;
        elseif n==5
            y1(Index,:)=0;
            y2(Index,:)=0;
            y3(Index,:)=1;
        elseif n==6
            y1(Index,:)=1;
            y2(Index,:)=0;
            y3(Index,:)=1;
        elseif n==7
            y1(Index,:)=0;
            y2(Index,:)=1;
            y3(Index,:)=1;
        elseif n==8
            y1(Index,:)=1;
            y2(Index,:)=1;
            y3(Index,:)=1;
        end
    end
 end
 C = 2;
 kernel = 'polynomial';
 kernel_param = [0.001,0.001,0.001];
 max_iter = 3000;
 
 model1=fitcsvm(X,y1,'BoxConstraint',10000,'KernelFunction',kernel,'PolynomialOrder',100);
 
 model2=fitcsvm(X,y2,'BoxConstraint',10000,'KernelFunction',kernel,'PolynomialOrder',100);
 
 model3=fitcsvm(X,y3,'BoxConstraint',10000,'KernelFunction',kernel,'PolynomialOrder',100);
 modelParameters.model1=model1;
 modelParameters.model2=model2;
 modelParameters.model3=model3;
 modelParameters.trainingdata=training_data;
  
end

% estimate function
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
  model1=modelParameters.model1;
  model2=modelParameters.model2;
  model3=modelParameters.model3;
  training_data=modelParameters.trainingdata;
  test_spikes=test_data.spikes;
  X_test=zeros(1,98);
  spike_number=0;
  time_length=length(test_spikes(1,:));
  for m = 1:1:length(test_spikes(1,:))
    spike_number=spike_number+test_spikes(:,m);
  end
  f_rate=spike_number./length(test_spikes(1,:));
  X_test(1,:)=f_rate;
  horizontal_mov=0;
  vertical_mov=0;

  predict_digit1=predict(model1,X_test);
  predict_digit2=predict(model2,X_test);
  predict_digit3=predict(model3,X_test);
 
 predict_direction_index=predict_digit1*1+predict_digit2*2+predict_digit3*4+1;
 
 for i = 1:1:size(training_data,1)
 if (length(training_data(i,predict_direction_index).handPos(1,:))>=time_length)
    horizontal_mov = horizontal_mov+training_data(i,predict_direction_index).handPos(1,time_length)-training_data(i,predict_direction_index).handPos(1,300);
    vertical_mov = vertical_mov+training_data(i,predict_direction_index).handPos(2,time_length)-training_data(i,predict_direction_index).handPos(2,300);
 else
     horizontal_mov = horizontal_mov+training_data(i,predict_direction_index).handPos(1,end-100)-training_data(i,predict_direction_index).handPos(1,300);
     vertical_mov = vertical_mov+training_data(i,predict_direction_index).handPos(2,end-100)-training_data(i,predict_direction_index).handPos(2,300);
 end
 end
 horizontal_mov=horizontal_mov/size(training_data,1)
 vertical_mov=vertical_mov/size(training_data,1);
 x=test_data.startHandPos(1)+horizontal_mov;
 y=test_data.startHandPos(2)+vertical_mov;
   
end

