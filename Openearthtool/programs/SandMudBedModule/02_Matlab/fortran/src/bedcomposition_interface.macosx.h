// subroutine dbc_version(id,url,prec)
void dbc_version(char * id, char * url, int * prec, int lenid, int lenurl);

// function dbc_new() result (this)
int dbc_new();

// function dbc_initialize(this) result (istat)
int dbc_initialize(int * this);

// function dbc_set_realpar(this,var,val) result (istat)
// int dbc_set_realpar(int * this, char * var, float * val, int lenvar);

// function dbc_set_intpar(this,var,ival) result (istat)
int dbc_set_intpar(int * this, char * var, int * ival, int lenvar);

// function dbc_set_realpar(this,var,rval) result (istat)
int dbc_set_realpar(int * this, char * var, double * rval, int lenvar);

// function dbc_set_realpar1d(this,var,rval) result (istat)
int dbc_set_realpar1d(int * this, char * var, double * rval, int lenvar);

// function dbc_set_realpar2d(this,var,rval) result (istat)
int dbc_set_realpar2d(int * this, char * var, double * rval, int * a, int * b, int lenvar);


// function dbc_get_intpar(this,var,ival) result (istat)
int dbc_get_intpar(int * this, char * var, int * ival, int lenvar);

// function dbc_get_realpar(this,var,rval) result (istat)
int dbc_get_realpar(int * this, char * var, double * rval, int lenvar);

// function dbc_set_fraction_properties(this,sedtyp,sedd50,logsedsig,sedrho,nfrac) result (istat)
int dbc_set_fraction_properties(int * this, int * sedtyp, double * sedd50, double * logsedsig, double * sedrho, int * nfrac);

// function dbc_deposit_mass(this, mass, massfluff, rhosol, dt, morfac, dz, nfrac, npnt) result (istat)
int dbc_deposit_mass(int * this, double * mass, double * massfluff, double * rhosol, double * dt, double * morfac, double * dz, int * nfrac, int * npnt);

// function dbc_remove_thickness(this, mass, dz, nfrac, npnt) result (istat)
int dbc_remove_thickness(int * this, double * mass, double * dz, int * nfrac, int * npnt);

// dbc_get_layer(this, val, var, fracs, layers, points, nfrac, nlayers, npnt) result (istat)
int dbc_get_layer(int * this, double * val, char * var, int * fracs, int * layers, int * points, int * nfrac, int * nlayers, int * npnt, int lenvar);

// dbc_set_layer(this, val, var, fracs, layers, points, nfrac, nlayers, npnt) result (istat)
int dbc_set_layer(int * this, double * val, char * var, int * fracs, int * layers, int * points, int * nfrac, int * nlayers, int * npnt, int lenvar);

// function dbc_messages(this, var) result (istat)
int dbc_messages(int * this);

// function dbc_finalize(this) result (istat)
int dbc_finalize(int * this);
