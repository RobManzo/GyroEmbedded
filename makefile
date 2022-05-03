EMBEDDED: utils.f gpio.f i2c.f gyro.f hdmi.f
	rm merged.f
	cat utils.f >> merged.f
	cat gpio.f >> merged.f
	cat i2c.f >> merged.f
	cat gyro.f >> merged.f
	cat hdmi.f >> merged.f
	sudo picocom --b 115200 /dev/ttyUSB0 --imap delbs -s "ascii-xfr -sv -l100 -c10"