VALAC = valac
PRG = de.hannenz.lipsum
DOCKLET = libdocklet-lipsum.so
PACKAGES = gtk+-3.0 plank
VALAFLAGS = $(patsubst %, --pkg %, $(PACKAGES))  -X -fPIC -X -shared --library=$(DOCKLET)

DESTDIR ?= /
PREFIX ?= /usr/local

RESOURCES=\
	data/styles/global.css\
	data/de.hannenz.lipsum.gresource.xml\
	data/ui/menu.ui\
	data/ui/window.ui\
	data/ui/popover.ui


SRC=\
	src/Lipsum.vala\
	src/Generator.vala\
	src/Application.vala\
	src/Widgets/Window.vala

DOCKLET_SRC=\
	src/Docklet/LipsumDockItem.vala\
	src/Docklet/LipsumDocklet.vala\
	src/Docklet/LipsumPreferences.vala\
	src/Generator.vala


.PHONY: clean distclean schemas


$(PRG): $(SRC) resources.c
	$(VALAC) -X -DGETTEXT_PACKAGE="\"lipsum\"" -o $@ --pkg gio-2.0 --pkg gtk+-3.0 --pkg gmodule-2.0 $(SRC) resources.c


$(DOCKLET): $(DOCKLET_SRC) resources.c
	$(VALAC) -X -DGETTEXT_PACKAGE="\"lipsum\"" -o $(DOCKLET) $(DOCKLET_SRC) resources.c $(VALAFLAGS)


resources.c: $(RESOURCES)
	 glib-compile-resources data/de.hannenz.lipsum.gresource.xml --target=resources.c --generate-source


po/de/lipsum.mo: po/de/lipsum.po
	msgfmt --output-file=$@ $<

po/de/lipsum.po: po/lipsum.pot
	msgmerge --update $@ $<

po/lipsum.pot: data/ui/menu.ui data/ui/window.ui data/ui/popover.ui $(SRC) $(DOCKLET_SRC)
	xgettext --join-existing --language=Glade --sort-output --output=po/lipsum.pot data/ui/*
	xgettext --join-existing --language=vala  --sort-output --output=po/lipsum.pot data/ui/* $(SRC) $(DOCKLET_SRC)


all: $(PRG) $(DOCKLET) po/de/lipsum.mo


docklet: $(DOCKLET)


install:
	install -Dm 755 "$(PRG)" "$(DESTDIR)/$(PREFIX)/bin/$(PRG)"
	install -Dm 644 "$(DOCKLET)" "$(DESTDIR)/$(PREFIX)/lib/x86_64-linux-gnu/plank/docklets/$(DOCKLET)"
	install -Dm 644 "data/lipsum.desktop" "$(DESTDIR)/$(PREFIX)/share/applications/lipsum.desktop"
	install -Dm 644 "po/de/lipsum.mo" "$(DESTDIR)/$(PREFIX)/share/locale/de/LC_MESSAGES/lipsum.mo"
	install -Dm 644 "data/$(PRG).gschema.xml" "$(DESTDIR)/$(PREFIX)/share/glib-2.0/schemas/$(PRG).gschema.xml"

	ln -sfr "$(DESTDIR)/$(PREFIX)/bin/$(PRG)" "$(DESTDIR)/$(PREFIX)/bin/lipsum"

	$(MAKE) schemas


uninstall:
	rm -f "$(DESTDIR)/$(PREFIX)/bin/$(PRG)"
	rm -f "$(DESTDIR)/$(PREFIX)/lib/x86_64-linux-gnu/plank/docklets/$(DOCKLET)"
	rm -f "$(DESTDIR)/$(PREFIX)/share/applications/lipsum.desktop"
	rm -f "$(DESTDIR)/$(PREFIX)/share/locale/de/LC_MESSAGES/lipsum.mo"
	rm -f "$(DESTDIR)/$(PREFIX)/share/glib-2.0/schemas/$(PRG).gschema.xml"

	rm -f "$(DESTDIR)/$(PREFIX)/bin/lipsum"

	$(MAKE) schemas


schemas:
	-test -f "$(DESTDIR)/$(PREFIX)/share/glib-2.0/schemas/gschemas.compiled" && \
    	glib-compile-schemas "$(DESTDIR)/$(PREFIX)/share/glib-2.0/schemas/"


clean:
	rm -f "$(PRG)"
	rm -f "$(DOCKLET)"
	rm -f "$(PRG).vapi"
	rm -f "$(DOCKLET).vapi"
	rm -f "resources.c"


distclean:
	rm -f src/*.vala.c
