import std.stdio;

import std.socket;
import std.process;

import std.algorithm;
import std.string;

immutable string recordProgram = "arecord";
immutable string broadcastProgram = "pi_fm_adv";


immutable string frequency = "94.9";
immutable string toneFile = "/usr/share/blueberry/tone.wav";

void main() {
	writeln("BlueberryD Started");
	
	Pid broadcastCommand;
	bool bluetoothConnected = false;

	auto sock = new Socket(AddressFamily.UNIX, SocketType.DGRAM);
	sock.connect(new UnixAddress("/run/blueberry.sock"));
	sock.blocking(false);

	broadcastCommand = spawnShell(broadcastProgram ~ " --freq " ~ frequency 
									~ " --ps AJA-RD --rt \"Ready for connections...\" --audio" ~ toneFile);

	do {
		char[256] buf;
		auto len = sock.receive(buf);

		if (len < 1) {
			// No Data recieved

			if(tryWait(broadcastCommand).terminated) {
				if(bluetoothConnected) {
					// Broadcast command exited, end of stream most likely so the bluetooth device disconnected
					bluetoothConnected = false;

					broadcastCommand = spawnShell(broadcastProgram ~ " --freq " ~ frequency 
									~ " --ps AJA-RD --rt \"Ready for connections...\" --audio" ~ toneFile);
				} else {
					// The tone broadcast crashed for some reason, restart it.
					broadcastCommand = spawnShell(broadcastProgram ~ " --freq " ~ frequency 
									~ " --ps AJA-RD --rt \"Ready for connections...\" --audio" ~ toneFile);
				}
			}
		} else {
			char[] actualData = buf[0..len];

			if(actualData.startsWith("CONNECTED") && !bluetoothConnected) {
				if(!tryWait(broadcastCommand).terminated) {
					executeShell("pkill " ~ broadcastProgram); // Kill broadcast program
				}

				auto devAddress = actualData.split(",")[1];

				writeln("Starting broadcast from device " ~ devAddress);

				// Spawn new broadcast with Bluetooth Stream.

				bluetoothConnected = true;
				broadcastCommand = spawnShell(recordProgram ~ 
										"-f cd -D bluealsa:DEV=" ~ devAddress ~ ",PROFILE=a2dp" 
										~ broadcastProgram ~ " --freq " ~ frequency 
										~ " --ps AJA-RD --rt \"Bluetooth Stream\" --audio -");
			}
		}
	} while(true);
}
