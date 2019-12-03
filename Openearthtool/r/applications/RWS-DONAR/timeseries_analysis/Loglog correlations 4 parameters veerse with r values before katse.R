#Read in raw data
chlorAveerse<-file.path("D:/My Documents/Data from Donar/ChlorAVeerse.xlsx")
ChlorAVeerse<-readWorksheetFromFile(chlorAveerse,sheet=1)

spmveerse<-file.path("D:/My Documents/Data from Donar/SPMVeerse.xlsx")
SPMVeerse<-readWorksheetFromFile(spmveerse,sheet=1)

secchiveerse<-file.path("D:/My Documents/Data from Donar/SecchiVeerse.xlsx")
SecchiVeerse<-readWorksheetFromFile(secchiveerse,sheet=1)

eveerse<-file.path("D:/My Documents/Data from Donar/EVeerse.xlsx")
EVeerse<-readWorksheetFromFile(eveerse,sheet=1)

#grveerse<-file.path("D:/My Documents/Data from Donar/GRVeerse.xlsx")
#GRVeerse<-readWorksheetFromFile(grveerse,sheet=1)

#pocveerse<-file.path("D:/My Documents/Data from Donar/POCVeerse.xlsx")
#POCVeerse<-readWorksheetFromFile(pocveerse,sheet=1)

#docveerse<-file.path("D:/My Documents/Data from Donar/DOCVeerse.xlsx")
#DOCVeerse<-readWorksheetFromFile(docveerse,sheet=1)

#Convert data into correct format
ChlorAVeerse$Value <- as.numeric(ChlorAVeerse$wrd)
ChlorAVeerse$Date <- as.Date(as.character(ChlorAVeerse$datum), format = "%Y%m%d")
ChlorAVeerse$Year<-as.POSIXlt(ChlorAVeerse$Date)$year+1900
ChlorAVeerse$Mon <-as.POSIXlt(ChlorAVeerse$Date)$mon+1
ChlorAVeerse$Location <- ChlorAVeerse$locoms
ChlorAVeerse$Parameter <- c("Log10(chlorophyll a (ug/L))")

SPMVeerse$Value <- as.numeric(SPMVeerse$wrd)
SPMVeerse$Date <- as.Date(as.character(SPMVeerse$datum), format = "%Y%m%d")
SPMVeerse$Year<-as.POSIXlt(SPMVeerse$Date)$year+1900
SPMVeerse$Mon <-as.POSIXlt(SPMVeerse$Date)$mon+1
SPMVeerse$Location <- SPMVeerse$locoms
SPMVeerse$Parameter <- c("Log10(SPM (mg/L))")

#GRVeerse$Value <- as.numeric(GRVeerse$wrd)
#GRVeerse$Date <- as.Date(as.character(GRVeerse$datum), format = "%Y%m%d")
#GRVeerse$Year<-as.POSIXlt(GRVeerse$Date)$year+1900
#GRVeerse$Mon <-as.POSIXlt(GRVeerse$Date)$mon+1
#GRVeerse$Location <- GRVeerse$locoms
#GRVeerse$Parameter <- GRVeerse$parcod

SecchiVeerse$Value <- as.numeric(SecchiVeerse$wrd)
SecchiVeerse$Date <- as.Date(as.character(SecchiVeerse$datum), format = "%Y%m%d")
SecchiVeerse$Year<-as.POSIXlt(SecchiVeerse$Date)$year+1900
SecchiVeerse$Mon <-as.POSIXlt(SecchiVeerse$Date)$mon+1
SecchiVeerse$Location <- SecchiVeerse$locoms
SecchiVeerse$Parameter <- c("Log10(Secchi depth(dm))")

EVeerse$Value <- as.numeric(EVeerse$wrd)
EVeerse$Date <- as.Date(as.character(EVeerse$datum), format = "%Y%m%d")
EVeerse$Year<-as.POSIXlt(EVeerse$Date)$year+1900
EVeerse$Mon <-as.POSIXlt(EVeerse$Date)$mon+1
EVeerse$Location <- EVeerse$locoms
EVeerse$Parameter <- c("Log10(Kd(m-1))")

#POCVeerse$Value <- as.numeric(POCVeerse$wrd)
#POCVeerse$Date <- as.Date(as.character(POCVeerse$datum), format = "%Y%m%d")
#POCVeerse$Year<-as.POSIXlt(POCVeerse$Date)$year+1900
#POCVeerse$Mon <-as.POSIXlt(POCVeerse$Date)$mon+1
#POCVeerse$Location <- POCVeerse$locoms
#POCVeerse$Parameter <- POCVeerse$parcod

#DOCVeerse$Value <- as.numeric(DOCVeerse$wrd)
#DOCVeerse$Date <- as.Date(as.character(DOCVeerse$datum), format = "%Y%m%d")
#DOCVeerse$Year<-as.POSIXlt(DOCVeerse$Date)$year+1900
#DOCVeerse$Mon <-as.POSIXlt(DOCVeerse$Date)$mon+1
#DOCVeerse$Location <- DOCVeerse$locoms
#DOCVeerse$Parameter <- DOCVeerse$parcod


#Make dataframes for data to plot
dfChlorA <- data.frame(ChlorAVeerse$Date,ChlorAVeerse$Value, ChlorAVeerse$Location, ChlorAVeerse$Parameter)
dfSPM <- data.frame(SPMVeerse$Date,SPMVeerse$Value, SPMVeerse$Location, SPMVeerse$Parameter)
#dfGR <- data.frame(GRVeerse$Date,GRVeerse$Value, GRVeerse$Location, GRVeerse$Parameter)
dfSecchi <- data.frame(SecchiVeerse$Date,SecchiVeerse$Value, SecchiVeerse$Location, SecchiVeerse$Parameter)
dfE <- data.frame(EVeerse$Date,EVeerse$Value, EVeerse$Location, EVeerse$Parameter)
#dfPOC <- data.frame(POCVeerse$Date,POCVeerse$Value, POCVeerse$Location,POCVeerse$Parameter)
#dfDOC <- data.frame(DOCVeerse$Date,DOCVeerse$Value, DOCVeerse$Location,DOCVeerse$Parameter)


#Make subsets of dataframes
ChlorASoelekerkepolder<- subset(dfChlorA, ChlorAVeerse$Location == "Soelekerkepolder oost" & ChlorAVeerse$Value > 10)
SPMSoelekerkepolder<- subset(dfSPM, SPMVeerse$Location == "Soelekerkepolder oost")
#GRSoelekerkepolder<- subset(dfGR, GRVeerse$Location == "Soelekerkepolder oost")
SecchiSoelekerkepolder<- subset(dfSecchi, SecchiVeerse$Location == "Soelekerkepolder oost")
ESoelekerkepolder<- subset(dfE, EVeerse$Location == "Soelekerkepolder oost")
#POCSoelekerkepolder<- subset(dfPOC, POCVeerse$Location == "Soelekerkepolder oost")
#DOCSoelekerkepolder<- subset(dfDOC, DOCVeerse$Location == "Soelekerkepolder oost")


colnames(ChlorASoelekerkepolder) <- colnames(SPMSoelekerkepolder) <- colnames(SecchiSoelekerkepolder)<- colnames(ESoelekerkepolder)<- c("Date","Value","Location","Parameter")
total <-rbind.data.frame(ChlorASoelekerkepolder, SPMSoelekerkepolder,SecchiSoelekerkepolder,ESoelekerkepolder)

#Make wide data frame
df <- data.frame(total$Date, total$Parameter, total$Value)
data <- dcast(df, total.Date ~ total.Parameter, value.var="total.Value", mean)
subset <- subset(data, as.Date(total.Date) >= "1972-07-01" & as.Date(total.Date)<="2004-07-01")
subset2 <-log10(subset[,-1])

#make data matrix
DM <- data.matrix(subset2)
DM2 <- DM[complete.cases(DM),]

## Correlation matrix with p-values. See http://goo.gl/nahmV for documentation of this function
cor.prob <- function (X, dfr = nrow(X) - 2) {
  R <- cor(X, use="pairwise.complete.obs")
  above <- row(R) < col(R)
  r2 <- R[above]^2
  Fstat <- r2 * dfr/(1 - r2)
  R[above] <- 1 - pf(Fstat, 1, dfr)
  R[row(R) == col(R)] <- NA
  R
}

## Use this to dump the cor.prob output to a 4 column matrix
## with row/column indices, correlation, and p-value.
## See StackOverflow question: http://goo.gl/fCUcQ
flattenSquareMatrix <- function(m) {
  if( (class(m) != "matrix") | (nrow(m) != ncol(m))) stop("Must be a square matrix.") 
  if(!identical(rownames(m), colnames(m))) stop("Row and column names must be equal.")
  ut <- upper.tri(m)
  data.frame(i = rownames(m)[row(m)[ut]],
             j = rownames(m)[col(m)[ut]],
             cor=t(m)[ut],
             p=m[ut])
}


# correlation matrix
cor(DM2,use="pairwise.complete.obs")

# correlation matrix with p-values
cor.prob(DM2)

# "flatten" that table
flattenSquareMatrix(cor.prob(DM2))

#correlation functions
chart.Correlation <-
  function (R, histogram = TRUE, method="pearson", ...)
  { # @author R Development Core Team
    # @author modified by Peter Carl
    # Visualization of a Correlation Matrix. On top the (absolute) value of the
    # correlation plus the result of the cor.test as stars. On botttom, the
    # bivariate scatterplots, with a fitted line
    
    x = checkData(R, method="matrix")
    
    if(missing(method)) method=method[1] #only use one
    
    # Published at http://addictedtor.free.fr/graphiques/sources/source_137.R
    panel.cor <- function(x, y, digits=2, prefix="", use="pairwise.complete.obs", method, cex.cor, ...)
    {
      usr <- par("usr"); on.exit(par(usr))
      par(usr = c(0, 1, 0, 1))
      r <- cor(x, y, use=use, method=method) # MG: remove abs here
      txt <- format(c(r, 0.123456789), digits=digits)[1]
      txt <- paste(prefix, txt, sep="")
      if(missing(cex.cor)) cex <- 0.8/strwidth(txt)
      
      test <- cor.test(x,y, method=method)
      # borrowed from printCoefmat
      Signif <- symnum(test$p.value, corr = FALSE, na = FALSE,
                       cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1),
                       symbols = c("***", "**", "*", ".", " "))
      # MG: add abs here and also include a 30% buffer for small numbers
      text(0.5, 0.5, txt, cex = cex * (abs(r) + .3) / 1.3)
      text(.8, .8, Signif, cex=cex, col=2)
    }
    
    f <- function(t) {
      dnorm(t, mean=mean(x), sd=sd.xts(x) )
    }
    hist.panel = function (x, ...) {
      par(new = TRUE)
      hist(x,
           col = "light gray",
           probability = TRUE,
           axes = FALSE,
           main = "",
           breaks = "FD")
      lines(density(x, na.rm=TRUE),
            col = "red",
            lwd = 1)
      #lines(f, col="blue", lwd=1, lty=1) how to add gaussian normal overlay?
      rug(x)
    }
    panel.lm<-
      function (x, y, col = par("col"), bg = NA, pch = par("pch"),
                cex = 1, col.lm = "red", lwd=par("lwd"), ...)
      {
        points(x, y, pch = pch, col = col, bg = bg, cex = cex)
        ok <- is.finite(x) & is.finite(y)
        if (any(ok))
          abline(lm(y~x,subset=ok), col = col.lm, ...)
      }
    # Draw the chart
    if(histogram)
      pairs(x, gap=0, lower.panel=panel.lm, upper.panel=panel.cor, diag.panel=hist.panel, method=method, ...)
    else
      pairs(x, gap=0, lower.panel=panel.lm, upper.panel=panel.cor, method=method, ...) 
  }


# plot the data
#save plot in pdf
pdf("Loglogdifferentparametersveerse4before.pdf", width=12, height=8)
print(chart.Correlation(DM2,histogram = FALSE)+ 
        mtext("Log10(different parameters measured at location Soelekerkepolder oost, lake Veere)", 1, line=4)+
        mtext("Log10(different parameters measured at location Soelekerkepolder oost, lake Veere)", 2, line=3))
dev.off()

#remove NAs
subset$test <- subset$ChlorA + subset$SPM
f <- which(subset$test > -999, arr.ind=T)
myfiltereddata   <- subset[f,] 

#linear regression model
mymodel <- lm(SPM ~ ChlorA, data = myfiltereddata)
summary(mymodel)