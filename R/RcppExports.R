# Generated by using Rcpp::compileAttributes() -> do not edit by hand
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

parse_xml <- function(path) {
    .Call(`_pipian_parse_xml`, path)
}

# Register entry points for exported C++ functions
methods::setLoadAction(function(ns) {
    .Call(`_pipian_RcppExport_registerCCallable`)
})
