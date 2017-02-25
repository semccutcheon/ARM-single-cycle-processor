
#set PathSeparator .

set WLFFilename waveform.wlf
log -r /*
log -r testbench/dut/arm/dp/rf/rf


#log -r /* 
run -all
quit
