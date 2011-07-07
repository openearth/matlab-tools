function WriteWebsiteHead(fid,title,url)

fprintf(fid,'%s\n','<head>');
fprintf(fid,'%s\n',['   <title>' title '</title>']);
fprintf(fid,'%s\n',['   <link rel="stylesheet" type="text/css" media="screen" href="' url 'tide.css" title="Normal"/>']);
fprintf(fid,'%s\n','</head>');
fprintf(fid,'%s\n','');

