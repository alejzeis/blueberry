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
		Thread.sleep(dur!("msecs")(250));

		auto devAddress = executeShell("hcitool con | grep -o -P '(?<=ACL).*(?=handle)'").output.strip();

		if (devAddress.length < 1) {
			// No Device connected

			if(bluetoothConnected) {
				// There was previously a device connected but not anymore
				bluetoothConnected = false;

				executeShell("pkill " ~ broadcastProgram); // Kill broadcast program for bluetooth

				// Restart broadcast with tone to show there is no device connected.
				broadcastCommand = spawnShell(broadcastProgram ~ " --freq " ~ frequency 
										~ " --ps AJA-RD --rt \"Ready for connections...\" --audio " ~ toneFile);
			} else {
				if(tryWait(broadcastCommand).terminated) {
					// Broadcast command crashed, restart it
					broadcastCommand = spawnShell(broadcastProgram ~ " --freq " ~ frequency 
										~ " --ps AJA-RD --rt \"Ready for connections...\" --audio " ~ toneFile);
				}
			}
		} else if (!bluetoothConnected) {
			if(!tryWait(broadcastCommand).terminated) {
				Thread.sleep(dur!("seconds")(3));
				executeShell("pkill " ~ broadcastProgram); // Kill broadcast program
			}

			writeln("Starting broadcast from device " ~ devAddress);

			// Spawn new broadcast with Bluetooth Stream.

			bluetoothConnected = true;
			broadcastCommand = spawnShell(recordProgram ~ 
									" -f cd -D bluealsa:SRV=org.bluealsa,DEV=" ~ devAddress ~ ",PROFILE=a2dp | " 
									~ broadcastProgram ~ " --freq " ~ frequency 
									~ " --ps AJA-RD --rt \"Bluetooth Stream\" --audio -");
		}
	} while(true);
}
