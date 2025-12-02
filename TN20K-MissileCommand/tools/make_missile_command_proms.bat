copy /B 035820-02.h1 + 035821-02.jk1 pgrom0.bin

copy /B 035822-03e.kl1 + 035823-02.ln1 pgrom1.bin

copy /B 035824-02.np1 + 035825-02.r1 pgrom2.bin



make_vhdl_prom pgrom0.bin pgrom0.vhd

make_vhdl_prom pgrom1.bin pgrom1.vhd

make_vhdl_prom pgrom2.bin pgrom2.vhd

make_vhdl_prom 035826-01.l6 L6.vhd



pause

