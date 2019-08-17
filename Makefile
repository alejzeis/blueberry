NAME=blueberry
VERSION=1.4

.PHONY: package
package:
	rm -f *.deb
	dub clean
	dub build
	fpm -s dir -t deb -n $(NAME) -v $(VERSION) ./bin/blueberryd=/usr/bin/blueberryd ./audio/tone.wav=/usr/share/blueberry/tone.wav ./agent/blueberry-agent.py=/usr/lib/blueberry/agent.py ./agent/bluezutils.py=/usr/lib/blueberry/bluezutils.py ./service/blueberry-agent.service=/usr/lib/systemd/system/blueberry-agent.service ./service/blueberryd.service=/usr/lib/systemd/system/blueberryd.service
