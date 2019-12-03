#Read in raw data
chlorAvolkerak<-file.path("N:/My Documents/Data from Donar/ChlorAVolkerak.xlsx")
ChlorAVolkerak<-readWorksheetFromFile(chlorAvolkerak,sheet=1)

#Convert data into correct format
ChlorAVolkerak$Value <- as.numeric(ChlorAVolkerak$wrd)
ChlorAVolkerak$Date <- as.Date(as.character(ChlorAVolkerak$datum), format = "%Y%m%d")
ChlorAVolkerak$Location <- ChlorAVolkerak$locoms

#Make wide data frame
df <- data.frame(ChlorAVolkerak$Date, ChlorAVolkerak$Location, ChlorAVolkerak$Value)
data <- dcast(df, ChlorAVolkerak.Date ~ ChlorAVolkerak.Location, value.var="ChlorAVolkerak.Value", mean)
subset <- subset(data, as.Date(ChlorAVolkerak.Date) >= "1987-01-01" & as.Date(ChlorAVolkerak.Date)<="2014-01-01")


#reorder columns according to location on map
data1 <- subset[c(1,17,14,15,20,21,4)]
data2 <-log10(data1[,-1])
DM <- data.matrix(data2)
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
pdf("Loglogcorrelationchloravolkerak6.pdf", width=12, height=8)
print(chart.Correlation(DM2,histogram = FALSE,xlim=c(0.1,2), ylim=c(0.1,2))+ 
        mtext(expression(paste("Log10(chlorophyll a concentration (",mu,"g/L))")), 1, line=4)+
        mtext(expression(paste("Log10(chlorophyll a concentration (",mu,"g/L))")), 2, line=3))
dev.off()


#rename colums with spaces
data3 <- data2
colnames(data3)[colnames(data3)=="Molenplaat midden"] <- "Molenplaat.midden"
colnames(data3)[colnames(data3)=="Steenbergen (Roosendaalsevliet)"] <- "Steenbergen"
colnames(data3)[colnames(data3)=="Volkerak, meetplaats 02"] <- "Meetplaats.2"

#remove NAs
data3$test <- data3$Meetplaats.2 + data3$Hellegat
f <- which(data3$test > -999, arr.ind=T)
myfiltereddata   <- data3[f,] 

#linear regression model
mymodel <- lm(Meetplaats.2 ~ Hellegat, data = myfiltereddata)
summary(mymodel)