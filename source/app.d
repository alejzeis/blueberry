import std.stdio;

import core.thread;
import core.time : dur;

void main() {
	writeln("BlueberryD Started");
	do {
		Thread.sleep(dur!("seconds")(2));
	} while(true);
}
