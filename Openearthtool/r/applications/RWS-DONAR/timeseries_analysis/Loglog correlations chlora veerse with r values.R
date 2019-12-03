#Read in raw data
chlorAveerse<-file.path("N:/My Documents/Data from Donar/ChlorAVeerse.xlsx")
ChlorAVeerse<-readWorksheetFromFile(chlorAveerse,sheet=1)

#Convert data into correct format
ChlorAVeerse$Value <- as.numeric(ChlorAVeerse$wrd)
ChlorAVeerse$Date <- as.Date(as.character(ChlorAVeerse$datum), format = "%Y%m%d")
ChlorAVeerse$Location <- ChlorAVeerse$locoms

#Make wide data frame
df <- data.frame(ChlorAVeerse$Date, ChlorAVeerse$Location, ChlorAVeerse$Value)
data <- dcast(df, ChlorAVeerse.Date ~ ChlorAVeerse.Location, value.var="ChlorAVeerse.Value", mean)
subset <- subset(data, as.Date(ChlorAVeerse.Date) >= "1972-01-01" & as.Date(ChlorAVeerse.Date)<="2004-01-01")


#reorder columns according to location on map from West to East
data1 <- subset[c(1,7,8,6,2,5,3,4,9,10)]
data2 <-log10(data1[,-1])
DM <- data.matrix(data2)
DM2 <- DM[complete.cases(DM),]

#rename colums with spaces
data3 <- data2
colnames(data3)[colnames(data3)=="Veersegat dam"] <- "Veersegat.dam"
colnames(data3)[colnames(data3)=="Veere havenmond"] <- "Veere.havenmond"
colnames(data3)[colnames(data3)=="De Piet"] <- "De.Piet"
colnames(data3)[colnames(data3)=="Soelekerkepolder oost"] <- "Soelekerkepolder.oost"
colnames(data3)[colnames(data3)=="Zandkreeksluis binnen"] <- "Zandkreeksluis.binnen"


#make plot

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
pdf("Loglogcorrelationchloraveersebeforekatse.pdf", width=12, height=8)
print(chart.Correlation(DM2,histogram = FALSE,xlim=c(-0.3,2), ylim=c(-0.3,2)) + 
        mtext(expression(paste("Log10(chlorophyll a concentration (",mu,"g/L))")), 1, line=4)+
        mtext(expression(paste("Log10(chlorophyll a concentration (",mu,"g/L))")), 2, line=3))
dev.off()

#remove NAs
data3$test <- data3$Veere.havenmond + data3$De.Piet
f <- which(data3$test > -999, arr.ind=T)
myfiltereddata   <- data3[f,] 

#linear regression model
mymodel <- lm( Veere.havenmond ~ De.Piet, data = myfiltereddata)
summary(mymodel)