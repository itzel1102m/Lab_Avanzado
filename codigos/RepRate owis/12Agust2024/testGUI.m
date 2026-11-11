function testGUI()



    doPause = false;
    figure('menu','none', 'Position',[400 400 150 30])
    hb = uicontrol('Style','pushbutton', 'String','Pause', ...
        'Callback',@buttonCallback, 'Unit','Normalized', 'Position',[0 0 1 1]);
    %drawnow

    while ishandle(hb)
        %# check if the user wants to pause
        if doPause
            pause()             %# pauses until user press any key
            doPause = false;
            a = rand();
            break;
            %# reset
            doPause = false;
            if ishandle(hb), set(hb, 'Enable','on'), drawnow, end
        end

        %# Calculations
        disp(rand), pause(.1)

        %# keep the GUI responsive
        drawnow
    end

    %# callback function for the button
    function buttonCallback(hObj,ev)
        doPause = true;
        set(hObj, 'Enable','off')
    end
disp(a)
end