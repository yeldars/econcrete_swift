/* cryptoki.h include file for PKCS #11. */
/* $Revision: 1.4 $ */
/* License to copy and use this software is granted provided that it is
 * identified as "RSA Security Inc. PKCS #11 Cryptographic Token Interface
 * (Cryptoki)" in all material mentioning or referencing this software.
 * License is also granted to make and use derivative works provided that
 * such works are identified as "derived from the RSA Security Inc. PKCS #11
 * Cryptographic Token Interface (Cryptoki)" in all material mentioning or
 * referencing the derived work.

 * RSA Security Inc. makes no representations concerning either the
 * any particular purpose. It is provided "as is" without express or implied
 * warranty of any kind.
 */

/* This is a sample file containing the top level include directives
 */

#ifndef ___CRYPTOKI_H_INC___

#if defined(_WIN32)

	/* Specifies that the function is a DLL entry point. */
	#define CK_IMPORT_SPEC __declspec(dllimport)

	/* Define CRYPTOKI_EXPORTS during the build of cryptoki libraries. Do
	 */

	#ifdef CRYPTOKI_EXPORTS
	#define CK_EXPORT_SPEC __declspec(dllexport)
	#else
	#define CK_EXPORT_SPEC CK_IMPORT_SPEC
	#endif

	/* Ensures the calling convention for Win32 builds */
	#define CK_CALL_SPEC __cdecl

	#define CK_PTR *

	#define CK_DEFINE_FUNCTION(returnType, name) \
	  returnType CK_EXPORT_SPEC CK_CALL_SPEC name

	#define CK_DECLARE_FUNCTION(returnType, name) \

	#define CK_DECLARE_FUNCTION_POINTER(returnType, name) \

	#define CK_CALLBACK_FUNCTION(returnType, name) \

#else
	#define CK_PTR *
	#define CK_DEFINE_FUNCTION(returnType, name) \

	#define CK_DECLARE_FUNCTION(returnType, name) \

	#define CK_DECLARE_FUNCTION_POINTER(returnType, name) \

	#define CK_CALLBACK_FUNCTION(returnType, name) \

#endif
#ifndef NULL_PTR
#endif

//#include "pkcs11kncsa.h"
#include "pkcs11.h"
#if defined(_WIN32)
#endif


#endif /* ___CRYPTOKI_H_INC___ */
