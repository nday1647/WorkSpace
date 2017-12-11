//
// MATLAB Compiler: 6.5 (R2017b)
// Date: Mon Dec 11 20:59:31 2017
// Arguments: "-B""macro_default""-W""cpplib:SUM_a""-T""link:lib""SUM_a.m"
//

#ifndef __SUM_a_h
#define __SUM_a_h 1

#if defined(__cplusplus) && !defined(mclmcrrt_h) && defined(__linux__)
#  pragma implementation "mclmcrrt.h"
#endif
#include "mclmcrrt.h"
#include "mclcppclass.h"
#ifdef __cplusplus
extern "C" {
#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_SUM_a_C_API 
#define LIB_SUM_a_C_API /* No special import/export declaration */
#endif

/* GENERAL LIBRARY FUNCTIONS -- START */

extern LIB_SUM_a_C_API 
bool MW_CALL_CONV SUM_aInitializeWithHandlers(
       mclOutputHandlerFcn error_handler, 
       mclOutputHandlerFcn print_handler);

extern LIB_SUM_a_C_API 
bool MW_CALL_CONV SUM_aInitialize(void);

extern LIB_SUM_a_C_API 
void MW_CALL_CONV SUM_aTerminate(void);

extern LIB_SUM_a_C_API 
void MW_CALL_CONV SUM_aPrintStackTrace(void);

/* GENERAL LIBRARY FUNCTIONS -- END */

/* C INTERFACE -- MLX WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- START */

extern LIB_SUM_a_C_API 
bool MW_CALL_CONV mlxSUM_a(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

/* C INTERFACE -- MLX WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- END */

#ifdef __cplusplus
}
#endif


/* C++ INTERFACE -- WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- START */

#ifdef __cplusplus

/* On Windows, use __declspec to control the exported API */
#if defined(_MSC_VER) || defined(__MINGW64__)

#ifdef EXPORTING_SUM_a
#define PUBLIC_SUM_a_CPP_API __declspec(dllexport)
#else
#define PUBLIC_SUM_a_CPP_API __declspec(dllimport)
#endif

#define LIB_SUM_a_CPP_API PUBLIC_SUM_a_CPP_API

#else

#if !defined(LIB_SUM_a_CPP_API)
#if defined(LIB_SUM_a_C_API)
#define LIB_SUM_a_CPP_API LIB_SUM_a_C_API
#else
#define LIB_SUM_a_CPP_API /* empty! */ 
#endif
#endif

#endif

extern LIB_SUM_a_CPP_API void MW_CALL_CONV SUM_a(int nargout, mwArray& sum, const mwArray& a, const mwArray& b);

/* C++ INTERFACE -- WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- END */
#endif

#endif
