#Read in raw data
chlorAvolkerak<-file.path("D:/My Documents/Data from Donar/ChlorAVolkerak.xlsx")
ChlorAVolkerak<-readWorksheetFromFile(chlorAvolkerak,sheet=1)

spmvolkerak<-file.path("D:/My Documents/Data from Donar/SPMVolkerak.xlsx")
SPMVolkerak<-readWorksheetFromFile(spmvolkerak,sheet=1)

secchivolkerak<-file.path("D:/My Documents/Data from Donar/SecchiVolkerak.xlsx")
SecchiVolkerak<-readWorksheetFromFile(secchivolkerak,sheet=1)

evolkerak<-file.path("D:/My Documents/Data from Donar/EVolkerak.xlsx")
EVolkerak<-readWorksheetFromFile(evolkerak,sheet=1)

#grvolkerak<-file.path("D:/My Documents/Data from Donar/GRVolkerak.xlsx")
#GRVolkerak<-readWorksheetFromFile(grvolkerak,sheet=1)

#pocvolkerak<-file.path("D:/My Documents/Data from Donar/POCVolkerak.xlsx")
#POCVolkerak<-readWorksheetFromFile(pocvolkerak,sheet=1)

#docvolkerak<-file.path("D:/My Documents/Data from Donar/DOCVolkerak.xlsx")
#DOCVolkerak<-readWorksheetFromFile(docvolkerak,sheet=1)

#Convert data into correct format
ChlorAVolkerak$Value <- as.numeric(ChlorAVolkerak$wrd)
ChlorAVolkerak$Date <- as.Date(as.character(ChlorAVolkerak$datum), format = "%Y%m%d")
ChlorAVolkerak$Year<-as.POSIXlt(ChlorAVolkerak$Date)$year+1900
ChlorAVolkerak$Mon <-as.POSIXlt(ChlorAVolkerak$Date)$mon+1
ChlorAVolkerak$Location <- ChlorAVolkerak$locoms
ChlorAVolkerak$Parameter <- c("Log10(chlorophyll a (ug/L))")

SPMVolkerak$Value <- as.numeric(SPMVolkerak$wrd)
SPMVolkerak$Date <- as.Date(as.character(SPMVolkerak$datum), format = "%Y%m%d")
SPMVolkerak$Year<-as.POSIXlt(SPMVolkerak$Date)$year+1900
SPMVolkerak$Mon <-as.POSIXlt(SPMVolkerak$Date)$mon+1
SPMVolkerak$Location <- SPMVolkerak$locoms
SPMVolkerak$Parameter <- c("Log10(SPM (mg/L))")

#GRVolkerak$Value <- as.numeric(GRVolkerak$wrd)
#GRVolkerak$Date <- as.Date(as.character(GRVolkerak$datum), format = "%Y%m%d")
#GRVolkerak$Year<-as.POSIXlt(GRVolkerak$Date)$year+1900
#GRVolkerak$Mon <-as.POSIXlt(GRVolkerak$Date)$mon+1
#GRVolkerak$Location <- GRVolkerak$locoms
#GRVolkerak$Parameter <- GRVolkerak$parcod

SecchiVolkerak$Value <- as.numeric(SecchiVolkerak$wrd)
SecchiVolkerak$Date <- as.Date(as.character(SecchiVolkerak$datum), format = "%Y%m%d")
SecchiVolkerak$Year<-as.POSIXlt(SecchiVolkerak$Date)$year+1900
SecchiVolkerak$Mon <-as.POSIXlt(SecchiVolkerak$Date)$mon+1
SecchiVolkerak$Location <- SecchiVolkerak$locoms
SecchiVolkerak$Parameter <- c("Log10(Secchi depth(dm))")

EVolkerak$Value <- as.numeric(EVolkerak$wrd)
EVolkerak$Date <- as.Date(as.character(EVolkerak$datum), format = "%Y%m%d")
EVolkerak$Year<-as.POSIXlt(EVolkerak$Date)$year+1900
EVolkerak$Mon <-as.POSIXlt(EVolkerak$Date)$mon+1
EVolkerak$Location <- EVolkerak$locoms
EVolkerak$Parameter <- c("Log10(Kd(m-1))")

#POCVolkerak$Value <- as.numeric(POCVolkerak$wrd)
#POCVolkerak$Date <- as.Date(as.character(POCVolkerak$datum), format = "%Y%m%d")
#POCVolkerak$Year<-as.POSIXlt(POCVolkerak$Date)$year+1900
#POCVolkerak$Mon <-as.POSIXlt(POCVolkerak$Date)$mon+1
#POCVolkerak$Location <- POCVolkerak$locoms
#POCVolkerak$Parameter <- POCVolkerak$parcod

#DOCVolkerak$Value <- as.numeric(DOCVolkerak$wrd)
#DOCVolkerak$Date <- as.Date(as.character(DOCVolkerak$datum), format = "%Y%m%d")
#DOCVolkerak$Year<-as.POSIXlt(DOCVolkerak$Date)$year+1900
#DOCVolkerak$Mon <-as.POSIXlt(DOCVolkerak$Date)$mon+1
#DOCVolkerak$Location <- DOCVolkerak$locoms
#DOCVolkerak$Parameter <- DOCVolkerak$parcod


#Make dataframes for data to plot
dfChlorA <- data.frame(ChlorAVolkerak$Date,ChlorAVolkerak$Value, ChlorAVolkerak$Location, ChlorAVolkerak$Parameter)
dfSPM <- data.frame(SPMVolkerak$Date,SPMVolkerak$Value, SPMVolkerak$Location, SPMVolkerak$Parameter)
#dfGR <- data.frame(GRVolkerak$Date,GRVolkerak$Value, GRVolkerak$Location, GRVolkerak$Parameter)
dfSecchi <- data.frame(SecchiVolkerak$Date,SecchiVolkerak$Value, SecchiVolkerak$Location, SecchiVolkerak$Parameter)
#dfE <- data.frame(EVolkerak$Date,EVolkerak$Value, EVolkerak$Location, EVolkerak$Parameter)
#dfPOC <- data.frame(POCVolkerak$Date,POCVolkerak$Value, POCVolkerak$Location,POCVolkerak$Parameter)
#dfDOC <- data.frame(DOCVolkerak$Date,DOCVolkerak$Value, DOCVolkerak$Location,DOCVolkerak$Parameter)


#Make subsets of dataframes
ChlorAOesterdam <- subset(dfChlorA, ChlorAVolkerak$Location == "Oesterdam" & ChlorAVolkerak$Value > 10)
SPMOesterdam <- subset(dfSPM, SPMVolkerak$Location == "Oesterdam")
#GROesterdam <- subset(dfGR, GRVolkerak$Location == "Oesterdam")
SecchiOesterdam <- subset(dfSecchi, SecchiVolkerak$Location == "Oesterdam")
EOesterdam <- subset(dfE, EVolkerak$Location == "Oesterdam")
#POCOesterdam <- subset(dfPOC, POCVolkerak$Location == "Oesterdam")
#DOCOesterdam <- subset(dfDOC, DOCVolkerak$Location == "Oesterdam")


colnames(ChlorAOesterdam) <- colnames(SPMOesterdam) <- colnames(SecchiOesterdam)<- colnames(EOesterdam)<-c("Date","Value","Location","Parameter")
total <-rbind.data.frame(ChlorAOesterdam, SPMOesterdam, SecchiOesterdam)

#Make wide data frame
df <- data.frame(total$Date, total$Parameter, total$Value)
data <- dcast(df, total.Date ~ total.Parameter, value.var="total.Value", mean)
subset <- subset(data, as.Date(total.Date) >= "1987-01-01" & as.Date(total.Date)<="2014-01-01")
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
pdf("Loglog3differentparametersvolkerak.pdf", width=12, height=8)
print(chart.Correlation(DM2,histogram = FALSE)+ 
        mtext("Log10(different parameters measured at location Oesterdam, lake Volkerak-Zoom)", 1, line=4)+
        mtext("Log10(different parameters measured at location Oesterdam, lake Volkerak-Zoom)", 2, line=3))
dev.off()

#remove NAs
subset$test <- subset$ChlorA + subset$SPM
f <- which(subset$test > -999, arr.ind=T)
myfiltereddata   <- subset[f,] 

#linear regression model
mymodel <- lm(SPM ~ ChlorA, data = myfiltereddata)
summary(mymodel)