function ballGameV3GUI
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ballGameV3.m
    % 
    %     AUTHOR: Miles Vincent Barnhart
    %       DATE: 01 Jan. 2018
    %        VER: 3.0
    %
    %     INFO: A MATLAB program that tries to solve the marble solitaire
    %           game (sometimes referred to as 'Venecian solitaire') using
    %           a brute force guess approach.
    %
    %           Can be run using a parallel pool and calling from the
    %           command line as:
    %
    %                          >> parpool(N); % N = Number of cores
    %
    %                          >> parfor i = 1:N
    %                          >> ballGameV3;
    %                          >> end
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bg_temp = ballGameGUI;
    bg_handle = guidata(bg_temp);

    iter = 1;
%     disp(' Iteration    Best yet     Current Iter.');
%     disp(' ---------    --------     -------------');
    flags = getFlags();
    xbest = 100;
    x_plt = [];
    tic;
    while xbest > 1
        
        [x, moves] = genMoves(flags);
        set(bg_handle.text5, 'String', num2str(iter));
        set(bg_handle.text6, 'String', num2str(xbest));
        
        if isempty(x_plt)
            x_plt = imagesc(x, 'Parent', bg_handle.axes2);
            set(bg_handle.axes2, 'XTickLabel', '', 'YTickLabel', '');
        else
            set(x_plt, 'CData', x);
            set(bg_handle.axes2, 'XTickLabel', '', 'YTickLabel', '');
        end
        drawnow;
        
        xi = sum(sum(x)); % If sum(x) == 1, game has been solved
        
        if xi < xbest % Update best game
            
            xbest = xi;
            
        end

        %fprintf('\t%0.0f\t\t\t\t%0.0f\t\t\t%0.0f\n', iter, xbest, xi);
        iter = iter + 1;

    end
    fprintf('Time Elapsed = %f\n', toc); 
    randNum =  sprintf('%d', randi([1,10000], 1)); % Save winning moves
    save(['winningMoves',randNum, '.mat'], 'moves');
    save(['winningBoard',randNum, '.mat'], 'x');
    disp(moves);
    disp('Solution found!');
    
    function [x, realmoves] = genMoves(flags)
        
        rand_row = 1:7;
        rand_row = randperm(length(rand_row));
        rand_col = randperm(length(rand_row));
        c = 1;
        mc = 1;                       

        x = genMat(); % Generate initial board                                     
                      % with random empty spot
        while 1

            xold = x;

            for i = rand_row % Stepping over rows

                for j = rand_col % Stepping over columbs

                    [x, moves.(['m',sprintf('%d', c)])] = cellEdit(x, i, j, flags);
                    
                    if isequaln(moves.(['m',sprintf('%d', c)]).move, 0) == 0

                        realmoves.(['m',sprintf('%d', mc)]) = moves.(['m',sprintf('%d', c)]).move;
                        mc = mc + 1;
                        
                    end
                    
                    c = c + 1;
                    
                end
                
            x(x == 2) = 0; % Set boundary values to zero
            %spy(x);set(gca, 'XTickLabel', '', 'YTickLabel','');pause(1);
            end

            if x == xold % Check if the board layout has changed

                break

            end

        end
        
        
    function [x, step] = cellEdit(x, row, col, flags)

        step.move = 0;
        
        flCk = flags{row, col};
        shuffledFL = flCk(randperm(length(flCk))); % Shuffle moves
        
        start = randi([1, randi([1, length(flCk)])], 1); % Random starting move
        len = randi([1, length(shuffledFL)],1); % Random end move
        
        if len > start
            
            d = 1; % Left-to-right
            
        else 
            
            d = -1; % Right-to-left
            
        end
        
        for i = start:d:len
            
            if isequaln(shuffledFL{i}, '')
                
                break
                
            elseif isequaln(shuffledFL{i}, 'vu') % Upward jump
                    
                if x(row, col) == 0 && ... % Check if empty spot and populated spots are available
                   x(row - 1, col) == 1 && ...
                   x(row - 2, col) == 1
                       
                   x(row, col) = 1; % Update board after jump
                   x(row - 1, col) = 0;
                   x(row - 2, col) = 0;
                   step.move = {row, col, 'vu'};
                    
                end
                    
            elseif isequaln(shuffledFL{i}, 'vd') % Downward jump
                    
                if x(row, col) == 0 && ... % Check if empty spot and populated spots are available
                   x(row + 1, col) == 1 && ...
                   x(row + 2, col) == 1
                       
                   x(row, col) = 1; % Update board after jump
                   x(row + 1, col) = 0;
                   x(row + 2, col) = 0;
                    
                   step.move = {row, col, 'vd'};
                        
                end
                    
            elseif isequaln(shuffledFL{i}, 'hl') % Horizontal-left jump
                    
                if x(row, col) == 0 && ... % Check if empty spot and populated spots are available
                   x(row, col - 1) == 1 && ...
                   x(row, col - 2) == 1
                       
                   x(row, col) = 1; % Update board after jump
                   x(row, col - 1) = 0;
                   x(row, col - 2) = 0;
                   step.move = {row, col, 'hl'};
                   
                end
                    
            elseif isequaln(shuffledFL{i}, 'hr') % Horizontal-right jump
                    
                if x(row, col) == 0 && ... % Check if empty spot and populated spots are available
                   x(row, col + 1) == 1 && ...
                   x(row, col + 2) == 1
                       
                   x(row, col) = 1; % Update board after jump
                   x(row, col + 1) = 0;
                   x(row, col + 2) = 0;
                   step.move = {row, col, 'hr'};
                   
                end
                
            end
            
            if isempty(step.move)

                step.move = 0;

            end
            
        end     

    function [x] = genMat()
        
                              % Empty spots with possible  
                              % winning solutions
        pickAspot = [1, 3;    %          W   L   W
                     1, 5;    %      L   L   W   L   L
                     2, 4;    %  W   L   L   W   L   L   W
                     3, 1;    %  L   W   W   L   W   W   L
                     3, 4;    %  W   L   L   W   L   L   W
                     3, 7;    %      L   L   W   L   L
                     4, 2;    %          W   L   W
                     4, 3;
                     4, 5;
                     4, 6;
                     5, 1;
                     5, 4;
                     5, 7;
                     6, 4;
                     7, 3;
                     7, 5];
                 
        x = ones(7);          % Initial board layout w/ 2's denoting
                              % boundary positions (not included)            
        x(2, 1) = 2;          % 2  2  1  1  1  2  2 
        x(1, 1:2) = 2;        % 2  1  1  1  1  1  2
        x(1,6:7) = 2;         % 1  1  1  1  1  1  1
        x(2, end) = 2;        % 1  1  1  1  1  1  1 
        x(end - 1, 1) = 2;    % 2  1  1  1  1  1  2
        x(end, 1:2) = 2;      % 2  2  1  1  1  2  2
        x(end, 6:7) = 2;
        x(end-1, end) = 2;
        x(pickAspot(randi([1,16],1),:)) = 0; % Initial empty spot
        
	function flags = getFlags()
            
        flags = cell(7);   % Assign possible moves for each cell
        flags(:) = {{''}}; % (this section needs to be optimized)
        flags{1, 3} = {'vd', 'hr'};
        flags{1, 4} = {'vd'};
        flags{1, 5} = {'vd', 'hl'};

        flags{2, 2} = {'vd', 'hr'};
        flags{2, 3} = {'vd', 'hr'};
        flags{2, 4} = {'vd','hl','hr'};
        flags{2, 5} = {'vd', 'hl'};
        flags{2, 6} = {'vd', 'hl'};

        flags{3, 1} = {'vd', 'hr'};
        flags{3, 2} = {'vd', 'hr'};        
        flags{3, 3} = {'vu', 'vd', 'hl', 'hr'};
        flags{3, 4} = {'vu', 'vd', 'hl', 'hr'};
        flags{3, 5} = {'vu', 'vd', 'hl', 'hr'};
        flags{3, 6} = {'vd', 'hl'};
        flags{3, 7} = {'vd', 'hl'};

        flags{4, 1} = {'hr'};
        flags{4, 2} = {'vu','vd','hr'};
        flags{4, 3} = {'vu', 'vd', 'hl', 'hr'};
        flags{4, 4} = {'vu', 'vd', 'hl', 'hr'};
        flags{4, 5} = {'vu', 'vd', 'hl', 'hr'};
        flags{4, 6} = {'vu','vd','hl'};
        flags{4, 7} = {'hl'};

        flags{5, 1} = {'vu', 'hr'};
        flags{5, 2} = {'vu', 'hr'};
        flags{5, 3} = {'vu', 'vd', 'hl', 'hr'};
        flags{5, 4} = {'vu', 'vd', 'hl', 'hr'};
        flags{5, 5} = {'vu', 'vd', 'hl', 'hr'};
        flags{5, 6} = {'vu', 'hl'};
        flags{5, 7} = {'vu', 'hl'};

        flags{6, 2} = {'vu', 'hr'};
        flags{6, 3} = {'vu', 'hr'};
        flags{6, 4} = {'vu','hl','hr'};
        flags{6, 5} = {'vu', 'hl'};
        flags{6, 6} = {'vu', 'hl'};

        flags{7, 3} = {'vu', 'hr'};
        flags{7, 4} = {'vu'};
        flags{7, 5} = {'vu', 'hl'};

    