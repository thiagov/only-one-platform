dist: only-one-platform.exe mac
	mkdir -p dist && cp love-11.2.0-win32/*.dll love-11.2.0-win32/license.txt only-one-platform.exe dist/

only-one-platform.love:
	cd src && zip -9 -r ../only-one-platform.love .

only-one-platform.exe: only-one-platform.love
	cat love-11.2.0-win32/love.exe only-one-platform.love > only-one-platform.exe

mac: only-one-platform.love
	cp only-one-platform.love OnlyOnePlatform.app/Contents/Resources/ && zip -9 -r -y only-one-platform.mac.zip OnlyOnePlatform.app/

clean:
	rm -rf dist only-one-platform.exe only-one-platform.love only-one-platform.mac.zip
