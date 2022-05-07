EMBEDDED: utils.f  hdmi.f
	rm merged.f
	cat utils.f >> merged.f
	cat hdmi.f >> merged.f
	sudo picocom --b 115200 /dev/ttyUSB0 --imap delbs -s "ascii-xfr -sv -l100 -c10"