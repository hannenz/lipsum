VALAC = valac
PRG=lipsum
DOCKLET_PRG=libdocklet-lipsum.so
PACKAGES = gtk+-3.0 plank
CFLAGS = `$(PKGCONFIG) --cflags $(PACKAGES)`
LIBS = `$(PKGCONFIG) --libs $(PACKAGES)`
VALAFLAGS = $(patsubst %, --pkg %, $(PACKAGES))  -X -fPIC -X -shared --library=$(DOCKLET_PRG)
RESOURCES=data/styles/global.css

# SRC=$(wildcard src/*.vala src/Widgets/*.vala)
SRC=src/Lipsum.vala\
	src/Generator.vala\
	src/Application.vala\
	src/Widgets/Window.vala

DOCKLET_SOURCES=$(wildcard src/docklet/*.vala) src/Generator.vala


$(PRG): $(SRC) resources.c
	$(VALAC) -o $@ --pkg gio-2.0 --pkg gtk+-3.0 --pkg gmodule-2.0 $(SRC) resources.c


docklet: $(DOCKLET_SOURCES) resources.c
	glib-compile-resources src/docklet/lipsum.gresource.xml --target=resources.c --generate-source
	$(VALAC) -o $(DOCKLET_PRG) $(DOCKLET_SOURCES) resources.c $(VALAFLAGS)


resources.c: $(RESOURCES) data/de.hannenz.lipsum.gresource.xml data/ui/window.ui data/ui/popover.ui
	 glib-compile-resources data/de.hannenz.lipsum.gresource.xml --target=resources.c --generate-source


install:
	cp $(PRG) /usr/local/bin/
	cp libdocklet-lipsum.so /usr/lib/x86_64-linux-gnu/plank/docklets/
	cp data/de.hannenz.lipsum.gschema.xml /usr/share/glib-2.0/schemas/ && glib-compile-schemas /usr/share/glib-2.0/schemas/


uninstall:
	rm -f /usr/local/bin/$(PRG)
	rm -f /usr/lib/x86_64-linux-gnu/plank/docklets/libdocklet-lipsum.so
	rm -f  /usr/share/glib-2.0/schemas/data/de.hannenz.lipsum.gschema.xml && glib-compile-schemas /usr/share/glib-2.0/schemas/


clean:
	rm -f $(PRG)
	rm -f $(DOCKLET_PRG)


distclean:
	rm -f src/*.vala.c
