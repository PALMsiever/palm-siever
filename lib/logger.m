% Logger function
% 
function logger(varargin)

if nargin==0
    logger_();
else
    for arg = varargin
        logger_(arg{1});
    end
end

function logger_(str)

if isappdata(0,'logger') && nargin>0
    l = getappdata(0,'logger');
    
    h = l(1);
    textArea = l(2);
    
    h.setVisible(true);
else
    h = javax.swing.JFrame('Log');
    h.setSize(500, 200);
    %textArea = javax.swing.JTextArea();
    textArea = javax.swing.JEditorPane();
    kit = javax.swing.text.html.HTMLEditorKit();
    textArea.setEditorKit(kit);
    doc = kit.createDefaultDocument();
    textArea.setDocument(doc);
    pane=javax.swing.JScrollPane(textArea);
    h.getContentPane().add(pane);
    h.setVisible(true);
    
    textArea.setText('<html><body id=body></body></html>');

    setappdata(0,'logger',[h textArea]);
end

if nargin>0
    if ischar(str)
        html = str;
    elseif isnumeric(str)
        html = matrix2html(str,'%.3e');
    else
        html = ['[' str ']'];
    end
    
    %textArea.append([str 10]);
    body = textArea.getDocument.getElement('body');
    textArea.getDocument.insertBeforeEnd(body,['<p>' html '</p>']);
    textArea.setCaretPosition(textArea.getDocument().getLength());
end

