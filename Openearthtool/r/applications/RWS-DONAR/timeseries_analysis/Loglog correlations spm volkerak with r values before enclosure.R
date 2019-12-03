#Read in raw data
spmvolkerak<-file.path("N:/My Documents/Data from Donar/SPMVolkerak.xlsx")
SPMVolkerak<-readWorksheetFromFile(spmvolkerak,sheet=1)

#Convert data into correct format
SPMVolkerak$Value <- as.numeric(SPMVolkerak$wrd)
SPMVolkerak$Date <- as.Date(as.character(SPMVolkerak$datum), format = "%Y%m%d")
SPMVolkerak$Location <- SPMVolkerak$locoms

#Make wide data frame
df <- data.frame(SPMVolkerak$Date, SPMVolkerak$Location, SPMVolkerak$Value)
data <- dcast(df, SPMVolkerak.Date ~ SPMVolkerak.Location, value.var="SPMVolkerak.Value", mean)
subset <- subset(data, as.Date(SPMVolkerak.Date) >= "1972-01-01" & as.Date(SPMVolkerak.Date)<="1987-01-01")


#reorder columns according to location on map
data2 <- subset[c(1,10,7,8,12,14,5)]
data3 <-log10(data2[,-1])
DM <- data.matrix(data3)
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

# plot the data
#save plot in pdf
pdf("Loglogcorrelationspmvolkerakbeforeenclosure.pdf", width=12, height=8)
print(chart.Correlation(DM2,histogram = FALSE,xlim=c(0.1,1.5), ylim=c(0.1,1.5))+ 
        mtext("Log10(SPM concentrations (mg/L))", 1, line=4)+
        mtext("Log10(SPM concentrations (mg/L))", 2, line=3))
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