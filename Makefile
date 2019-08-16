NAME=blueberry
VERSION=1.2

.PHONY: package
package:
	rm *.deb
	dub clean
	dub build
	fpm -s dir -t deb -n $(NAME) -v $(VERSION) ./bin/blueberryd=/usr/bin/blueberryd ./audio/tone.wav=/usr/share/blueberry/tone.wav ./agent/blueberry-agent.py=/usr/bin/blueberry-agent ./service/blueberry-agent.service=/usr/lib/systemd/system/blueberry-agent.service ./service/blueberryd.service=/usr/lib/systemd/system/blueberryd.service