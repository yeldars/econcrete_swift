//
//  XMLSigner.h
//  SSLTESTER
//
//  Created by Dev on 06/02/15.
//  Copyright (c) 2015 STS. All rights reserved.
//

#ifndef SSLTESTER_XMLSigner_h
#define SSLTESTER_XMLSigner_h


NSString * xmlsignersign(NSString * p12path,NSString *xmlToSign,NSString *password,unsigned int isRSA );

NSString * getSubDN (NSString * pkcs12_path, NSString * pin);
    
#endif
