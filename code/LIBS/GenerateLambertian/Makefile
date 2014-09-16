UNAME := $(shell uname)

# DEBUG = y
TRIMESHDIR = ../trimesh2
MAKERULESDIR = $(TRIMESHDIR)
INCLUDES = -I$(TRIMESHDIR)/include -I/usr/local/include
LIBDIR = -L$(TRIMESHDIR)/lib.$(UNAME)
#INCLUDES = -I$(TRIMESHDIR)/include -I../jpeg-8a/src/OUT/include
#LIBDIR = -L$(TRIMESHDIR)/lib.$(UNAME) -L../jpeg-8a/src/OUT/lib

include $(MAKERULESDIR)/Makerules
ifeq ($(UNAME),Win32)
  COPTS += -mwindows
endif

SOURCES = generate_lambertian.cc generate_colored.cc rtsc.cc apparentridge.cc smooth_normals.cc
OFILES = $(addprefix $(OBJDIR)/,$(SOURCES:.cc=.o))
PROGS = point_view$(EXE) visibility_mesh$(EXE) generate_lambertian$(EXE) generate_colored$(EXE) rtsc$(EXE) smooth_normals$(EXE)

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

#LIBS += -ltrimesh -ljpeg -framework GLUT -framework OpenGL

default: $(PROGS)

point_view$(EXE) : $(OBJDIR)/point_view.o
	$(LINK) $(GLLIBS)

visibility_mesh$(EXE) : $(OBJDIR)/visibility_mesh.o
	$(LINK) $(GLLIBS)

generate_colored$(EXE) : $(OBJDIR)/generate_colored.o
	$(LINK) $(GLLIBS)

generate_lambertian$(EXE) : $(OBJDIR)/generate_lambertian.o
	$(LINK) $(GLLIBS)

rtsc$(EXE) : $(OBJDIR)/rtsc.o $(OBJDIR)/apparentridge.o
	$(LINK) $(GLLIBS)

smooth_normals$(EXE) : $(OBJDIR)/smooth_normals.o
	$(LINK) $(GLLIBS)

clean :
	-rm -f $(OFILES) $(OBJDIR)/Makedepend $(OBJDIR)/*.d
	-rm -rf $(OBJDIR)/ii_files
	-rmdir $(OBJDIR)

spotless : clean
	-rm -f $(PROGS)
	-rmdir $(DESTDIR)

VERSION = 1.5

tar:
	cd .. && tar zcvf rtsc-$(VERSION).tar.gz `find rtsc-$(VERSION) -name 'OBJ*' -prune -o -name CVS -prune -o -type f -print | sort`

zip:
	cd .. && find rtsc-$(VERSION) -name 'OBJ*' -prune -o -name CVS -prune -o -print | sort | zip -9 rtsc-$(VERSION).zip -@

