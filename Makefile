VALAC = valac
PRG=lipsum
DOCKLET_PRG=libdocklet-lipsum.so
PACKAGES = gtk+-3.0 plank
CFLAGS = `$(PKGCONFIG) --cflags $(PACKAGES)`
LIBS = `$(PKGCONFIG) --libs $(PACKAGES)`
VALAFLAGS = $(patsubst %, --pkg %, $(PACKAGES))  -X -fPIC -X -shared --library=$(DOCKLET_PRG)
RESOURCES=data/styles/global.css\
		  data/de.hannenz.lipsum.gresource.xml\
		  data/ui/menu.ui\
		  data/ui/window.ui\
		  data/ui/popover.ui


# SRC=$(wildcard src/*.vala src/Widgets/*.vala)
SRC=src/Lipsum.vala\
	src/Generator.vala\
	src/Application.vala\
	src/Widgets/Window.vala

DOCKLET_SOURCES=$(wildcard src/Docklet/*.vala) src/Generator.vala


$(PRG): $(SRC) resources.c
	$(VALAC) -o $@ --pkg gio-2.0 --pkg gtk+-3.0 --pkg gmodule-2.0 $(SRC) resources.c


docklet: $(DOCKLET_SOURCES) resources.c
	$(VALAC) -o $(DOCKLET_PRG) $(DOCKLET_SOURCES) resources.c $(VALAFLAGS)


resources.c: $(RESOURCES)
	 glib-compile-resources data/de.hannenz.lipsum.gresource.xml --target=resources.c --generate-source


install:
	# Install binary / executable
	cp $(PRG) /usr/local/bin/
	# Install docklet
	cp libdocklet-lipsum.so /usr/lib/x86_64-linux-gnu/plank/docklets/
	# Install schema
	cp data/de.hannenz.lipsum.gschema.xml /usr/share/glib-2.0/schemas/ && glib-compile-schemas /usr/share/glib-2.0/schemas/
	# Install desktop file and icon
	cp data/lipsum.desktop /usr/share/applications/
	# cp data/icons/lipsum.png /usr/share/icons/hicolor/16x16/apps/
	# cp data/icons/lipsum.png /usr/share/icons/hicolor/24x24/apps/
	# cp data/icons/lipsum.png /usr/share/icons/hicolor/32x32/apps/
	# cp data/icons/lipsum.png /usr/share/icons/hicolor/48x48/apps/
	# cp data/icons/lipsum.png /usr/share/icons/hicolor/64x64/apps/
	# cp data/icons/lipsum.png /usr/share/icons/hicolor/128x128/apps/
	# gtk-update-icon-cache -f /usr/share/icons/hicolor/


uninstall:
	rm -f /usr/local/bin/$(PRG)
	rm -f /usr/lib/x86_64-linux-gnu/plank/docklets/libdocklet-lipsum.so
	rm -f  /usr/share/glib-2.0/schemas/data/de.hannenz.lipsum.gschema.xml && glib-compile-schemas /usr/share/glib-2.0/schemas/
	# rm /usr/share/icons/hicolor/16x16/apps/lipsum.png
	# rm /usr/share/icons/hicolor/24x24/apps/lipsum.png
	# rm /usr/share/icons/hicolor/32x32/apps/lipsum.png
	# rm /usr/share/icons/hicolor/48x48/apps/lipsum.png
	# rm /usr/share/icons/hicolor/64x64/apps/lipsum.png
	# rm /usr/share/icons/hicolor/128x128/apps/lipsum.png


clean:
	rm -f $(PRG)
	rm -f $(DOCKLET_PRG)
	rm -f resources.c


distclean:
	rm -f src/*.vala.c
