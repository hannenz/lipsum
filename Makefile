CC:=valac
PRG=lipsum

SRC=$(wildcard src/*.vala)


$(PRG): $(SRC)
	$(CC) -o $@ --pkg gio-2.0 --pkg gtk+-3.0 --pkg gmodule-2.0 $^

install:
	cp $(PRG) /usr/local/bin/
	if [ ! -e /usr/local/share/lipsum ] ; then mkdir /usr/local/share/lipsum ; fi
	cp src/lipsum.glade /usr/local/share/lipsum/



clean:
	rm $(PRG)
