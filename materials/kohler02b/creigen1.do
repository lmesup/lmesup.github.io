* Erzeugt Datensatz aller generierten Variablen aller Wellen, brutto
version 6.0
clear
set memory 60m

#delimit ;
mkdat
bil84 bil85 bil86 bil87 bil88 bil89 bil90 bil91
 bil92 bil93 bil94 bil95 bil96 bil97
bbil84 bbil85 bbil86 bbil87 bbil88 bbil89 bbil90 bbil91
 bbil92 bbil93 bbil94 bbil95 bbil96 bbil97
bdauer84 bdauer85 bdauer86 bdauer87 bdauer88 bdauer89 bdauer90 bdauer91
 bdauer92 bdauer93 bdauer94 bdauer95 bdauer96 bdauer97
est84 est85 est86 est87 est88 est89 est90 est91
 est92 est93 est94 est95 est96 est97
nie84 nie85 nie86 nie87 nie88 nie89 nie90 nie91
 nie92 nie93 nie94 nie95 nie96 nie97
bstb84 bstb85 bstb86 bstb87 bstb88 bstb89 bstb90 bstb91
 bstb92 bstb93 bstb94 bstb95 bstb96 bstb97
iscb84 iscb85 iscb86 iscb87 iscb88 iscb89 iscb90 iscb91
 iscb92 iscb93 iscb94 iscb95 iscb96 iscb97
bsth84 bsth85 bsth86 bsth87 bsth88 bsth89 bsth90 bsth91
 bsth92 bsth93 bsth94 bsth95 bsth96 bsth97
isch84 isch85 isch86 isch87 isch88 isch89 isch90 isch91
 isch92 isch93 isch94 isch95 isch96 isch97
bstp84 bstp85 bstp86 bstp87 bstp88 bstp89 bstp90 bstp91
 bstp92 bstp93 bstp94 bstp95 bstp96 bstp97
iscp84 iscp85 iscp86 iscp87 iscp88 iscp89 iscp90 iscp91
 iscp92 iscp93 iscp94 iscp95 iscp96 iscp97
bstt84 bstt85 bstt86 bstt87 bstt88 bstt89 bstt90 bstt91
 bstt92 bstt93 bstt94 bstt95 bstt96 bstt97
isct84 isct85 isct86 isct87 isct88 isct89 isct90 isct91
 isct92 isct93 isct94 isct95 isct96 isct97
aus84 aus85 aus86 aus87 aus88 aus89 aus90 aus91
 aus92 aus93 aus94 aus95 aus96 aus97
hhein84 hhein85 hhein86 hhein87 hhein88 hhein89 hhein90 hhein91
 hhein92 hhein93 hhein94 hhein95 hhein96 hhein97
ein84 ein85 ein86 ein87 ein88 ein89 ein90 ein91
 ein92 ein93 ein94 ein95 ein96 ein97
using $soepdir , files(peigen) waves(a b c d e f g h i j k l m n)
netto(-3,-2,-1,0,1,2,3,4,5) keep(gebjahr sex);
#delimit cr

* Zur Arbeitserleichterung
capture program drop umben
program define umben
        version 6.0
        local i 84
        while "`1'" ~= "" {
                ren `1'netto netto`i'
                local i = `i' + 1
                mac shift
        }
end

umben a b c d e f g h i j k l m n

save eigen1, replace

exit