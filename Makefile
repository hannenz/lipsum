CC:=valac
PRG=lipsum

$(PRG): src/lipsum.vala
	$(CC) --pkg gio-2.0 --pkg gtk+-3.0 $<

install:
	cp $(PRG) /usr/local/bin/

clean:
	rm $(PRG)
