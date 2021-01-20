/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */


#import "OOSTransferUtility+HeaderHelper.h"
#import "OOSTransferUtilityTasks.h"

@interface OOSCreateMultipartUploadRequest()
+ (NSValueTransformer *)ACLJSONTransformer;
+ (NSValueTransformer *)storageClassJSONTransformer;
+ (NSValueTransformer *)serverSideEncryptionJSONTransformer;
+ (NSValueTransformer *)requestPayerJSONTransformer;
+ (NSValueTransformer *)expiresJSONTransformer;
@end

@interface OOSTransferUtilityExpression()

@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> *internalRequestHeaders;

@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> *internalRequestParameters;

- (void)assignRequestParameters:(OOSGetPreSignedURLRequest *)getPreSignedURLRequest;
- (void)assignRequestHeaders:(OOSGetPreSignedURLRequest *)getPreSignedURLRequest;

@end

@interface OOSTransferUtilityUploadExpression()

@property (copy, atomic) OOSTransferUtilityUploadCompletionHandlerBlock completionHandler;

@end

@interface OOSTransferUtilityMultiPartUploadExpression()

@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> *internalRequestHeaders;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> *internalRequestParameters;
- (void)assignRequestParameters:(OOSGetPreSignedURLRequest *)getPreSignedURLRequest;
@property (copy, atomic) OOSTransferUtilityMultiPartUploadCompletionHandlerBlock completionHandler;

@end

@implementation OOSTransferUtility (HeaderHelper)

-(void) propagateHeaderInformation: (OOSCreateMultipartUploadRequest *) uploadRequest
                        expression: (OOSTransferUtilityMultiPartUploadExpression *) expression {
    
    //Propagate header info and add custom metadata
    NSMutableDictionary<NSString *, NSString *> *metadata = [NSMutableDictionary new];
    for (NSString *key in expression.requestHeaders) {
        NSString *lKey = [key lowercaseString];
        if ([lKey hasPrefix:@"x-amz-meta"]) {
            [metadata setValue:expression.requestHeaders[key] forKey:[key stringByReplacingOccurrencesOfString:@"x-amz-meta-" withString:@""]];
        }
        else if ([lKey isEqualToString:@"x-amz-acl"]) {
            NSValueTransformer *transformer = [OOSCreateMultipartUploadRequest ACLJSONTransformer];
            uploadRequest.ACL = (OOSObjectCannedACL)[[transformer transformedValue:expression.requestHeaders[key]] integerValue];
        }
        else if ([lKey isEqualToString:@"x-amz-grant-read" ]) {
            uploadRequest.grantRead = expression.requestHeaders[key];
        }
        else if ([lKey isEqualToString:@"x-amz-grant-read-acp" ]) {
            uploadRequest.grantReadACP = expression.requestHeaders[key];
        }
        else if ([lKey isEqualToString:@"x-amz-grant-read-acp" ]) {
            uploadRequest.grantReadACP = expression.requestHeaders[key];
        }
        else if ([lKey isEqualToString:@"x-amz-grant-write-acp" ]) {
            uploadRequest.grantWriteACP = expression.requestHeaders[key];
        }
        else if ([lKey isEqualToString:@"x-amz-grant-full-control" ]) {
            uploadRequest.grantFullControl = expression.requestHeaders[key];
        }
        else if ([lKey isEqualToString:@"x-amz-server-side-encryption" ]) {
            NSValueTransformer *transformer = [OOSCreateMultipartUploadRequest serverSideEncryptionJSONTransformer];
            uploadRequest.serverSideEncryption = (OOSServerSideEncryption)[[transformer transformedValue:expression.requestHeaders[key]] integerValue];
        }
        else if ([lKey isEqualToString:@"x-amz-server-side-encryption-OOS-kms-key-id" ]) {
            uploadRequest.SSEKMSKeyId = expression.requestHeaders[key];
        }
        else if ([lKey isEqualToString:@"x-amz-server-side​-encryption​-customer-algorithm" ]) {
            uploadRequest.SSECustomerAlgorithm = expression.requestHeaders[key];
        }
        else if ([lKey isEqualToString:@"x-amz-server-side​-encryption​-customer-key" ]) {
            uploadRequest.SSECustomerKey = expression.requestHeaders[key];
        }
        else if ([lKey isEqualToString:@"x-amz-server-side​-encryption​-customer-key-MD5" ]) {
            uploadRequest.SSECustomerKeyMD5 = expression.requestHeaders[key];
        }
        else if ([lKey isEqualToString:@"content-encoding" ]) {
            uploadRequest.contentEncoding = expression.requestHeaders[key];
        }
        else if ([lKey isEqualToString:@"content-type" ]) {
            uploadRequest.contentType = expression.requestHeaders[key];
        }
        else if([lKey isEqualToString:@"cache-control"]) {
            uploadRequest.cacheControl = expression.requestHeaders[key];
        }
        else if ([lKey isEqualToString:@"x-amz-request-payer" ]) {
            NSValueTransformer *transformer = [OOSCreateMultipartUploadRequest requestPayerJSONTransformer];
            uploadRequest.requestPayer = (OOSRequestPayer)[[transformer transformedValue:expression.requestHeaders[key]] integerValue];
        }
        else if ([lKey isEqualToString:@"expires" ]) {
            NSValueTransformer *transformer = [OOSCreateMultipartUploadRequest expiresJSONTransformer];
            uploadRequest.expires = [transformer transformedValue:expression.requestHeaders[key]];
        }
        else if ([lKey isEqualToString:@"x-amz-storage-class" ]) {
            NSValueTransformer *transformer = [OOSCreateMultipartUploadRequest storageClassJSONTransformer];
            uploadRequest.storageClass = (OOSStorageClass)[[transformer transformedValue:expression.requestHeaders[key]] integerValue];
        }
        else if ([lKey isEqualToString:@"x-amz-website-redirect-location" ]) {
            uploadRequest.websiteRedirectLocation = expression.requestHeaders[key];
        }
        else if ([lKey isEqualToString:@"x-amz-tagging" ]) {
            uploadRequest.tagging = expression.requestHeaders[key];
        }
    }
    uploadRequest.metadata = metadata;
}

-(void) filterAndAssignHeaders:(NSDictionary<NSString *, NSString *> *) requestHeaders
        getPresignedURLRequest:(OOSGetPreSignedURLRequest *) getPresignedURLRequest
                    URLRequest: (NSMutableURLRequest *) URLRequest {
    
    NSSet *disallowedHeaders = [[NSSet alloc] initWithArray:
                                @[@"x-amz-acl", @"x-amz-tagging", @"x-amz-storage-class", @"x-amz-server-side-encryption"]];
    
    for (NSString *key in requestHeaders) {
        //Do not include custom metadata or custom grants
        NSString *lKey = [key lowercaseString];
        if ([ lKey hasPrefix:@"x-amz-meta"] || [lKey hasPrefix:@"x-amz-grant"]) {
            continue;
        }
        if ([disallowedHeaders containsObject:lKey]) {
            continue;
        }
        [getPresignedURLRequest setValue:requestHeaders[key] forRequestHeader:key];
        [URLRequest setValue:requestHeaders[key] forHTTPHeaderField:key];
    }
}

@end
