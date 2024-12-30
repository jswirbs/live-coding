/*
This is an example startup file. You can load it from your startup file
(to be found in Platform.userAppSupportDir +/+ "startup.scd")
*/


(
s.reboot { // server options are only updated on reboot
	Server.killAll();
	// configure the sound server: here you could add hardware specific options
	// see http://doc.sccode.org/Classes/ServerOptions.html
	s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
	s.options.memSize = 8192 * 32; // increase this if you get "alloc failed" messages
	// s.options.numWireBufs = 64; // increase this if you get "exceeded number of interconnect buffers" messages
	s.options.numWireBufs = 128; // ***** increasing as I got some "exceeded number of interconnect buffers" messages
	s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
	s.options.numOutputBusChannels = 2; // set this to your hardware output channel size, if necessary
	s.options.numInputBusChannels = 2; // set this to your hardware output channel size, if necessary

	// blackhole as output, comment out to use default out
	s.options.outDevice_("BlackHole 2ch");

	// boot the server and start SuperDirt
	s.waitForBoot {
		~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels
		~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
		// for example: ~dirt.loadSoundFiles("/Users/myUserName/Dirt/samples/*");
		~dirt.loadSoundFiles("~/Library/Application Support/SuperCollider/downloaded-quarks/Custom-samples/*"); // specify sample folder to load
		// s.sync; // optionally: wait for samples to be read
		~dirt.start(57120, 0 ! 12);   // start listening on port 57120, create two busses each sending audio to channel 0


		// optional, needed for convenient access from sclang:
		(
			~d1 = ~dirt.orbits[0]; ~d2 = ~dirt.orbits[1]; ~d3 = ~dirt.orbits[2];
			~d4 = ~dirt.orbits[3]; ~d5 = ~dirt.orbits[4]; ~d6 = ~dirt.orbits[5];
			~d7 = ~dirt.orbits[6]; ~d8 = ~dirt.orbits[7]; ~d9 = ~dirt.orbits[8];
			~d10 = ~dirt.orbits[9]; ~d11 = ~dirt.orbits[10]; ~d12 = ~dirt.orbits[11];
		);


		// MIDI connecting to Ableton Live through Audio MIDI Setup ports
		//
		// following https://tidalcycles.org/SuperDirt_MIDI_Tutorial and
		// https://www.youtube.com/watch?v=cdB0dBGiar4&ab_channel=DanDerks

		MIDIClient.init;

		/*~midiTb3Out = MIDIOut.newByName("TB-3", "TB-3");
		~midiTb3Out.latency = 0;
		~dirt.soundLibrary.addMIDI(\tb3, ~midiTb3Out);*/

		~midi1Out = MIDIOut.newByName("IAC Driver", "Tidal1");
		~midi1Out.latency = 0;
		~dirt.soundLibrary.addMIDI(\m1, ~midi1Out);

		~midi2Out = MIDIOut.newByName("IAC Driver", "Tidal2");
		~midi2Out.latency = 0;
		~dirt.soundLibrary.addMIDI(\m2, ~midi2Out);

		~midi3Out = MIDIOut.newByName("IAC Driver", "Tidal3");
		~midi3Out.latency = 0;
		~dirt.soundLibrary.addMIDI(\m3, ~midi3Out);

		~midi4Out = MIDIOut.newByName("IAC Driver", "Tidal4");
		~midi4Out.latency = 0;
		~dirt.soundLibrary.addMIDI(\m4, ~midi4Out);

		~midi5Out = MIDIOut.newByName("IAC Driver", "Tidal5");
		~midi5Out.latency = 0;
		~dirt.soundLibrary.addMIDI(\m5, ~midi5Out);

		~midi6Out = MIDIOut.newByName("IAC Driver", "Tidal6");
		~midi6Out.latency = 0;
		~dirt.soundLibrary.addMIDI(\m6, ~midi6Out);

		/*~lc = LinkClock.new.latency_(Server.default.latency);
		~lc.numPeers;
		~ltmc = LinkToMidiClock(~midiTb3Out, ~lc);
		~ltmc.start;
		// ~ltmc.stop;*/
	};

	s.latency = 0.1; // increase this if you get "late" messages

	// https://github.com/calumgunn/StageMaster/tree/master
	StageMaster.activate(numChannels: 2, compThreshold: 0.7, limiterLevel: 1.0, highEndDb: 2.0);
	// StageMaster.deactivate;
};

// Start Tidal clock popup
this.executeFile("/Users/justinswirbul/Library/Application\ Support/SuperCollider/tidal_clock_popup.scd");

);


MIDIClient.init;