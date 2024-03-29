% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dose-response-analysis.R
\name{fl.drFit}
\alias{fl.drFit}
\title{Fit a biosensor model (Meyer et al., 2019) to response vs. concentration data}
\usage{
fl.drFit(
  flTable,
  control = fl.control(dr.method = "model", dr.parameter = "max_slope.spline")
)
}
\arguments{
\item{flTable}{A dataframe containing the data for the dose-response model estimation. Such table of class \code{flTable} can be obtained by running \code{\link{flFit}} with \code{dr.method = 'model'} as argument in the \code{fl.control} object.}

\item{control}{A \code{fl.control} object created with \code{\link{fl.control}}, defining relevant fitting options.}

\item{dr.method}{(Character) Perform either a smooth spline fit on response parameter vs. concentration data (\code{'spline'}) or fit a biosensor response model with \code{'model'} (proposed by Meyer et al., 2019).}

\item{dr.parameter}{(Character or numeric) The response parameter in the output table to be used for creating a dose response curve. See \code{\link{fl.drFit}} for further details. Default: \code{'max_slope.spline'}, which represents the maximum slope of the spline fit Typical options include: \code{'max_slope.linfit'}, \code{'dY.linfit'}, \code{'max_slope.spline'}, and \code{'dY.spline'}.}
}
\value{
An object of class \code{drFit}.
\item{raw.data}{Data that passed to the function as \code{flTable}.}
\item{drTable}{Dataframe containing condition identifiers, fit options, and results of the dose-response analysis.}
\item{drFittedModels}{List of all \code{drFitModel} objects generated by the call of \code{\link{fl.drFitModel}} for each distinct experiment.}
\item{control}{Object of class \code{fl.control} created with the call of \code{\link{fl.control}}.}
}
\description{
Fit a biosensor model (Meyer et al., 2019) to response vs. concentration data
}
\details{
Common response parameters used in dose-response analysis:\if{html}{\out{<br>}}\if{html}{\out{<br>}}\if{html}{\out{<b>}}Linear fit:\if{html}{\out{</b>}}\if{html}{\out{<br>}}- max_slope.linfit: Fluorescence increase rate\if{html}{\out{<br>}}- lambda.linfit: Lag time\if{html}{\out{<br>}}- dY.linfit: Maximum Fluorescence - Minimum Fluorescence\if{html}{\out{<br>}}- A.linfit: Maximum fluorescence\if{html}{\out{<br>}}\if{html}{\out{<br>}}\if{html}{\out{<b>}}Spline fit:\if{html}{\out{</b>}}\if{html}{\out{<br>}}- max_slope.spline: Fluorescence increase rate\if{html}{\out{<br>}}- lambda.spline: Lag time\if{html}{\out{<br>}}- dY.spline: Maximum Fluorescence - Minimum Fluorescence\if{html}{\out{<br>}}- A.spline: Maximum fluorescence\if{html}{\out{<br>}}- integral.spline: Integral\if{html}{\out{<br>}}\if{html}{\out{<br>}}\if{html}{\out{<b>}}Parametric fit:\if{html}{\out{</b>}}\if{html}{\out{<br>}}- max_slope.model: Fluorescence increase rate\if{html}{\out{<br>}}- lambda.model: Lag time\if{html}{\out{<br>}}- dY.model: Maximum Fluorescence - Minimum Fluorescence\if{html}{\out{<br>}}- A.model: Maximum fluorescence\if{html}{\out{<br>}}- integral.model: Integral'
}
\examples{
\donttest{
# Load example dataset
input <- read_data(data.fl = system.file('lac_promoters.xlsx', package = 'QurvE'),
                   sheet.fl = 2 )

# Run fluorescence curve analysis workflow
fitres <- flFit(fl_data = input$fluorescence,
                time = input$time,
                parallelize = FALSE,
                control = fl.control(x_type = 'time', norm_fl = FALSE,
                                     suppress.messages = TRUE))

# Perform dose-response analysis
drFit <- fl.drFit(flTable = fitres$flTable,
                  control = fl.control(dr.method = 'model',
                                       dr.parameter = 'max_slope.linfit'))

# Inspect results
summary(drFit)
plot(drFit)
}
}
\references{
Meyer, A.J., Segall-Shapiro, T.H., Glassey, E. et al. \emph{Escherichia coli “Marionette” strains with 12 highly optimized small-molecule sensors.} Nat Chem Biol 15, 196–204 (2019). DOI: 10.1038/s41589-018-0168-3
}
