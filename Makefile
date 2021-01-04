VALAC = valac
PRG = de.hannenz.lipsum
DOCKLET=libdocklet-lipsum.so
PACKAGES = gtk+-3.0 plank
VALAFLAGS = $(patsubst %, --pkg %, $(PACKAGES))  -X -fPIC -X -shared --library=$(DOCKLET)
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


.PHONY: clean distclean


$(PRG): $(SRC) resources.c
	$(VALAC) -X -DGETTEXT_PACKAGE="\"lipsum\"" -o $@ --pkg gio-2.0 --pkg gtk+-3.0 --pkg gmodule-2.0 $(SRC) resources.c


$(DOCKLET): $(DOCKLET_SRC) resources.c
	$(VALAC) -o $(DOCKLET) $(DOCKLET_SRC) resources.c $(VALAFLAGS)


resources.c: $(RESOURCES)
	 glib-compile-resources data/de.hannenz.lipsum.gresource.xml --target=resources.c --generate-source


po/de/lipsum.mo: po/de/lipsum.po
	msgfmt --output-file=$@ $<

po/de/lipsum.po: po/lipsum.pot
	msgmerge --update $@ $<

po/lipsum.pot: data/ui/menu.ui data/ui/window.ui data/ui/popover.ui
	xgettext --join-existing --language=Glade --sort-output --output=po/lipsum.pot data/ui/*

all: $(PRG) $(DOCKLET) po/de/lipsum.mo


docklet: $(DOCKLET)


install:
	install -m 755 $(PRG) /usr/local/bin/
	install -m 644 libdocklet-lipsum.so /usr/lib/x86_64-linux-gnu/plank/docklets/
	install -m 644 data/lipsum.desktop /usr/share/applications/
	install -m 644 data/de.hannenz.lipsum.gschema.xml /usr/share/glib-2.0/schemas/
	install -m 644 po/de/LC_MESSAGES/lipsum.mo /usr/share/locale/de/LC_MESSAGES/
	glib-compile-schemas /usr/share/glib-2.0/schemas/


uninstall:
	rm -f /usr/local/bin/$(PRG)
	rm -f /usr/lib/x86_64-linux-gnu/plank/docklets/libdocklet-lipsum.so
	rm -f  /usr/share/glib-2.0/schemas/data/de.hannenz.lipsum.gschema.xml && glib-compile-schemas /usr/share/glib-2.0/schemas/


clean:
	rm -f $(PRG)
	rm -f $(DOCKLET)
	rm -f resources.c
	rm -f ($PRG).vapi
	rm -f ($DOCKLET).vapi


distclean:
	rm -f src/*.vala.c
