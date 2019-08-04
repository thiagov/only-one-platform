dist: game.exe
	mkdir -p dist && cp love-11.2.0-win32/*.dll love-11.2.0-win32/license.txt game.exe dist/

game.love:
	cd src && zip -9 -r ../game.love .

game.exe: game.love
	cat love-11.2.0-win32/love.exe game.love > game.exe

clean:
	rm -rf dist game.exe game.love
