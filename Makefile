CC:=valac
PRG=lipsum

SRC=$(wildcard src/*.vala)


$(PRG): $(SRC)
	$(CC) -o $@ --pkg gio-2.0 --pkg gtk+-3.0 --pkg gmodule-2.0 $^

install:
	cp $(PRG) /usr/local/bin/

clean:
	rm $(PRG)
