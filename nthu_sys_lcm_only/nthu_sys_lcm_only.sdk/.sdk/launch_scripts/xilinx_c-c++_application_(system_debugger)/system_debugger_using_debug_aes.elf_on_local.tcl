connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~ "microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "RealDigital Boo 887429230357A"} -index 0
rst -processor
targets -set -nocase -filter {name =~ "microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "RealDigital Boo 887429230357A"} -index 0
dow D:/Security/nthu_sys_lcm_only/nthu_sys_lcm_only.sdk/aes/Debug/aes.elf
targets -set -nocase -filter {name =~ "microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "RealDigital Boo 887429230357A"} -index 0
con
