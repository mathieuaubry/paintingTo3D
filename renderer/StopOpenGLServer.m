function StopOpenGLServer(pipeName)
  
fp = fopen(pipeName,'w');
fprintf(fp,'EXIT_SERVER\n');
fclose(fp);

t = cputime;
loop_wait = 1;
while loop_wait && ((cputime-t) < 5)
  fp = fopen(pipeName,'r');
  if fp~=-1
    tline = fgets(fp);
    fclose(fp);
    
    if ~isempty(strfind(tline,'SERVER_STOPPED'))
      loop_wait = 0;

      % Remove pipe file:
      delete(pipeName);
    end
  end
end
