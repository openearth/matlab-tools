// subroutine eqtran(sig       ,thick     ,kmax      ,ws        ,ltur      , &
//                 & frac      ,sigmol    ,dicww     ,lundia    ,taucr0    , &
//                 & rksrs     ,i2d3d     ,lsecfl    ,spirint   ,suspfrac  , &
//                 & tetacr    ,concin    , &
//                 & dzduu     ,dzdvv     ,ubot      ,tauadd    ,sus       , &
//                 & bed       ,susw      ,bedw      ,espir     ,wave      , &
//                 & scour     ,ubot_from_com        ,camax     ,eps       , &
//                 & iform     ,npar      ,par       ,numintpar ,numrealpar, &
//                 & numstrpar ,dllfunc   ,dllhandle ,intpar    ,realpar   , &
//                 & strpar    , &
// !output:
//                 & aks       ,caks      ,taurat    ,seddif    ,rsedeq    , &
//                 & kmaxsd    ,conc2d    ,sbcu      ,sbcv      ,sbwu      , &
//                 & sbwv      ,sswu      ,sswv      ,dss       ,caks_ss3d , &
//                 & aks_ss3d  ,ust2      ,t_relax   ,error     )
void eqtran(    double *sig       , double *thick     , int    *kmax      , double *ws        , int    *ltur      , 
                double *frac      , double *sigmol    , double *dicww     , int    *lundia    , double *taucr0    , 
                double *rksrs     , int    *i2d3d     , int    *lsecfl    , double *spirint   , bool   *suspfrac  , 
                double *tetacr    , double *concin    , 
                double *dzduu     , double *dzdvv     , double *ubot      , double *tauadd    , double *sus       , 
                double *bed       , double *susw      , double *bedw      , double *espir     , bool   *wave      ,
                bool   *scour     , bool   *ubot_from_com                 , double *camax     , double *eps       ,
                int    *iform     , int    *npar      , double *par       , int    *numintpar , int    *numrealpar,
                int    *numstrpar , char   *dllfunc   , int    *dllhandle , int    *intpar    , double *realpar   ,
                char   *strpar    , 
                double *aks       , double *caks      , double *taurat    , double *seddif    , double *rsedeq    , 
                int    *kmaxsd    , double *conc2d    , double *sbcu      , double *sbcv      , double *sbwu      , 
                double *sbwv      , double *sswu      , double *sswv      , double *dss       , double *caks_ss3d , 
                double *aks_ss3d  , double *ust2      , double *t_relax   , bool   *error     );
