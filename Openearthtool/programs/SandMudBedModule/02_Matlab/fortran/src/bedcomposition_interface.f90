subroutine dbc_version(id,url,prec)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'DBC_VERSION' :: DBC_VERSION
!!--description-----------------------------------------------------------------
!
!    Function: - Obtain version Id and URL
!
!!--declarations----------------------------------------------------------------
    use bdc_module
    use precision, only : fp
    implicit none
    !
    ! Call variables
    !
    character(len=*)             :: id
    character(len=*)             :: url
    integer                      :: prec
    !
    ! Local variables
    !
    type(message_stack)          :: messages
    character(len=message_len)   :: message
!
!! executable statements -------------------------------------------------------
!
    ! Initialize a new message stack
    call initstack(messages)
    ! Obtain bedcomposition module information on stack
    call bedcomposition_module_info(messages)
    ! Retrieve first message from stack: the subversion Id string
    call getmessage(messages,message) ! Id
    id = message(6:len_trim(message)-1)
    ! Retrieve second message from stack: the subversion URL string
    call getmessage(messages,message) ! URL
    url = message(7:len_trim(message)-1)
    ! All messages have been processed, so no need to clean up messages
    prec = fp
end subroutine dbc_version
!
!
!
!==============================================================================
function dbc_new() result (this)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'DBC_NEW' :: DBC_NEW
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    use bdc_module
    implicit none
    !
    ! Call variables
    !
    integer                       :: this   ! object handle
    !
    ! Local variables
    !
    type(message_stack), pointer  :: messages       ! message stack object
    type(bedcomp_data) , pointer  :: bedcomposition ! bed composition object
!
!! executable statements -------------------------------------------------------
!
    this = new_bdc(bedcomposition, messages)
end function dbc_new
!
!
!
!==============================================================================
function dbc_initialize(this) result (istat)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'DBC_INITIALIZE' :: DBC_INITIALIZE
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    use bdc_module
    implicit none
    !
    ! Call variables
    !
    integer         , intent(in)  :: this   ! object handle
    integer                       :: istat  ! status flag
    !
    ! Local variables
    !
    type(message_stack), pointer  :: messages       ! message stack object
    type(bedcomp_data) , pointer  :: bedcomposition ! bed composition object
!
!! executable statements -------------------------------------------------------
!
    istat = get_bdc(this, bedcomposition, messages)
    ! Allocate arrays
    if (istat==0) istat = allocmorlyr(bedcomposition)
end function dbc_initialize
!
!
!
!==============================================================================
function dbc_set_realpar(this,var,rval) result (istat)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'DBC_SET_REALPAR' :: DBC_SET_REALPAR
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    use string_module
    use bdc_module
    use precision
    use message_module
    implicit none
    !
    ! Call variables
    !
    integer         , intent(in)  :: this   ! object handle
    character(len=*), intent(in)  :: var
    real(fp)        , intent(in)  :: rval
    integer                       :: istat  ! status flag
    !
    ! Local variables
    !
    integer:: l
    character(message_len)        :: message
    real(fp)                , pointer   :: prval
    real(fp), dimension(:)  , pointer   :: prarr1d
    real(fp), dimension(:,:), pointer   :: prarr2d
    character(len(var))                 :: localname
    character(100)                      :: bdcname
    type(message_stack)     , pointer   :: messages       ! message stack object
    type(bedcomp_data)      , pointer   :: bedcomposition ! bed composition object
!
!! executable statements -------------------------------------------------------
!
    istat = get_bdc(this, bedcomposition, messages)
    localname = var
    call str_lower(localname)
    select case(localname)
    case ('thickness_of_transport_layer','diffusion_levels')
       if (istat==0) istat = bedcomp_getpointer_realfp(bedcomposition, localname, prarr1d)
       if (istat==0) prarr1d = rval
       message = localname
       call addmessage(messages,message)
        do l=1,10
            write(message,'(e20.4)') prarr1d(l)
            call addmessage(messages,message)
        enddo 
       return
    case ('bfluff0','bfluff1','diffusion_coefficients')
       if (istat==0) istat = bedcomp_getpointer_realfp(bedcomposition, localname, prarr2d)
       if (istat==0) prarr2d = rval
       message = localname
!       call addmessage(messages,message)
!        do l=1,10
!            write(message,'(10e20.4)') prarr2d(:,l)
!            call addmessage(messages,message)
!        enddo 
       return
    case default
       bdcname = localname
    end select
    if (istat==0) istat = bedcomp_getpointer_realfp(bedcomposition, bdcname, prval)
    if (istat==0) prval = rval
end function dbc_set_realpar
!
!
!
!==============================================================================
function dbc_set_realpar1d(this,var,rval) result (istat)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'DBC_SET_REALPAR1D' :: DBC_SET_REALPAR1D
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    use string_module
    use bdc_module
    use precision
    use message_module
    implicit none
    !
    ! Call variables
    !
    integer         , intent(in)  :: this   ! object handle
    character(len=*), intent(in)  :: var
    real(fp), dimension(*)        , intent(in)  :: rval
    integer                       :: istat  ! status flag
    !
    ! Local variables
    !
    integer, pointer::nc
    integer:: l
    character(message_len)        :: message
    real(fp), dimension(:)  , pointer   :: prarr1d
    character(len(var))                 :: localname
    type(message_stack)     , pointer   :: messages       ! message stack object
    type(bedcomp_data)      , pointer   :: bedcomposition ! bed composition object
!
!! executable statements -------------------------------------------------------
!
    istat = get_bdc(this, bedcomposition, messages)
    localname = var
    call str_lower(localname)
    select case(localname)
    case ('thickness_of_transport_layer')
       if (istat==0) istat = bedcomp_getpointer_integer(bedcomposition, 'last_column_number', nc)
       if (istat==0) istat = bedcomp_getpointer_realfp(bedcomposition, localname, prarr1d)
       if (istat==0) prarr1d = rval(1:nc)
!       message = localname
!       call addmessage(messages,message)
!        do l=1,nc
!            write(message,'(e20.4)') prarr1d(l)
!            call addmessage(messages,message)
!        enddo 
       return
    case ('diffusion_levels')
       if (istat==0) istat = bedcomp_getpointer_integer(bedcomposition, 'number_of_diffusion_values', nc)
       if (istat==0) istat = bedcomp_getpointer_realfp(bedcomposition, localname, prarr1d)
       if (istat==0) prarr1d = rval(1:nc)
       return
    end select
end function dbc_set_realpar1d
!
!
!
!==============================================================================
function dbc_set_realpar2d(this,var,rval,a,b) result (istat)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'DBC_SET_REALPAR2D' :: DBC_SET_REALPAR2D
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    use string_module
    use bdc_module
    use precision
    use message_module
    implicit none
    !
    ! Call variables
    !
    integer         , intent(in)  :: this   ! object handle
    character(len=*), intent(in)  :: var
    integer, intent(in)  :: a
    integer, intent(in)  :: b
    real(fp), dimension(a,b)        , intent(in)  :: rval
    integer                       :: istat  ! status flag
    !
    ! Local variables
    !
    integer, pointer::nc
    integer:: l
    character(message_len)        :: message
    real(fp), dimension(:,:)  , pointer   :: prarr2d
    character(len(var))                 :: localname
    type(message_stack)     , pointer   :: messages       ! message stack object
    type(bedcomp_data)      , pointer   :: bedcomposition ! bed composition object
!
!! executable statements -------------------------------------------------------
!
    istat = get_bdc(this, bedcomposition, messages)
    localname = var
    call str_lower(localname)
    select case(localname)
    case ('diffusion_coefficients')
       if (istat==0) istat = bedcomp_getpointer_realfp(bedcomposition, localname, prarr2d)
       if (istat==0) prarr2d = rval
       return
    end select
end function dbc_set_realpar2d
!
!
!
!==============================================================================
function dbc_set_intpar(this,var,ival) result (istat)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'DBC_SET_INTPAR' :: DBC_SET_INTPAR
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    use bdc_module
    use string_module
    implicit none
    !
    ! Call variables
    !
    integer         , intent(in)  :: this   ! object handle
    character(len=*), intent(in)  :: var
    integer         , intent(in)  :: ival
    integer                       :: istat  ! status flag
    !
    ! Local variables
    !
    integer         , pointer     :: pival
    character(len(var))           :: localname
    character(100)                :: bdcname
    type(message_stack), pointer  :: messages       ! message stack object
    type(bedcomp_data) , pointer  :: bedcomposition ! bed composition object
!
!! executable statements -------------------------------------------------------
!
    istat = get_bdc(this, bedcomposition, messages)
    localname = var
    call str_lower(localname)
    select case(localname)
    case ('number_of_columns')
       if (istat==0) istat = bedcomp_getpointer_integer(bedcomposition, 'first_column_number', pival)
       if (istat==0) pival = 1
       bdcname = 'last_column_number'
    case default
       bdcname = localname
    end select
    if (istat==0) istat = bedcomp_getpointer_integer(bedcomposition, bdcname, pival)
    if (istat==0) pival = ival
end function dbc_set_intpar
!
!
!
!==============================================================================
function dbc_get_realpar(this,var,rval) result (istat)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'DBC_GET_REALPAR' :: DBC_GET_REALPAR
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    use string_module
    use bdc_module
    use precision
    implicit none
    !
    ! Call variables
    !
    integer         , intent(in)  :: this   ! object handle
    character(len=*), intent(in)  :: var
    real(fp)        , intent(out) :: rval
    integer                       :: istat  ! status flag
    !
    ! Local variables
    !
    real(fp)        , pointer     :: prval
    character(len(var))           :: localname
    character(100)                :: bdcname
    type(message_stack), pointer  :: messages       ! message stack object
    type(bedcomp_data) , pointer  :: bedcomposition ! bed composition object
!
!! executable statements -------------------------------------------------------
!
    istat = get_bdc(this, bedcomposition, messages)
    localname = var
    call str_lower(localname)
    select case(localname)
    case default
       bdcname = localname
    end select
    if (istat==0) istat = bedcomp_getpointer_realfp(bedcomposition, bdcname, prval)
    if (istat==0) rval = prval
end function dbc_get_realpar
!
!
!
!==============================================================================
function dbc_get_intpar(this,var,ival) result (istat)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'DBC_GET_INTPAR' :: DBC_GET_INTPAR
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    use bdc_module
    use string_module
    implicit none
    !
    ! Call variables
    !
    integer         , intent(in)  :: this   ! object handle
    character(len=*), intent(in)  :: var
    integer         , intent(out) :: ival
    integer                       :: istat  ! status flag
    !
    ! Local variables
    !
    integer         , pointer     :: pival
    character(len(var))           :: localname
    character(100)                :: bdcname
    type(message_stack), pointer  :: messages       ! message stack object
    type(bedcomp_data) , pointer  :: bedcomposition ! bed composition object
!
!! executable statements -------------------------------------------------------
!
    istat = get_bdc(this, bedcomposition, messages)
    localname = var
    call str_lower(localname)
    select case(localname)
    case ('number_of_columns')
       bdcname = 'last_column_number'
    case default
       bdcname = localname
    end select
    if (istat==0) istat = bedcomp_getpointer_integer(bedcomposition, bdcname, pival)
    if (istat==0) ival = pival
end function dbc_get_intpar
!
!
!
!==============================================================================
function dbc_set_fraction_properties(this,sedtyp,sedd50,logsedsig,sedrho,nfrac) result (istat)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'DBC_SET_FRACTION_PROPERTIES' :: DBC_SET_FRACTION_PROPERTIES
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    use bdc_module
    use precision
    implicit none
    !
    ! Call variables
    !
    integer         , intent(in)  :: this   ! object handle
    integer                   , intent(in)  :: nfrac  ! number of fractions
    integer , dimension(nfrac), intent(in)  :: sedtyp
    real(fp), dimension(nfrac), intent(in)  :: sedd50
    real(fp), dimension(nfrac), intent(in)  :: logsedsig
    real(fp), dimension(nfrac), intent(in)  :: sedrho
    integer                       :: istat  ! status flag
    !
    ! Local variables
    !
    integer, pointer :: pnfrac
    type(message_stack), pointer  :: messages       ! message stack object
    type(bedcomp_data) , pointer  :: bedcomposition ! bed composition object
!
!! executable statements -------------------------------------------------------
!
    istat = get_bdc(this, bedcomposition, messages)
    if (istat==0) istat = bedcomp_getpointer_integer(bedcomposition, 'nfrac', pnfrac)
    if (istat/=0) then
       return
    elseif (pnfrac/=nfrac) then
       istat=-1
       return
    endif
    call setbedfracprop(bedcomposition, sedtyp, sedd50, logsedsig, sedrho)
end function dbc_set_fraction_properties
!
!
!
!==============================================================================
function dbc_deposit_mass(this, mass, massfluff, rhosol, dt, morfac, dz, nfrac, npnt) result (istat)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'DBC_DEPOSIT_MASS' :: DBC_DEPOSIT_MASS
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    use precision
    use bdc_module
    implicit none
    !
    ! Call variables
    !
    integer                          , intent(in)  :: nfrac     ! number of fractions
    integer                          , intent(in)  :: npnt      ! number of points
    integer                          , intent(in)  :: this      ! object handle
    real(fp)                         , intent(in)  :: dt        !  time step, units : s
    real(fp)                         , intent(in)  :: morfac    !  morphological scale factor, units : -
    real(fp), dimension(nfrac)       , intent(in)  :: rhosol    !  density of sediment fractions, units : kg/m3
    real(fp), dimension(nfrac,npnt)  , intent(in)  :: mass      ! mass of sediment to be deposited
    real(fp), dimension(nfrac,npnt)  , intent(in)  :: massfluff ! mass of sediment to be deposited in fluff layer
    real(fp), dimension(npnt)        , intent(out) :: dz        ! resulting bed level change
    integer                                        :: istat     ! status flag
    !
    ! Local variables
    !
    character(len=message_len)   :: message
    type(message_stack), pointer  :: messages       ! message stack object
    type(bedcomp_data) , pointer  :: bedcomposition ! bed composition object
!
!! executable statements -------------------------------------------------------
!
    istat = get_bdc(this, bedcomposition, messages)
    !
    istat = updmorlyr(bedcomposition, mass, massfluff, rhosol, dt, morfac, dz, messages)
end function dbc_deposit_mass
!
!
!
!==============================================================================
function dbc_remove_thickness(this, mass, dz, nfrac, npnt) result (istat)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'DBC_REMOVE_THICKNESS' :: DBC_REMOVE_THICKNESS
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    use precision
    use bdc_module
    implicit none
    !
    ! Call variables
    !
    integer                          , intent(in)   :: nfrac  ! number of fractions
    integer                          , intent(in)   :: npnt   ! number of points
    integer                          , intent(in)   :: this   ! object handle
    real(fp), dimension(nfrac,npnt)  , intent(out)  :: mass   ! mass of sediment removed
    real(fp), dimension(npnt)        , intent(in)   :: dz     ! sediment thickness to be removed
    integer                                         :: istat  ! status flag
    !
    ! Local variables
    !
    type(message_stack), pointer  :: messages       ! message stack object
    type(bedcomp_data) , pointer  :: bedcomposition ! bed composition object
!
!! executable statements -------------------------------------------------------
!
    istat = get_bdc(this, bedcomposition, messages)
    ! Initialize a new message stack
    istat = gettoplyr(bedcomposition, dz, mass, messages  )
end function dbc_remove_thickness
!
!
!
!==============================================================================
function dbc_get_layer(this, val, var, fracs, layers, points, nfrac, nlayers, npnt) result (istat)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'DBC_GET_LAYER' :: DBC_GET_LAYER
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    use precision
    use bdc_module
    use string_module
    implicit none
    !
    ! Call variables
    !
    integer                                 , intent(in)    :: this     ! object handle
    integer                                 , intent(in)    :: nfrac    ! number of fractions requested
    integer                                 , intent(in)    :: nlayers  ! number of layers requested
    integer                                 , intent(in)    :: npnt     ! number of points requested
    integer , dimension(nfrac)              , intent(in)    :: fracs    ! fractions for which mass is requested
    integer , dimension(nlayers)            , intent(in)    :: layers   ! layers for which mass is requested
    integer , dimension(npnt)               , intent(in)    :: points   ! points for which mass is requested
    real(fp), dimension(nfrac,nlayers,npnt) , intent(out)   :: val      ! return values of variable
    character(*)                            , intent(in)    :: var      ! variable name
    integer                                                 :: istat    ! status flag
    !
    ! Local variables
    !
    character(len(var))           :: localname
    integer :: il
    integer :: ik
    integer :: inm
    integer :: l
    integer :: k
    integer :: nm
    integer, pointer :: nfractot
    real(fp) :: sedtot
    integer                   , pointer :: flufflyr
    real(fp), dimension(:,:,:), pointer :: msed
    real(fp), dimension(:,:), pointer :: mfluff
    real(fp), dimension(:,:), pointer :: svfrac
    real(fp), dimension(:,:), pointer :: thlyr
    real(fp), dimension(:), pointer :: dens
    type(message_stack), pointer  :: messages       ! message stack object
    type(bedcomp_data) , pointer  :: bedcomposition ! bed composition object
!
!! executable statements -------------------------------------------------------
!
    istat = get_bdc(this, bedcomposition, messages)
    if (istat==0) istat = bedcomp_getpointer_integer(bedcomposition, 'number_of_fractions', nfractot)
    if (istat==0) istat = bedcomp_getpointer_realfp(bedcomposition, 'layer_mass', msed)
    if (istat==0) istat = bedcomp_getpointer_integer(bedcomposition, 'flufflayer_model_type', flufflyr)
    if (flufflyr>0) then
        if (istat==0) istat = bedcomp_getpointer_realfp(bedcomposition, 'flufflayer_mass', mfluff)
    endif
    if (istat==0) istat = bedcomp_getpointer_realfp(bedcomposition, 'solid_volume_fraction', svfrac)
    if (istat==0) istat = bedcomp_getpointer_realfp(bedcomposition, 'layer_thickness', thlyr)
    if (istat==0) istat = bedcomp_getpointer_realfp(bedcomposition, 'sediment_density', dens)
    if (istat/=0) return
    !
    localname = var
    call str_lower(localname)
    if (localname=='volume_fractions') then
       do inm = 1,npnt
          nm = points(inm)
          do ik = 1,nlayers
             k = layers(ik)
             do il = 1,nfrac
                l = fracs(il)
                if (thlyr(k,nm)>0.0_fp) then
                   val(il,ik,inm) = msed(l, k, nm)/(dens(l)*svfrac(k, nm)*thlyr(k, nm))
                else
                   val(il,ik,inm) = 0.0_fp
                endif
             enddo
          enddo
       enddo
    elseif (localname=='mass_fractions') then
       do inm = 1,npnt
          nm = points(inm)
          do ik = 1,nlayers
             k = layers(ik)
             sedtot = 0.0_fp
             do l = 1, nfractot
                sedtot = sedtot + msed(l, k, nm)
             enddo
             do il = 1,nfrac
                l = fracs(il)
                if (sedtot>0.0_fp) then
                   val(il,ik,inm) = msed(l, k, nm)/sedtot
                else
                   val(il,ik,inm) = 0.0_fp
                endif
             enddo
          enddo
       enddo
    elseif (localname=='mass') then
       do inm = 1,npnt
          nm = points(inm)
          do ik = 1,nlayers
             k = layers(ik)
             do il = 1,nfrac
                l = fracs(il)
                val(il,ik,inm) = msed(l, k, nm)
             enddo
          enddo
       enddo
    elseif (localname=='massfluff') then
       do inm = 1,npnt
          nm = points(inm)
          do il = 1,nfrac
             l = fracs(il)
             val(il,1,inm) = mfluff(l, nm)
          enddo
       enddo
    elseif (localname=='thickness') then
       do inm = 1,npnt
          nm = points(inm)
          do ik = 1,nlayers
             k = layers(ik)
             val(1,ik,inm) = thlyr(k, nm)
          enddo
       enddo
    elseif (localname=='porosity') then
       do inm = 1,npnt
          nm = points(inm)
          do ik = 1,nlayers
             k = layers(ik)
             val(1,ik,inm) = 1.0_fp - svfrac(k, nm)
          enddo
       enddo
    else
       istat = -1
    endif
end function dbc_get_layer!
!
!
!==============================================================================
function dbc_set_layer(this, val, var, fracs, layers, points, nfrac, nlayers, npnt) result (istat)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'DBC_SET_LAYER' :: DBC_SET_LAYER
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    use precision
    use bdc_module
    use string_module
    implicit none
    !
    ! Call variables
    !
    integer                                 , intent(in)    :: this     ! object handle
    integer                                 , intent(in)    :: nfrac    ! number of fractions requested
    integer                                 , intent(in)    :: nlayers  ! number of layers requested
    integer                                 , intent(in)    :: npnt     ! number of points requested
    integer , dimension(nfrac)              , intent(in)    :: fracs    ! fractions for which mass is requested
    integer , dimension(nlayers)            , intent(in)    :: layers   ! layers for which mass is requested
    integer , dimension(npnt)               , intent(in)    :: points   ! points for which mass is requested
    real(fp), dimension(nfrac,nlayers,npnt) , intent(out)   :: val      ! return values of variable
    character(*)                            , intent(in)    :: var      ! variable name
    integer                                                 :: istat    ! status flag
    !
    ! Local variables
    !
    character(len(var))           :: localname
    integer :: il
    integer :: ik
    integer :: inm
    integer :: l
    integer :: k
    integer :: nm
    integer, pointer :: nfractot
    real(fp) :: sedtot
    integer                   , pointer :: flufflyr
    real(fp), dimension(:,:,:), pointer :: msed
    real(fp), dimension(:,:), pointer :: mfluff
    real(fp), dimension(:,:), pointer :: svfrac
    real(fp), dimension(:,:), pointer :: thlyr
    real(fp), dimension(:), pointer :: dens
    type(message_stack), pointer  :: messages       ! message stack object
    type(bedcomp_data) , pointer  :: bedcomposition ! bed composition object
!
!! executable statements -------------------------------------------------------
!
    istat = get_bdc(this, bedcomposition, messages)
    if (istat==0) istat = bedcomp_getpointer_integer(bedcomposition, 'number_of_fractions', nfractot)
    if (istat==0) istat = bedcomp_getpointer_realfp(bedcomposition, 'layer_mass', msed)
    if (istat==0) istat = bedcomp_getpointer_integer(bedcomposition, 'flufflayer_model_type', flufflyr)
    if (flufflyr>0) then
        if (istat==0) istat = bedcomp_getpointer_realfp(bedcomposition, 'flufflayer_mass', mfluff)
    endif
    if (istat==0) istat = bedcomp_getpointer_realfp(bedcomposition, 'solid_volume_fraction', svfrac)
    if (istat==0) istat = bedcomp_getpointer_realfp(bedcomposition, 'layer_thickness', thlyr)
    if (istat==0) istat = bedcomp_getpointer_realfp(bedcomposition, 'sediment_density', dens)
    if (istat/=0) return
    !
    localname = var
    call str_lower(localname)
    if (localname=='volume_fractions') then
       do inm = 1,npnt
          nm = points(inm)
          do ik = 1,nlayers
             k = layers(ik)
             do il = 1,nfrac
                l = fracs(il)
                if (thlyr(k,nm)>0.0_fp) then
                   msed(l, k, nm) = val(il,ik,inm) *dens(l)*svfrac(k, nm)*thlyr(k, nm)
                else
                   msed(l, k, nm) = 0.0_fp
                endif
             enddo
          enddo
       enddo
    elseif (localname=='mass_fractions') then
       do inm = 1,npnt
          nm = points(inm)
          do ik = 1,nlayers
             k = layers(ik)
             sedtot = 0.0_fp
             do l = 1, nfractot
                sedtot = sedtot + msed(l, k, nm)
             enddo
             do il = 1,nfrac
                l = fracs(il)
                if (sedtot>0.0_fp) then
                   val(il,ik,inm) = msed(l, k, nm)/sedtot
                else
                   val(il,ik,inm) = 0.0_fp
                endif
             enddo
          enddo
       enddo
    elseif (localname=='mass') then
       do inm = 1,npnt
          nm = points(inm)
          do ik = 1,nlayers
             k = layers(ik)
             do il = 1,nfrac
                l = fracs(il)
                msed(l, k, nm) = val(il,k,inm)
             enddo
          enddo
       enddo
    elseif (localname=='massfluff') then
       do inm = 1,npnt
          nm = points(inm)
          do il = 1,nfrac
             l = fracs(il)
             mfluff(l, nm) = val(il,1,inm)
          enddo
       enddo
    elseif (localname=='thickness') then
       do inm = 1,npnt
          nm = points(inm)
          do ik = 1,nlayers
             k = layers(ik)
             thlyr(k, nm) = val(1,ik,inm)
          enddo
       enddo
    elseif (localname=='porosity') then
       do inm = 1,npnt
          nm = points(inm)
          do ik = 1,nlayers
             k = layers(ik)
             svfrac(k, nm) = 1.0_fp - val(1,ik,inm)
          enddo
       enddo
    else
       istat = -1
    endif
end function dbc_set_layer
!
!
!
!==============================================================================
function dbc_messages(this) result(istat)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'DBC_MESSAGES' :: DBC_MESSAGES
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    use bdc_module
    use message_module
    implicit none
    !
    ! Call variables
    !
    integer         , intent(in)  :: this   ! object handle
    integer                       :: istat  ! status flag
!    character(*)    , intent(in)  :: filename
    !
    ! Local variables
    !
    character(message_len)        :: message
    type(message_stack), pointer  :: messages       ! message stack object
    type(bedcomp_data) , pointer  :: bedcomposition ! bed composition object
    integer                       :: unit
!
!! executable statements -------------------------------------------------------
!
    istat = get_bdc(this, bedcomposition, messages)
    unit = 88;
    open (unit, file = 'messages.txt')
    call writemessages(messages,unit)
    close(unit)
end function dbc_messages
!
!
!
!==============================================================================
function dbc_timestep(this) result (istat)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'DBC_TIMESTEP' :: DBC_TIMESTEP
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    use bdc_module
    implicit none
    !
    ! Call variables
    !
    integer         , intent(in)  :: this   ! object handle
    integer                       :: istat  ! status flag
    !
    ! Local variables
    !
    type(message_stack), pointer  :: messages       ! message stack object
    type(bedcomp_data) , pointer  :: bedcomposition ! bed composition object
!
!! executable statements -------------------------------------------------------
!
    istat = get_bdc(this, bedcomposition, messages)
end function dbc_timestep
!
!
!
!==============================================================================
function dbc_finalize(this) result (istat)
!DEC$ ATTRIBUTES DLLEXPORT, ALIAS: 'DBC_FINALIZE' :: DBC_FINALIZE
!!--description-----------------------------------------------------------------
!
!    Function: - 
!
!!--declarations----------------------------------------------------------------
    use bdc_module
    implicit none
    !
    ! Call variables
    !
    integer         , intent(in)  :: this   ! object handle
    integer                       :: istat  ! status flag
    !
    ! Local variables
    !
!
!! executable statements -------------------------------------------------------
!
    istat = destroy_bdc(this)
end function dbc_finalize
