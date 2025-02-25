onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib urbana_opt

do {wave.do}

view wave
view structure
view signals

do {urbana.udo}

run -all

quit -force
