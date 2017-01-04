show:
	echo 'Run "make install" as root to install program!'
run:
	python3 desktop-layout-picker.py
install: build
	sudo gdebi --no desktop-layout-picker_UNSTABLE.deb
uninstall:
	sudo apt-get purge desktop-layout-picker
installed-size:
	du -sx --exclude DEBIAN ./debian/
build:
	sudo make build-deb;
build-deb:
	mkdir -p debian;
	mkdir -p debian/DEBIAN;
	mkdir -p debian/usr;
	mkdir -p debian/usr/bin;
	mkdir -p debian/usr/share;
	mkdir -p debian/usr/share/desktop-layout-picker;
	mkdir -p debian/usr/share/desktop-layout-picker/layouts;
	mkdir -p debian/usr/share/applications;
	# copy over the files
	cp -vf desktop-layout-picker.py ./debian/usr/bin/desktop-layout-picker
	cp -vf desktop-layout-picker.desktop ./debian/usr/share/applications/desktop-layout-picker.desktop
	# copy over the layouts
	cp -vfr layouts/. ./debian/usr/share/desktop-layout-picker/layouts/
	# make the program executable
	chmod +x ./debian/usr/bin/desktop-layout-picker
	# Create the md5sums file
	find ./debian/ -type f -print0 | xargs -0 md5sum > ./debian/DEBIAN/md5sums
	# cut filenames of extra junk
	sed -i.bak 's/\.\/debian\///g' ./debian/DEBIAN/md5sums
	sed -i.bak 's/\\n*DEBIAN*\\n//g' ./debian/DEBIAN/md5sums
	sed -i.bak 's/\\n*DEBIAN*//g' ./debian/DEBIAN/md5sums
	rm -v ./debian/DEBIAN/md5sums.bak
	# figure out the package size
	du -sx --exclude DEBIAN ./debian/ > Installed-Size.txt
	# copy over package data
	cp -rv debdata/. debian/DEBIAN/
	# fix permissions in package
	chmod -Rv 775 debian/DEBIAN/
	chmod -Rv ugo+r debian/
	chmod -Rv go-w debian/
	chmod -Rv u+w debian/
	# build the package
	dpkg-deb --build debian
	cp -v debian.deb desktop-layout-picker_UNSTABLE.deb
	rm -v debian.deb
	rm -rv debian
project-report:
	sudo apt-get install gitstats gource --assume-yes
	rm -vr report/ || echo "No existing report..."
	mkdir -p report
	mkdir -p report/webstats
	# write the index page
	echo "<html style='margin:auto;width:800px;text-align:center;'><body>" > report/index.html
	echo "<a href='webstats/index.html'><h1>WebStats</h1></a>" >> report/index.html
	echo "<a href='log.html'><h1>Log</h1></a>" >> report/index.html
	echo "<video src='video.mp4' width='800' controls>" >> report/index.html
	echo "<a href='video.mp4'><h1>Gource Video Rendering</h1></a>" >> report/index.html
	echo "</video>" >> report/index.html
	echo "</body></html>" >> report/index.html
	# write the log to a webpage
	echo "<html><body>" > report/log.html
	echo "<h1><a href='index.html'>Back</a></h1>" >> report/log.html
	# generate the log into a variable
	git log --stat > report/logInfo
	echo "<code><pre>" >> report/log.html
	cat report/logInfo >> report/log.html
	echo "</pre></code>" >> report/log.html
	rm report/logInfo
	echo "</body></html>" >> report/log.html
	# generate git statistics
	gitstats -c processes='8' . report/webstats
	# generate a video with gource
	gource --max-files 0 -s 1 -c 4 -1280x720 -o - | avconv -y -r 60 -f image2pipe -vcodec ppm -i - -vcodec libx264 -preset ultrafast -pix_fmt yuv420p -crf 1 -threads 8 -bf 0 report/video.mp4
