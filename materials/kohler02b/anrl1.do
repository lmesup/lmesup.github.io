* Fehlercheck 1 Rechts--Links--Schema
version 6.0
clear
set memory 60m

* Retrival
* --------

#delimit ;
mkdat
ap5601 bp7901 cp7901 dp8801 ep7701 fp9301 gp8501 hp9001 ip9001 jp9001 kp9201
       lp9801 mp8401 np9401
ap5602 bp7902 cp7902 dp8802 ep7702 fp9302 gp8502 hp9002 ip9002 jp9002 kp9202
       lp9802 mp8402 np9402
ap5603 bp7903 cp7903 dp8803 ep7703 fp9303 gp8503 hp9003 ip9003 jp9003 kp9203
       lp9803 mp8403 np9403
using $soepdir, files(p) waves(a b c d e f g h i j k l m n) ;
#delimit cr

holrein /*
*/ rl84 rl85 rl86 rl87 rl88 rl89 rl90 rl91 rl92 rl93 rl94 rl95 rl96 rl97 /*
*/ using $soepdir, files(peigen) waves(a b c d e f g h i j k l m n)

* Reshape
* -------

capture program drop umben
    program define umben
        local i 84
        while "`1'" ~= "" {
            ren `1'01 pij`i'
            ren `1'02 pip`i'
            ren `1'03 pii`i'
            local i = `i'+1
            mac shift
        }
    end
umben ap56 bp79 cp79 dp88 ep77 fp93 gp85 hp90 ip90 jp90 kp92 lp98 mp84 np94
keep persnr rl* pi*

* Kontrollen
* ----------

local i 84
while `i' <= 97 {
    tab rl`i' pij`i'
    sort pip`i'
    by pip`i': tab rl`i' pii`i'
    local i = `i'+1
}

exit
