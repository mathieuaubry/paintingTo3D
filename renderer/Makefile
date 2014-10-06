UNAME := $(shell uname)

# DEBUG = y
MAKERULESDIR = $(TRIMESHDIR)
INCLUDES = -I$(TRIMESHDIR)/include -I$(INCLUDE) 
LIBDIR = -L$(TRIMESHDIR)/lib.$(UNAME)

include $(MAKERULESDIR)/Makerules
ifeq ($(UNAME),Win32)
  COPTS += -mwindows
endif

SOURCES = get_3d_info_textures.cc
OFILES = $(addprefix $(OBJDIR)/,$(SOURCES:.cc=.o))
PROGS = get_3d_info_textures$(EXE)

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

get_3d_info_textures$(EXE) : $(OBJDIR)/get_3d_info_textures.o
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

