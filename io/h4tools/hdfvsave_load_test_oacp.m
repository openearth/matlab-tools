%HDFVSAVE_LOAD_TEST_OACP  test of hdfvsave and hdfvload
clear S0 S1

fname = 'hdfvsave_tst_oacp.hdf';

S0.A(1).rand = rand(2,3,4);
S0.A(1).a    = rand(4);
S0.A(1).b    = rand(8);
S0.A(1).c2   = ['abc',
                'ABC'];
S0.A(1).e1   =  'abc';           

S0.A(2)      =  S0.A(1);           

S0.B.rand = rand(2,3,4);
S0.B.a    = rand(4);
S0.B.b    = rand(8);
S0.B.c2   = ['defghijklmnopqrstuvw',
             'DEFGHIJKLMNOPQRSTUVW'];
S0.B.e1   =  'defghijklmnopqrstuvw';  

s  = hdfvsave(fname,S0,'c')

S1 = hdfvload(fname)