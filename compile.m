
  % Compile trimesh2:
  cd('./code/LIBS/trimesh2');
  system('make');
  cd('../../..');
  
  % Compile OpenGL rendering code:
  cd('./code/LIBS/GenerateLambertian');
  system('make');
  cd('../../..');
  