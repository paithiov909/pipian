// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#ifndef RCPP_pipian_RCPPEXPORTS_H_GEN_
#define RCPP_pipian_RCPPEXPORTS_H_GEN_

#include <Rcpp.h>

namespace pipian {

    using namespace Rcpp;

    namespace {
        void validateSignature(const char* sig) {
            Rcpp::Function require = Rcpp::Environment::base_env()["require"];
            require("pipian", Rcpp::Named("quietly") = true);
            typedef int(*Ptr_validate)(const char*);
            static Ptr_validate p_validate = (Ptr_validate)
                R_GetCCallable("pipian", "_pipian_RcppExport_validate");
            if (!p_validate(sig)) {
                throw Rcpp::function_not_exported(
                    "C++ function with signature '" + std::string(sig) + "' not found in pipian");
            }
        }
    }

    inline DataFrame parse_xml(const std::string path) {
        typedef SEXP(*Ptr_parse_xml)(SEXP);
        static Ptr_parse_xml p_parse_xml = NULL;
        if (p_parse_xml == NULL) {
            validateSignature("DataFrame(*parse_xml)(const std::string)");
            p_parse_xml = (Ptr_parse_xml)R_GetCCallable("pipian", "_pipian_parse_xml");
        }
        RObject rcpp_result_gen;
        {
            RNGScope RCPP_rngScope_gen;
            rcpp_result_gen = p_parse_xml(Shield<SEXP>(Rcpp::wrap(path)));
        }
        if (rcpp_result_gen.inherits("interrupted-error"))
            throw Rcpp::internal::InterruptedException();
        if (Rcpp::internal::isLongjumpSentinel(rcpp_result_gen))
            throw Rcpp::LongjumpException(rcpp_result_gen);
        if (rcpp_result_gen.inherits("try-error"))
            throw Rcpp::exception(Rcpp::as<std::string>(rcpp_result_gen).c_str());
        return Rcpp::as<DataFrame >(rcpp_result_gen);
    }

}

#endif // RCPP_pipian_RCPPEXPORTS_H_GEN_
