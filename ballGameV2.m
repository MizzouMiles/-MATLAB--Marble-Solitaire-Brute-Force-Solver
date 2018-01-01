function ballGameV2()

close all; clc;echo off;
format shortG;

iteration = 3;
iteration2 = 1;

for h = 1:3
    [x, moves, count] = genMoves();

    mc = 1;

    for i = 1:count - 1

        if isequaln(moves.(genvarname(char(strcat('m',num2str(i))))).move, 0) == 0

            realmoves.(genvarname(char(strcat('m',num2str(mc))))) = moves.(genvarname(char(strcat('m',num2str(i))))).move;
            mc = mc + 1;

        end

    end
    record_moves{:,:, h} = struct2cell(realmoves);
    
end
disp('Iter.     SUM(X)');

while sum(sum(x)) > 2
    
    while isequaln(record_moves{:,:,1:iteration-1}, record_moves{:,:,iteration}) == 0

        [x, moves, count] = genMoves();
        mc = 1;

        for i = 1:count - 1
           
            if isequaln(moves.(genvarname(char(strcat('m',num2str(i))))).move, 0) == 0

                realmoves.(genvarname(char(strcat('m',num2str(mc))))) = moves.(genvarname(char(strcat('m',num2str(i))))).move;
                mc = mc + 1;

            end

        end
        
        record_moves{:,:,iteration + 1} = struct2cell(realmoves);
        disp([iteration, sum(sum(x))])
        iteration = iteration + 1;    
        
    end
    
    xbest(iteration2) = sum(sum(x));
    best = min(xbest);    
    iteration2 = iteration2 + 1;
    disp('NEXT GENERATION');
    disp(['Best yet: ', num2str(best)]);
    
    
end
disp((realmoves))
a = struct2cell(realmoves)
disp(x)
disp(a{1})


    function [x, moves, c] = genMoves()

        rand_x = 1:7;
        rand_x = randperm(length(rand_x));
        rand_y = randperm(length(rand_x));
        c = 1;
        
        % x = genMat([randi([3,5],1), randi([3,5],1)]); % Generate random initial
        %                                                 empty location

        x = genMat([3, 7]);

            for k = 1:60

                xold = x;

                for i = rand_x

                    for j = rand_y
                        
                        [x, moves.(genvarname(char(strcat('m',num2str(c)))))] = cellEdit(x, i, j);
                        %disp(['move #:',num2str(c)]);
                        %disp(moves.(genvarname(char(strcat('m',num2str(c))))));
                        c = c + 1;
                    end


                x(x == 2) = 0;

                end

                if x == xold

                    break

                end

            end
    

    function [xUpdated, step] = cellEdit(x, row, col)

        flags = cell(7);
        flags(:) = {{''}};

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
        step.move = 0;
        %step.row = row;
        %step.col = col;
        
        flCk = flags{row, col};
        shuffledFL = flCk(randperm(length(flCk)));
        %step.start = randi([1, randi([1, length(flCk)])], 1);
        %step.length = randi([1, length(shuffledFL)],1);
        
        start = randi([1, randi([1, length(flCk)])], 1);
        len = randi([1, length(shuffledFL)],1);
        
        if len > start
            
            d = 1;
            
        else 
            
            d = -1;
            
        end
        
        %step.order = shuffledFL(step.start:d:step.length);
        
        for i = start:d:len
            
            if issame(shuffledFL{i}, '')
                
                break
                
            elseif issame(shuffledFL{i}, 'vu') % Upward jump
                    
                if x(row, col) == 0 & ... % Check if empty spot and populated spots are available
                   x(row - 1, col) == 1 & ...
                   x(row - 2, col) == 1
                       
                   x(row, col) = 1; % Update board after jump
                   x(row - 1, col) = 0;
                   x(row - 2, col) = 0;
                   step.move = {row, col, 'vu'};
                    
                end
                    
            elseif issame(shuffledFL{i}, 'vd') % Downward jump
                    
                if x(row, col) == 0 & ... % Check if empty spot and populated spots are available
                   x(row + 1, col) == 1 & ...
                   x(row + 2, col) == 1
                       
                   x(row, col) = 1; % Update board after jump
                   x(row + 1, col) = 0;
                   x(row + 2, col) = 0;
                    
                   step.move = {row, col, 'vd'};
                        
                end
                    
            elseif issame(shuffledFL{i}, 'hl') % Horizontal-left jump
                    
                if x(row, col) == 0 & ... % Check if empty spot and populated spots are available
                   x(row, col - 1) == 1 & ...
                   x(row, col - 2) == 1
                       
                   x(row, col) = 1; % Update board after jump
                   x(row, col - 1) = 0;
                   x(row, col - 2) = 0;
                   step.move = {row, col, 'hl'};
                   
                end
                    
            elseif issame(shuffledFL{i}, 'hr') % Horizontal-right jump
                    
                if x(row, col) == 0 & ... % Check if empty spot and populated spots are available
                   x(row, col + 1) == 1 & ...
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

        xUpdated = x;
        

    function [x] = genMat(hole)

        x = ones(7);

        x(2, 1) = 2;
        x(1, 1:2) = 2;
        x(1,6:7) = 2;
        x(2, end) = 2;
        x(end - 1, 1) = 2;
        x(end, 1:2) = 2;
        x(end, 6:7) = 2;
        x(end-1, end) = 2;
        x(hole(1), hole(2)) = 0;

    