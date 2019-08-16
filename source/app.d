import std.stdio;
import std.process;
import std.algorithm;
import std.string;

import core.thread;

immutable string recordProgram = "arecord";
immutable string broadcastProgram = "pi_fm_adv";


immutable string frequency = "94.9";
immutable string toneFile = "/usr/share/blueberry/tone.wav";

void main() {
	writeln("BlueberryD Started");
	
	Pid broadcastCommand;
	bool bluetoothConnected = false;

	broadcastCommand = spawnShell(broadcastProgram ~ " --freq " ~ frequency 
									~ " --ps AJA-RD --rt \"Ready for connections...\" --audio " ~ toneFile);

	do {
		auto devAddress = executeShell("hcitool con | grep -o -P '(?<=ACL).*(?=handle)'").output.strip();

		if (devAddress.length < 1) {
			// No Device connected

			if(tryWait(broadcastCommand).terminated) {
				if(bluetoothConnected) {
					// Broadcast command exited, end of stream most likely so the bluetooth device disconnected
					bluetoothConnected = false;

					broadcastCommand = spawnShell(broadcastProgram ~ " --freq " ~ frequency 
									~ " --ps AJA-RD --rt \"Ready for connections...\" --audio " ~ toneFile);
				} else {
					// The tone broadcast crashed for some reason, restart it.
					broadcastCommand = spawnShell(broadcastProgram ~ " --freq " ~ frequency 
									~ " --ps AJA-RD --rt \"Ready for connections...\" --audio " ~ toneFile);
				}
			}

			Thread.sleep(dur!("msecs")(250));
		} else {
			if(!tryWait(broadcastCommand).terminated) {
				executeShell("pkill " ~ broadcastProgram); // Kill broadcast program
			}

			writeln("Starting broadcast from device " ~ devAddress);

			// Spawn new broadcast with Bluetooth Stream.

			bluetoothConnected = true;
			broadcastCommand = spawnShell(recordProgram ~ 
									"-f cd -D bluealsa:DEV=" ~ devAddress ~ ",PROFILE=a2dp" 
									~ broadcastProgram ~ " --freq " ~ frequency 
									~ " --ps AJA-RD --rt \"Bluetooth Stream\" --audio -");
		}
	} while(true);
}
