function flagBasedStopExample()
    % Create a figure window
    fig = figure('Name', 'Flag-Based Stop Example', 'Position', [100, 100, 300, 150]);

    % Create a button to stop the cycle
    stopButton = uicontrol('Style', 'pushbutton', 'String', 'Stop Cycle', ...
                          'Position', [100, 50, 100, 30], ...
                          'Callback', @stopButtonCallback);

    % Initialize the flag variable
    stopFlag = false;

    % Define the stop flag callback function
    function stopButtonCallback(~, ~)
        % Set the flag to true when the button is pressed
        nonlocalStopFlag = true;
    end

    % Run the cycle
    disp('Starting the cycle...');
    for i = 1:100
        % Check the stop flag
        if stopFlag
            disp('Cycle stopped by user.');
            break;
        end
        
        % Simulate some work
        disp(['Processing iteration ' num2str(i)]);
        pause(0.1); % Adjust pause duration to simulate work

        % Pause the script and wait for the flag to change
        if i == 10 % For demonstration, check the flag every 10 iterations
            disp('Waiting for stop signal...');
            waitfor(stopButton, 'Callback');
        end
    end

    % Clean up
    close(fig);
    disp('Cycle completed or stopped.');

    % Helper function to update the flag variable
    function nonlocalStopFlag
        stopFlag = true;
    end
end
