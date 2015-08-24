function alldata(expName, SubjectStart, SubjectEnd)
for i = SubjectStart:SubjectEnd
    s = num2str(i);
    if i < 10
        a = num2str(i);
        s = strcat('00', a);
    else 
        a = num2str(i);
        s = strcat('0', a);
    end
    loadandwritedata(expName, s);
end
    
    