function [rows2 data N] = getVariables(handles,N)

if nargin<2
    %warning('Refactor!');
    N = handles.settings.N;
end

cols = get(handles.tParameters,'ColumnName');
rows = evalin('base','who');
rowoffset=0; brk=false;

rows2={}; data={};
for irow=1:length(rows)
    var = evalin('base',rows{irow});
    % Skip logical vectors, vars beginning with '_', matrices, or vectors
    % of different length than N, or functions
    if ~isnumeric(var) || rows{irow}(1)=='_' || size(var,2)>1 || (nargin>1 && size(var,1)~=N)
        rowoffset=rowoffset+1;
        continue
    end

    for icol=1:length(cols)
        try
            fev = evalin('base',[cols{icol} '(' rows{irow} ')']);
            if strcmp(cols{icol},'min')
                if fev>=0
                    fev = fev * .999;
                else
                    fev = fev / .999;
                end
            elseif strcmp(cols{icol},'max')
                if fev >=0
                    fev = fev / .999;
                else
                    fev = fev * .999;
                end
            end
            data{irow-rowoffset,icol} = fev;
        catch err
            rowoffset=rowoffset+1;
            brk = true;
            break
        end
    end
    if brk
        brk = false;
        continue
    end
    rows2{irow-rowoffset}=rows{irow};
end
