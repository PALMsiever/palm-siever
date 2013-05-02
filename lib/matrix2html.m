% Matrix to HTML table
function str = matrix2html(M,precision)

if nargin<2
    precision = 1e4;
end

str = '<table>';

for r = 1:size(M,1)
    str = [str '<tr>'];
    for c = 1:size(M,2)
        str = [str '<td>' num2str(M(r,c),precision) '</td>'];
    end
    str = [str '</tr>'];
end

str = [str '</table>'];

