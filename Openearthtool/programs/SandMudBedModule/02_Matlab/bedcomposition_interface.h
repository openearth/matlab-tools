// subroutine dbc_version(id,url,prec)
void DBC_VERSION(char * id, char * url, int * prec, int lenid, int lenurl);

// function dbc_new() result (this)
int DBC_NEW();

// function dbc_initialize(this) result (istat)
int DBC_INITIALIZE(int * this);

// function dbc_set_realpar(this,var,val) result (istat)
// int DBC_SET_REALPAR(int * this, char * var, float * val, int lenvar);

// function dbc_set_intpar(this,var,ival) result (istat)
int DBC_SET_INTPAR(int * this, char * var, int * ival, int lenvar);

// function dbc_set_realpar(this,var,rval) result (istat)
int DBC_SET_REALPAR(int * this, char * var, double * rval, int lenvar);

// function dbc_set_realpar1d(this,var,rval) result (istat)
int DBC_SET_REALPAR1D(int * this, char * var, double * rval, int lenvar);

// function dbc_set_realpar2d(this,var,rval) result (istat)
int DBC_SET_REALPAR2D(int * this, char * var, double * rval, int * a, int * b, int lenvar);


// function dbc_get_intpar(this,var,ival) result (istat)
int DBC_GET_INTPAR(int * this, char * var, int * ival, int lenvar);

// function dbc_get_realpar(this,var,rval) result (istat)
int DBC_GET_REALPAR(int * this, char * var, double * rval, int lenvar);

// function dbc_set_fraction_properties(this,sedtyp,sedd50,logsedsig,sedrho,nfrac) result (istat)
int DBC_SET_FRACTION_PROPERTIES(int * this, int * sedtyp, double * sedd50, double * logsedsig, double * sedrho, int * nfrac);

// function dbc_deposit_mass(this, mass, massfluff, rhosol, dt, morfac, dz, nfrac, npnt) result (istat)
int DBC_DEPOSIT_MASS(int * this, double * mass, double * massfluff, double * rhosol, double * dt, double * morfac, double * dz, int * nfrac, int * npnt);

// function dbc_remove_thickness(this, mass, dz, nfrac, npnt) result (istat)
int DBC_REMOVE_THICKNESS(int * this, double * mass, double * dz, int * nfrac, int * npnt);

// dbc_get_layer(this, val, var, fracs, layers, points, nfrac, nlayers, npnt) result (istat)
int DBC_GET_LAYER(int * this, double * val, char * var, int * fracs, int * layers, int * points, int * nfrac, int * nlayers, int * npnt, int lenvar);

// dbc_set_layer(this, val, var, fracs, layers, points, nfrac, nlayers, npnt) result (istat)
int DBC_SET_LAYER(int * this, double * val, char * var, int * fracs, int * layers, int * points, int * nfrac, int * nlayers, int * npnt, int lenvar);

// function dbc_messages(this, var) result (istat)
int DBC_MESSAGES(int * this);

// function dbc_finalize(this) result (istat)
int DBC_FINALIZE(int * this);
