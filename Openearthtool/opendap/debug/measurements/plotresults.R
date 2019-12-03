#!/usr/bin/env r
library(lattice)
results <- read.csv(file="results.txt",dec=".",sep=";")
trellis.device(png,file="plot.png")
bwplot(results$Total ~ results$Server | results$Url)
dev.off()
## post <- read.csv(file="post/results.txt",dec=".",sep=";")
## pre$cat <- "pre"
## post$cat <- "post"
## measurements <- data.frame(Total.time=c(pre$Total.time,post$Total.time), Measurement=factor(c(pre$cat,post$cat), levels=c("post", "pre")))
## test <- t.test(measurements$Total.time ~ measurements$Measurement, paired=F)
## # postscript(, paper="special", family = "ComputerModern")
## # boxplot(measurements$Total.time ~ measurements$Measurement, horizontal=T, col="pink", axes=F, lwd=1, notch=F, boxwex=0.4, main="Response time measurements using curl (lower is better)", xlab="response time [s]", ylab="pre/post patch")

## trellis.device(postscript,file="prepost.ps", width=8, height=3, paper="special", horizontal=F)
## bwplot(measurements$Measurement ~ measurements$Total.time, xlab="response time [s]", ylab="pre/post patch")
## # axis(side=2, at=c(1:2), labels=c("post", "pre"), cex.axis=0.9)
## # axis(side=1, at=seq(0,0.5,0.1), labels=T, cex.axis=0.9)
## # rug(measurements$Total.time)
## dev.off()
