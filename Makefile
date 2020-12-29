VALAC = valac
PRG=lipsum
DOCKLET_PRG=libdocklet-lipsum.so
PACKAGES = gtk+-3.0 plank
CFLAGS = `$(PKGCONFIG) --cflags $(PACKAGES)`
LIBS = `$(PKGCONFIG) --libs $(PACKAGES)`
VALAFLAGS = $(patsubst %, --pkg %, $(PACKAGES))  -X -fPIC -X -shared --library=$(DOCKLET_PRG)
RESOURCES=data/styles/global.css

# SRC=$(wildcard src/*.vala src/Widgets/*.vala)
SRC=src/lipsum.vala\
	src/generator.vala\
	src/Application.vala\
	src/Widgets/Window.vala

DOCKLET_SOURCES=$(wildcard src/docklet/*.vala) src/generator.vala


$(PRG): $(SRC) resources.c
	$(VALAC) -o $@ --pkg gio-2.0 --pkg gtk+-3.0 --pkg gmodule-2.0 $(SRC) resources.c

resources.c: $(RESOURCES) data/de.hannenz.lipsum.gresource.xml
	 glib-compile-resources data/de.hannenz.lipsum.gresource.xml --target=resources.c --generate-source

docklet: $(DOCKLET_SOURCES)
	glib-compile-resources src/docklet/lipsum.gresource.xml --target=resources.c --generate-source
	$(VALAC) -o $(DOCKLET_PRG) $(DOCKLET_SOURCES) resources.c $(VALAFLAGS)


install:
	cp $(PRG) /usr/local/bin/
	if [ ! -e /usr/local/share/lipsum ] ; then mkdir /usr/local/share/lipsum ; fi
	cp src/lipsum.glade /usr/local/share/lipsum/
	cp libdocklet-lipsum.so /usr/lib/x86_64-linux-gnu/plank/docklets/
	cp data/de.hannenz.lipsum.gschema.xml /usr/share/glib-2.0/schemas/ && glib-compile-schemas /usr/share/glib-2.0/schemas/

uninstall:
	rm -f /usr/local/bin/$(PRG)
	rm -rf /usr/local/share/lipsum
	rm -f /usr/lib/x86_64-linux-gnu/plank/docklets/libdocklet-lipsum.so
	rm -f  /usr/share/glib-2.0/schemas/data/de.hannenz.lipsum.gschema.xml && glib-compile-schemas /usr/share/glib-2.0/schemas/


clean:
	rm $(PRG)
	rm $(DOCKLET)

distclean: clean
	rm -f *.vala.c
