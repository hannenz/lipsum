VALAC = valac
PRG=lipsum
DOCKLET_PRG=libdocklet-lipsum.so
PACKAGES = gtk+-3.0 plank
CFLAGS = `$(PKGCONFIG) --cflags $(PACKAGES)`
LIBS = `$(PKGCONFIG) --libs $(PACKAGES)`
VALAFLAGS = $(patsubst %, --pkg %, $(PACKAGES))  -X -fPIC -X -shared --library=$(DOCKLET_PRG)

SRC=$(wildcard src/*.vala src/Widgets/*.vala)
DOCKLET_SOURCES=$(wildcard src/docklet/*.vala) src/generator.vala


$(PRG): $(SRC) data/de.hannenz.lipsum.gresource.xml
	glib-compile-resources data/de.hannenz.lipsum.gresource.xml --target=resources.c --generate-source
	$(VALAC) -o $@ --pkg gio-2.0 --pkg gtk+-3.0 --pkg gmodule-2.0 $(SRC) resources.c


docklet: $(DOCKLET_SOURCES)
	glib-compile-resources src/docklet/lipsum.gresource.xml --target=resources.c --generate-source
	$(VALAC) -o $(DOCKLET_PRG) $(DOCKLET_SOURCES) resources.c $(VALAFLAGS)

schema: data/de.hannenz.lipsum.gschema.xml
	cp data/de.hannenz.lipsum.gschema.xml /usr/share/glib-2.0/schemas/ && glib-compile-schemas --targetdir /usr/share/glib-2.0/schemas/ data/


install:
	cp $(PRG) /usr/local/bin/
	if [ ! -e /usr/local/share/lipsum ] ; then mkdir /usr/local/share/lipsum ; fi
	cp src/lipsum.glade /usr/local/share/lipsum/
	cp libdocklet-lipsum.so /usr/lib/x86_64-linux-gnu/plank/docklets/

clean:
	rm $(PRG)
	rm $(DOCKLET)

distclean: clean
	rm -f *.vala.c
