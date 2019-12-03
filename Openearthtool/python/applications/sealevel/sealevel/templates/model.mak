## Inputs
library(plyr)
startyear <- ${startyear}
endyear <- ${endyear}
station.name <- "${station}"

model <- as.character("${model}")

#model == "linear"
polynomial <- ${polynomial}
nodal <- ${nodal}
wind <- ${wind}

#model == "loess"
span <- ${span}
polynomial_loess <- ${polynomial_loess}

# corrections
ib <- ${ib}
gia <- ${gia}


## Define the model
dependent <- "waterlevel"

independent <- c("1")
if (polynomial > 0) {
    ## Use non orthogonal polynomials.
    independent <- c(independent, sprintf("poly(year,degree=%d, raw=TRUE)", polynomial))
}



if (nodal) {
    independent <- c(independent, "A", "B")
}


## Load the stations into memory
if (!("stations.l" %in% ls()))
    {
        load("sealevel/static/data/stations.l.rdata")
    }

station.l <- stations.l[[station.name]]



## Calculations
##  Fill the data frame
df <- data.frame(
    waterlevel=station.l$h,
    year=station.l$y,
    A = sin(2 * pi * station.l$y/18.613),
    B = cos(2 * pi * station.l$y/18.613),
    peltier = station.l$peltier,
    ib = station.l$ib,
    u2 = station.l$u2,
    v2 = station.l$v2
    )
# fill missings
na.fill <- colwise(function(d){d[is.na(d)] <- mean(d,na.rm=TRUE);return(d)})
df <- na.fill(df)

if (wind) {
    independent <- c(independent, "u2", "v2")
}

if (ib) {
    df$waterlevel <- df$waterlevel - df$ib
}

if (gia) {
    df$waterlevel <- df$waterlevel - df$peltier*(df$year - 2004)
}


## Select time window in dataframe
df.selected <- subset(df, df$year>=startyear & df$year<=endyear )


## Fit the statistical model
if (model == "linear") {
    model <- as.formula(paste(
        paste0(dependent, " ~ "),
        paste(independent, collapse= "+")))
    fit <- lm(model, df.selected)
} else {
    model <- waterlevel ~ year
    ## Don't bother include covariates
    fit <- loess(model, df.selected, span=span, degree=polynomial_loess)
}


t <- seq(startyear, endyear)

## Only works for lm
newdata <- data.frame(
    waterlevel=t,
    year=t,
    A = sin(2 * pi * t/18.613),
    B = cos(2 * pi * t/18.613)
    )

if (wind) {
    ## Add u,v components, replace by means where we don't know
    newdata = join(
        newdata,
        data.frame(year=station.l$y, u2=station.l$u2, v2=station.l$v2),
        by=c("year")
        )
    newdata$u2[is.na(newdata$u2)] <- mean(newdata$u2, na.rm=TRUE)
    newdata$v2[is.na(newdata$v2)] <- mean(newdata$v2, na.rm=TRUE)
}
if (ib) {
    newdata = join(
        newdata,
        data.frame(year=station.l$y, p=station.l$ib),
        by=c("year")
        )
    newdata$p[is.na(newdata$p)] <- mean(newdata$p, na.rm=TRUE)
}




## Do some predictions
df.selected$predicted <- predict(fit)

if (class(fit) == "loess") {
    pred <- predict(fit, se=TRUE, newdata=newdata)
    conf.int <- data.frame(
        year=newdata$year,
        confidence.fit=pred$fit,
        confidence.lwr=pred$fit + qt(0.025, pred$df),
        confidence.lwr=pred$fit + qt(0.975, pred$df)
        )

    ## TODO, check how to compute these.....
    pred.int <- data.frame(
        year=newdata$year,
        confidence.fit=pred$fit,
        confidence.lwr=pred$fit + qt(0.025, pred$df) * pred$residual.scale,
        confidence.lwr=pred$fit + qt(0.975, pred$df) * pred$residual.scale
        )

} else {
    conf.int <- as.data.frame(predict(fit, interval="confidence", newdata=newdata))
    conf.int <- cbind(data.frame(year=newdata$year), conf.int)
    pred.int <- as.data.frame(predict(fit, interval="prediction", newdata=newdata))
    pred.int <- cbind(data.frame(year=newdata$year), pred.int)

}
colnames(conf.int) <- c("year", "confidence.fit", "confidence.lwr", "confidence.upr")
colnames(pred.int) <- c("year", "prediction.fit", "prediction.lwr", "prediction.upr")
## Combine and return data
merged <- join_all(list(pred.int, conf.int, df, df.selected[c("year", "predicted")]), by=c("year"), type="full")
merged <- merged[order(merged$year),]
list(df=merged, summary=summary(fit))
