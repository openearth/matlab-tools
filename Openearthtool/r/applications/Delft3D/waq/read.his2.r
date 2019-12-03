## Script by Ype van der Velde 2011 08 10
## Commented and updated by Fedor Baart 2013 10 04
## Updated by Willem Stolte 2013 11 01 
require("stringr")
read.his2 <- function(filename){
## Open file in binary mode
    zz <- file(filename, "rb")
## Read header lines
    readChar(zz,40)
    readChar(zz,40)
    readChar(zz,40)
    readChar(zz,4)
## reads time origin from Delwaq his file
    timeorigin <- readChar(zz,19)
    readChar(zz,17)
## Read 2 integers
    afm <- readBin(zz,integer(),n=2)
## reserve some memory
    syname <- vector("character",afm[1])
    idump <- vector("integer",afm[2])
    duname <- vector("integer",afm[2])
## Now a row of characters
    for(i in 1:afm[1]){
        syname[i] <- readChar(zz,20)
    }
## Now a few rows of integers and strings
    for(i in 1:afm[2]){
        idump[i] <- readBin(zz,integer(),n=1)
        duname[i] <- readChar(zz,20)
    }

    loc <- seek(zz)
    it <- -1
    itn <- vector("integer",0)
    tel<-0
## Keep reading until we no longer have data
    while(length(it)>0){
        tel<-tel+1
        it<-readBin(zz,integer(),n=1)
        if (length(it)>0){
            itn<-c(itn,it)
            conc<-readBin(zz,"double",n=afm[1]*afm[2],size=4)
        }
    }
## rewind
    seek(zz, where=loc)
    concar <- array(dim=c(length(itn),afm[2],afm[1]))
    for(i in 1:length(itn)){
        it <- readBin(zz,integer(),n=1)
        concar[i,,] <- matrix(readBin(zz,"double",n=afm[1]*afm[2],size=4),nrow=afm[2],ncol=afm[1],byrow=T)
    }
## close file connection
    close(zz)
### adapt date names using timeorigin in his file
    timeorigin <- str_replace_all(timeorigin,"[.]","-")
    itn2 <- as.character(as.POSIXct(x=as.numeric(itn), origin = timeorigin, tz = "GMT"))  
    dimnames(concar) <- list(itn2,str_trim(duname),str_trim(syname))
    return(concar)
}





