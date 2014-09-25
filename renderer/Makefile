UNAME := $(shell uname)

# DEBUG = y
TRIMESHDIR = LIBS/trimesh2
MAKERULESDIR = $(TRIMESHDIR)
INCLUDES = -I$(TRIMESHDIR)/include -I$(INCLUDE) 
LIBDIR = -L$(TRIMESHDIR)/lib.$(UNAME)

include $(MAKERULESDIR)/Makerules
ifeq ($(UNAME),Win32)
  COPTS += -mwindows
endif

SOURCES = interactive_frustum.cc get_3d_info_textures.cc get_3d_info.cc rayCastGL.cc interactive_viewpoint.cc visibility_mesh.cc point_view.cc smooth_normals.cc rtsc.cc apparentridge.cc
OFILES = $(addprefix $(OBJDIR)/,$(SOURCES:.cc=.o))
PROGS = get_3d_info_textures$(EXE)
#PROGS = interactive_frustum$(EXE) get_3d_info_textures$(EXE) get_3d_info$(EXE) rayCastGL$(EXE) interactive_viewpoint$(EXE) visibility_mesh$(EXE) point_view$(EXE) smooth_normals$(EXE) rtsc$(EXE)

ifeq ($(UNAME), Linux)
  # linux:
  LIBS += -ltrimesh -ljpeg
endif
ifeq ($(UNAME), Linux64)
  # 64-bit linux:
  LIBS += -ltrimesh -ljpeg
else
  # Mac:
  LIBS += -ltrimesh -ljpeg -framework GLUT -framework OpenGL
endif

default: $(PROGS)

interactive_frustum$(EXE) : $(OBJDIR)/interactive_frustum.o
	$(LINK) $(GLLIBS)

get_3d_info_textures$(EXE) : $(OBJDIR)/get_3d_info_textures.o
	$(LINK) $(GLLIBS)

get_3d_info$(EXE) : $(OBJDIR)/get_3d_info.o
	$(LINK) $(GLLIBS)

rayCastGL$(EXE) : $(OBJDIR)/rayCastGL.o
	$(LINK) $(GLLIBS)

interactive_viewpoint$(EXE) : $(OBJDIR)/interactive_viewpoint.o
	$(LINK) $(GLLIBS)

visibility_mesh$(EXE) : $(OBJDIR)/visibility_mesh.o
	@echo $(UNAME)
	$(LINK) $(GLLIBS)

point_view$(EXE) : $(OBJDIR)/point_view.o
	@echo $(UNAME)
	$(LINK) $(GLLIBS)

smooth_normals$(EXE) : $(OBJDIR)/smooth_normals.o
	@echo $(UNAME)
	$(LINK) $(GLLIBS)

rtsc$(EXE) : $(OBJDIR)/rtsc.o $(OBJDIR)/apparentridge.o
	@echo $(UNAME)
	$(LINK) $(GLLIBS)

clean :
	-rm -f $(OFILES) $(OBJDIR)/Makedepend $(OBJDIR)/*.d
	-rm -rf $(OBJDIR)/ii_files
	-rmdir $(OBJDIR)

spotless : clean
	-rm -f $(PROGS)
	-rmdir $(DESTDIR)

#VERSION = 1.5

#tar:
#	cd .. && tar zcvf rtsc-$(VERSION).tar.gz `find rtsc-$(VERSION) -name 'OBJ*' -prune -o -name CVS -prune -o -type f -print | sort`

#zip:
#	cd .. && find rtsc-$(VERSION) -name 'OBJ*' -prune -o -name CVS -prune -o -print | sort | zip -9 rtsc-$(VERSION).zip -@

