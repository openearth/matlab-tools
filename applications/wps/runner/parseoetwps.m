function [match] = parseoetwps(filename)
    fid = fopen(filename);
    text = fgetl(fid);
    match = regexp(text, '(?<function>function)\s*\[\s*(\w+,?\s*)*\]\s*=\s*(?<name>\w+)\s*\(\s*((?<arg>\w+),?\s*)*\)', 'names')
    
end 