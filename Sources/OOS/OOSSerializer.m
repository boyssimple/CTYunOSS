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


#import "OOSSerializer.h"
#import "OOSModel.h"
#import "OOSURLResponseSerialization.h"
#import "OOSURLRequestSerialization.h"

@interface OOSRequestSerializer()

@property (nonatomic, strong) NSDictionary *serviceDefinitionJSON;
@property (nonatomic, strong) NSString *actionName;
@property (nonatomic, strong) id<OOSURLRequestSerializer> requestSerializer;

@end

@implementation OOSRequestSerializer

- (instancetype)initWithJSONDefinition:(NSDictionary *)JSONDefinition
                            actionName:(NSString *)actionName{
    if (self = [super init]) {
        
        _serviceDefinitionJSON = JSONDefinition;
        if (_serviceDefinitionJSON == nil) {
            OOSDDLogError(@"serviceDefinitionJSON is nil.");
            return nil;
        }
        _actionName = actionName;
        
        //get and put bucket policy use json, while rest use xml
        if([[_actionName lowercaseString] isEqualToString:@"putbucketpolicy"]
           || [[_actionName lowercaseString] isEqualToString:@"getbucketpolicy"]){
            _requestSerializer = [[OOSJSONRequestSerializer alloc]initWithJSONDefinition:JSONDefinition actionName:actionName];
		}else if ( [[_actionName lowercaseString] isEqualToString:@"createaccesskey"] ||
				  [[_actionName lowercaseString] isEqualToString:@"updateaccesskey"] ||
				  [[_actionName lowercaseString] isEqualToString:@"listaccesskey"] ||
				  [[_actionName lowercaseString] isEqualToString:@"deleteaccesskey"] ) {
			_requestSerializer = [[OOSQueryStringRequestSerializer alloc]initWithJSONDefinition:JSONDefinition actionName:actionName];
		}else{
            _requestSerializer = [[OOSXMLRequestSerializer alloc]initWithJSONDefinition:JSONDefinition actionName:actionName];
        }
    }
    
    return self;
}

- (OOSTask *)validateRequest:(NSURLRequest *)request{
    return [_requestSerializer validateRequest:request];
}

- (OOSTask *)serializeRequest:(NSMutableURLRequest *)request headers:(NSDictionary *)headers parameters:(NSDictionary *)parameters{
    return [_requestSerializer serializeRequest:request headers:headers parameters:parameters];
}

@end


@interface OOSResponseSerializer()

@property (nonatomic, strong) NSDictionary *serviceDefinitionJSON;
@property (nonatomic, strong) NSString *actionName;
@property (nonatomic, strong) id<OOSHTTPURLResponseSerializer> responseSerializer;

@end

@implementation OOSResponseSerializer

- (instancetype)initWithJSONDefinition:(NSDictionary *)JSONDefinition
                            actionName:(NSString *)actionName
                           outputClass:(Class)outputClass{
    if (self = [super init]) {
        
        _serviceDefinitionJSON = JSONDefinition;
        if (_serviceDefinitionJSON == nil) {
            OOSDDLogError(@"serviceDefinitionJSON is nil.");
            return nil;
        }
        _actionName = actionName;
        
        _outputClass = outputClass;
        
        //get and put bucket policy use json, while rest use xml
        if([[_actionName lowercaseString] isEqualToString:@"putbucketpolicy"]
           || [[_actionName lowercaseString] isEqualToString:@"getbucketpolicy"]){
            _responseSerializer = [[OOSJSONResponseSerializer alloc]initWithJSONDefinition:JSONDefinition actionName:actionName outputClass:outputClass];
        }else{
            _responseSerializer = [[OOSXMLResponseSerializer alloc]initWithJSONDefinition:JSONDefinition actionName:actionName outputClass:outputClass];
        }
    }
    
    return self;
}

static NSDictionary *errorCodeDictionary = nil;
+ (void)initialize {
    errorCodeDictionary = @{
                            @"BucketAlreadyExists" : @(OOSErrorBucketAlreadyExists),
                            @"BucketAlreadyOwnedByYou" : @(OOSErrorBucketAlreadyOwnedByYou),
                            @"NoSuchBucket" : @(OOSErrorNoSuchBucket),
                            @"NoSuchKey" : @(OOSErrorNoSuchKey),
                            @"NoSuchUpload" : @(OOSErrorNoSuchUpload),
                            @"ObjectAlreadyInActiveTierError" : @(OOSErrorObjectAlreadyInActiveTier),
                            @"ObjectNotInActiveTierError" : @(OOSErrorObjectNotInActiveTier),
                            };
}

- (id)responseObjectForResponse:(NSHTTPURLResponse *)response
                originalRequest:(NSURLRequest *)originalRequest
                 currentRequest:(NSURLRequest *)currentRequest
                           data:(id)data
                          error:(NSError *__autoreleasing *)error {
    
    id responseObject =  [_responseSerializer responseObjectForResponse:response
                                          originalRequest:originalRequest
                                           currentRequest:currentRequest
                                                     data:data
                                                    error:error];
    
    
    if (!*error && [responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *errorInfo = responseObject[@"Error"];
        if (errorInfo[@"Code"] && errorCodeDictionary[errorInfo[@"Code"]]) {
            if (error) {
                *error = [NSError errorWithDomain:OOSErrorDomain
                                             code:[errorCodeDictionary[errorInfo[@"Code"]] integerValue]
                                         userInfo:errorInfo];
                return responseObject;
            }
        } else if (errorInfo) {
            if (error) {
                *error = [NSError errorWithDomain:OOSErrorDomain
                                             code:OOSErrorUnknown
                                         userInfo:errorInfo];
                return responseObject;
            }
        }
    }
    
    if (!*error
        && response.statusCode/100 != 2
        && response.statusCode/100 != 3) {
        *error = [NSError errorWithDomain:OOSErrorDomain
                                     code:OOSErrorUnknown
                                 userInfo:nil];
    }
    
    if (!*error && [responseObject isKindOfClass:[NSDictionary class]]) {
        if (self.outputClass) {
            responseObject = [OOSMTLJSONAdapter modelOfClass:self.outputClass
                                          fromJSONDictionary:responseObject
                                                       error:error];
        }
    }
    
    return responseObject;
    
}

- (BOOL)validateResponse:(NSHTTPURLResponse *)response
             fromRequest:(NSURLRequest *)request
                    data:(id)data
                   error:(NSError *__autoreleasing *)error{
    
    return [_responseSerializer validateResponse:response
                                     fromRequest:request
                                            data:data
                                           error:error];
}

@end
