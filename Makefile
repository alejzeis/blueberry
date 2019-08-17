NAME=blueberry
VERSION=1.5

.PHONY: package
package:
	rm -f *.deb
	rm -f ./agent/*.pyc
	dub clean
	dub build
	python -m compileall ./agent
	fpm -s dir -t deb -n $(NAME) -v $(VERSION) ./bin/blueberryd=/usr/bin/blueberryd ./audio/tone.wav=/usr/share/blueberry/tone.wav ./agent/blueberry-agent.pyc=/usr/lib/blueberry/agent.pyc ./agent/bluezutils.pyc=/usr/lib/blueberry/bluezutils.pyc ./service/blueberry-agent.service=/usr/lib/systemd/system/blueberry-agent.service ./service/blueberryd.service=/usr/lib/systemd/system/blueberryd.service
