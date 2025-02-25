TEST CASE      || Delay(Cycle) || DATA RATE(TX)  || DATA RATE(RX)  || ERROR CASE
===============================================================================================
test_use_vec1  || TX) 100      || valid = 1      || valid = 1 or 0 || no
test_use_vec2  || TX) 100      || valid = 1 or 0 || valid = 1      || no
test_use_vec3  || no           || valid = 1 or 0 || valid = 1 or 0 || no
test_use_vec4  || RX) 100      || valid = 1      || valid = 1      || no
test_use_vec5  || RX) 100      || valid = 1      || valid = 1      || yes, overflow (TX test length is more than checker length) 
