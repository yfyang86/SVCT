\name{svcopt}
\alias{svcopt}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
svcopt
%%  ~~function to do ... ~~
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
svcopt(formula, data, subset = NULL, nperm = 1e+05, rho = seq(0, 1, length.out = 21), kappa = seq(0, 1, length.out = 21))
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{formula}{
%%     ~~Describe \code{formula} here~~
}
  \item{data}{
%%     ~~Describe \code{data} here~~
}
  \item{subset}{
%%     ~~Describe \code{subset} here~~
}
  \item{nperm}{
%%     ~~Describe \code{nperm} here~~
}
  \item{rho}{
%%     ~~Describe \code{rho} here~~
}
  \item{kappa}{
%%     ~~Describe \code{kappa} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (formula, data, subset = NULL, nperm = 1e+05, rho = seq(0, 
    1, length.out = 21), kappa = seq(0, 1, length.out = 21)) 
{
    formula <- Formula(formula)
    if (is.null(subset)) {
        subset <- 1:nrow(data)
    }
    else {
        subset <- sort(intersect(subset, 1:nrow(data)))
    }
    data <- data[subset, ]
    mf <- model.frame(formula, na.action = na.pass, data = data, 
        lhs = 1:2)
    null.B <- model.part(formula, mf, lhs = 1, rhs = 1, drop = F)
    null.G <- model.part(formula, mf, lhs = 2, rhs = 1, drop = F)
    alt.B <- model.part(formula, mf, lhs = 1, rhs = 1:2, drop = F)
    alt.G <- model.part(formula, mf, lhs = 2, rhs = 1:2, drop = F)
    resp.B <- colnames(null.B)[1]
    covar.B <- colnames(null.B)[-1]
    snp.B <- setdiff(colnames(alt.B), c(resp.B, covar.B))
    resp.G <- colnames(null.G)[1]
    covar.G <- colnames(null.G)[-1]
    snp.G <- setdiff(colnames(alt.G), c(resp.G, covar.G))
    null.G <- null.G[!is.na(null.G[, resp.G]), , drop = F]
    alt.G <- alt.G[!is.na(alt.G[, resp.G]), , drop = F]
    n.B <- nrow(null.B)
    n.G <- nrow(null.G)
    n <- n.B
    X.B <- as.matrix(cbind(Intercept = rep(1, n.B), null.B[, 
        covar.B, drop = F]))
    X.G <- as.matrix(cbind(Intercept = rep(1, n.G), null.G[, 
        covar.G, drop = F]))
    G.B <- as.matrix(alt.B[, snp.B, drop = F])
    G.G <- as.matrix(alt.G[, snp.G, drop = F])
    mdl0.B <- glm(as.formula(paste(resp.B, "~ .")), data = null.B, 
        family = "binomial")
    mdl1.B <- glm(as.formula(paste(resp.B, "~ .")), data = alt.B, 
        family = "binomial")
    mdl0.G <- glm(as.formula(paste(resp.G, "~ .")), data = null.G, 
        family = "gaussian")
    mdl1.G <- glm(as.formula(paste(resp.G, "~ .")), data = alt.G, 
        family = "gaussian")
    y.hat <- mdl0.B$fitted.values
    res.B <- null.B[, resp.B] - y.hat
    A <- y.hat * (1 - y.hat)
    V.B <- t(G.B) \%*\% (A * G.B) - t(G.B) \%*\% (A * X.B) \%*\% solve(t(X.B) \%*\% 
        (A * X.B)) \%*\% t(X.B) \%*\% (A * G.B)
    V.B <- V.B/n.B
    lam.B <- eigen(V.B)$values
    res.G <- null.G[, resp.G] - mdl0.G$fitted.values
    s2 <- sum(res.G^2)/(n.G - ncol(X.G))
    V.G <- (t(G.G) \%*\% G.G - t(G.G) \%*\% X.G \%*\% solve(t(X.G) \%*\% 
        X.G) \%*\% t(X.G) \%*\% G.G)/s2
    V.G <- V.G/n.G
    lam.G <- eigen(V.G)$values
    S.B <- t(G.B) \%*\% res.B/sqrt(n.B)
    S.G <- t(G.G) \%*\% res.G/s2/sqrt(n.G)
    stat.B <- t(S.B) \%*\% S.B
    stat.G <- t(S.G) \%*\% S.G
    stat.BG <- t(S.B) \%*\% S.G
    S.B0 <- rbind(t(S.B), rmvnorm(nperm, sigma = V.B))
    S.G0 <- rbind(t(S.G), rmvnorm(nperm, sigma = V.G))
    x1 <- rowSums(S.B0^2)
    x2 <- rowSums(S.G0^2)
    x3 <- rowSums(S.B0 * S.G0)
    rm(S.B0)
    rm(S.G0)
    gc()
    minp <- rep(nperm + 2, nperm + 1)
    x <- minp
    rx <- minp
    u <- NULL
    for (kappa0 in kappa) {
        for (rho0 in rho) {
            x <- kappa0 * x1 + (1 - kappa0) * x2 + 2 * rho0 * 
                sqrt(kappa0 * (1 - kappa0)) * x3
            rx <- rank(-x, ties = "min")
            u <- c(u, rx[1])
            minp <- pmin(minp, rx)
        }
    }
    pval <- mean(minp <= minp[1])
    min.id <- which(u == min(u))
    k <- 0
    kappa.opt <- NULL
    rho.opt <- NULL
    for (kappa0 in kappa) {
        for (rho0 in rho) {
            k <- k + 1
            if (k \%in\% min.id) {
                kappa.opt <- c(kappa.opt, kappa0)
                rho.opt <- c(rho.opt, rho0)
            }
        }
    }
    pval <- c(VC.Het2 = pval)
    svcopt.obj <- list()
    svcopt.obj$pval <- pval
    svcopt.obj$nperm <- nperm
    svcopt.obj$rho.opt <- mean(rho.opt)
    svcopt.obj$kappa.opt <- mean(kappa.opt)
    class(svcopt.obj) <- "svcopt"
    svcopt.obj
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
