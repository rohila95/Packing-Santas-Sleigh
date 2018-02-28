
firstRow = 1;

firstCol = 0;

presentsTemp = csvread('presents.csv', firstRow, firstCol);

[rows, columns] = size(presentsTemp);
numPresents = rows % the number of presents will be displayed in the Command Window

idsCol = presentsTemp(:,1:1);
dimensions = presentsTemp(:,2:4);
dimensions = sort(dimensions,2);
presents = horzcat(idsCol,dimensions);



presentIDs = presents(:,1);
presentWidth = presents(:,2);
presentLength = presents(:,3);
presentHeight = presents(:,4);
presentVol = [presentIDs, presentWidth(:).*presentLength(:).*presentHeight(:)];
minVol = min(presentVol(:,2))
maxVol = max(presentVol(:,2))



% Parameters
width = 1000;
length = 1000;
xs = 1; ys = 1; zs = -1; % Initial coordinates for placing boxes
% lastRowIdxs = zeros(100,1); % Buffer for storing row indices
% lastLayerIdxs = zeros(500,1); % Buffer for storing layer indices
numInRow = 0;
numInLayer = 0;
presentCoords = zeros(numPresents,25); % PresentID and 8 sets of coordinates per present
numRowInLayer = 1;

lastElement = 0;

for i = 1:numPresents
    flag = 0;
    if numRowInLayer > 1
        bestRow = BAF(presentWidth(i),presentLength(i),lastPresentInRowDetails,presentCoords);        
        if bestRow ~=0
            newXs = presentCoords(lastPresentInRowDetails(bestRow,1),5)+1;
            newYs = presentCoords(lastPresentInRowDetails(bestRow,1),6);
            newZs = presentCoords(lastPresentInRowDetails(bestRow,1),7);
            
            presentCoords(i,1) = presentIDs(i);
            presentCoords(i,[2 8 14 20]) = newXs;
            presentCoords(i,[5 11 17 23]) = newXs + presentWidth(i) - 1;
            presentCoords(i,[3 6 15 18]) = newYs;
            presentCoords(i,[9 12 21 24]) = newYs + presentLength(i) - 1;
            presentCoords(i,[4 7 10 13]) = newZs;
            presentCoords(i,[16 19 22 25]) = newZs - presentHeight(i) + 1;
            
            lastPresentInRowDetails(bestRow,1) = i;
%             lastPresentInRowDetails(bestRow,3) = 0;
            numInLayer = numInLayer +1;
            lastLayerIdxs(numInLayer) = presentIDs(i);
            flag=1;
%             presentCoords(i,:) = presentCoords(i,:)
        end
        
    end
    if flag==0
        % Move to the next row if there isn't room
        if xs + presentWidth(i) > width + 1 % exceeded allowable width
            ys = ys + max(presentLength(lastRowIdxs(1:numInRow))); % increment y to ensure no overlap
            lastPresentInRowDetails(numRowInLayer,:) = [lastRowIdxs(numInRow),max(presentLength(lastRowIdxs(1:numInRow)))];
            numRowInLayer = numRowInLayer+1;
            xs = 1;
            numInRow = 0;
            clear lastRowIdxs;
%             astRowIdxs = zeros(100,1);l
        end
        % Move to the next layer if there isn't room
        if ys + presentLength(i) > length + 1 % exceeded allowable length
            zs = zs - max(presentHeight(lastLayerIdxs(1:numInLayer))); % increment z to ensure no overlap
            xs = 1;
            ys = 1;
            numInLayer = 0;
            clear lastLayerIdxs;
%             lastLayerIdxs = zeros(500,1);
            numInRow = 0;
            clear lastRowIdxs;
%             lastRowIdxs = zeros(100,1);
            clear lastPresentInRowDetails;
            numRowInLayer = 1;
        end

        % Fill present coordinate matrix
        presentCoords(i,1) = presentIDs(i);
        presentCoords(i,[2 8 14 20]) = xs;
        presentCoords(i,[5 11 17 23]) = xs + presentWidth(i) - 1;
        presentCoords(i,[3 6 15 18]) = ys;
        presentCoords(i,[9 12 21 24]) = ys + presentLength(i) - 1;
        presentCoords(i,[4 7 10 13]) = zs;
        presentCoords(i,[16 19 22 25]) = zs - presentHeight(i) + 1;

        % Update location info
        lastElement = i;
        xs = xs + presentWidth(i);
        numInRow = numInRow+1;
        numInLayer = numInLayer+1;
        lastRowIdxs(numInRow) = presentIDs(i);
        lastLayerIdxs(numInLayer) = presentIDs(i);
    end
end

% We started at z = -1 and went downward, need to shift so all z-values >=
% 1
zCoords = presentCoords(:,4:3:end);
minZ = min(zCoords(:));
presentCoords(:,4:3:end) = zCoords - minZ + 1;


idealOrder = presentIDs; 

maxZ = max(max(presentCoords(:,4:3:end)));

maxZCoord = zeros(numPresents,2);
for i = 1:numPresents
    maxZCoord(i,1) = presentCoords(i);
    maxZCoord(i,2) = max(presentCoords(i,4:3:end));
end
maxzCoordSorted = sortrows(maxZCoord,[-2 1]); %sort max z-coord for each present
reOrder = maxzCoordSorted(:,1);

% Compare the new order to the ideal order
order = sum(abs(idealOrder - reOrder));

% Compute metric
metric = 2*maxZ + order;


subfile = 'submissionfile_BAF.csv';
fileID = fopen(subfile, 'w');
headers = {'PresentId','x1','y1','z1','x2','y2','z2','x3','y3','z3','x4','y4','z4','x5','y5','z5','x6','y6','z6','x7','y7','z7','x8','y8','z8'};
fprintf(fileID,'%s,',headers{1,1:end-1});
fprintf(fileID,'%s\n',headers{1,end});
fprintf(fileID,'%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n',presentCoords');
fclose(fileID);


function rowId = BAF(newPwidth, newPlength, lastPresentInRowDetails,presentCoords)

    noOfRows = size(lastPresentInRowDetails,1);
    minValue = 9999999999;
    rowId = 0;
    for j = 1:noOfRows
        remainingWidth = 1000 - presentCoords(lastPresentInRowDetails(j,1),5);
        maxLength = lastPresentInRowDetails(j,2);
        if newPwidth < remainingWidth && newPlength < maxLength
            if minValue > remainingWidth * maxLength - newPwidth* newPlength
                minValue = remainingWidth * maxLength - newPwidth* newPlength;
                rowId = j;
            end
        end  
    end
end

