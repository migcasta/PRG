function [out]=PRG(G0,outCL ,inCL)
% Returns the Partial Relative Gain (PRG) for the dc-gain matrix "G0" and 
% for  closing the loop under perfect control with the inputs and
% outputs specified by "inCL" and "outCL". The PRG has been
% defined in by K.E. Haeggblom (1997) in the paper titled: "Partial 
% relative gain: a new tool for control structure selection"
% 
% G0: dc-gain matrix
% outCL: indexes of the outputs which are under perfect control
% inCL: indexes of the inputs used for closing the loop under perfect
% control
% 
% Function by: Miguel Castaño Arranz (12-02-2017)

% Example: Consider the following DC-gain system fot a Petlyuk distillation 
% column used in by K.E. Haeggblom (1997) to calculate PRGAs: 
%  G0=[153.45, -179.34,  0.23,  0.03;
%    -157.67,  184.75, -0.10, 21.63;
%      24.63,  -28.97, -0.23,  -0.1;
%       -4.8,    6.09,  0.13,  -2.41];
% PRG obtained by closing the loop composed by input 1 and output 1: 
% [out]=PRG(G0,1,1); % Eq.28 by K.E. Haeggblom (1997)
% PRG obtained by closing the loop composed by input 1 and output 3: 
% [out]=PRG(G0,3,1); % Eq.29 by K.E. Haeggblom (1997)
% PRG obtained by closing the loop composed by input 2 and output 4: 
% [out]=PRG(G0,4,2); % Eq.30 by K.E. Haeggblom (1997)
% PRG obtained by closing the loop composed by inputs 1,3 and outputs 1,3:
% [out]=PRG(G0,[1,3],[1,3]); % Eq.31 by K.E. Haeggblom (1997)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We first check the input and output arguments to the function
checkvalues(G0,outCL,inCL);

nCL=length(inCL); %number of measuresments in closed loop
nOL=size(G0,1)-nCL; % number of measurements in open loop


% We are going to reorder the rows and columns in G0 in such a way that
% the outputs/inputs in open loop are in the first rows/columns and the
% outputs/input in closed loop are in the last rows/columns.
% The following lines are for creating "rows" and "columns", which
% include the indexes for the reordering of G0.
rows=1:1:size(G0,1);
columns=1:1:size(G0,2);
for ct=1:length(outCL)
    rows(rows==outCL(ct))=[];
    columns(columns==inCL(ct))=[];
end
rows=[rows,outCL];
columns=[columns,inCL];

% Reordering of G0.
G0=G0(rows,columns);

% Partitioning of G0 to calculate the gains in closed loop
G11=G0(1:nOL,1:nOL);
G22=G0(nOL+1:end,nOL+1:end);
G12=G0(1:nOL,nOL+1:end);
G21=G0(nOL+1:end,1:nOL);

% Open loos gains after closing part of the process under perfect control
CLgain=G11-G12*(G22\G21);

% Calculation of PRGA
out=CLgain.*transpose(inv(CLgain));
end

function checkvalues(G0,outCL,inCL)
if ~isa(G0,'double')
    error('First input must be a matrix of double elements')
end
if size(G0,1)~=size(G0,2)
    error('First input must have the same number of rows and columns')
end
if size(inCL,2)>1 && size(inCL,1)>1 || ~isa(inCL,'double')
    error('Second input must be a 1D vector of double elements');
end
if size(outCL,2)>1 && size(outCL,1)>1 || ~isa(outCL,'double')
    error('Third input must be a 1D vector with double elements');
end
if size(outCL,2)~=size(inCL,2) ||  size(inCL,1)~=size(outCL,1)
    error('Second and third inputs must be vectors of the same size');
end
if length(inCL)>size(G0,1)
    error(['The second input must have less elements than the number of'...
        ' rows/columns of the first input'])
end
if length(outCL)>size(G0,1)
    error(['The second input must have less elements than the number of'...
        ' rows/columns of the first input'])
end

end