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
#import <Foundation/Foundation.h>

// defined domain for errors from OOSRuntime.
FOUNDATION_EXPORT NSString *const OOSXMLBuilderErrorDomain;

/* NSError codes in OOSErrorDomain. */
typedef NS_ENUM(NSInteger, OOSXMLBuilderErrorType) {
    // OOSJSON Validation related errors
    OOSXMLBuilderUnknownError = 900, // Unknown Error found
    OOSXMLBuilderDefinitionFileIsEmpty = 901,
    OOSXMLBuilderUndefinedXMLNamespace = 902,
    OOSXMLBuilderUndefinedActionRule = 903,
    OOSXMLBuilderMissingRequiredXMLElements = 904,
    OOSXMLBuilderInvalidXMLValue = 905,
    OOSXMLBuilderUnCatchedRuleTypeInDifinitionFile = 906,
};

// defined domain for errors from OOSRuntime.
FOUNDATION_EXPORT NSString *const OOSXMLParserErrorDomain;

/* NSError codes in OOSErrorDomain. */
typedef NS_ENUM(NSInteger, OOSXMLParserErrorType) {
    // OOSJSON Validation related errors
    OOSXMLParserUnknownError, // Unknown Error found
    OOSXMLParserNoTypeDefinitionInRule, // Unknown Type in JSON Definition (rules) file
    OOSXMLParserUnHandledType, //Unhandled Type
    OOSXMLParserUnExpectedType, //Unexpected type
    OOSXMLParserDefinitionFileIsEmpty, //the rule is empty.
    OOSXMLParserUnexpectedXMLElement,
    OOSXMLParserXMLNameNotFoundInDefinition, //can not find the 'xmlname' key in definition file for unflattened xml list
    OOSXMLParserMissingRequiredXMLElements,
    OOSXMLParserInvalidXMLValue,
};

//defined domain for errors from OOSRuntime.
FOUNDATION_EXPORT NSString *const OOSQueryParamBuilderErrorDomain;

/* NSError codes in OOSErrorDomain. */
typedef NS_ENUM(NSInteger, OOSQueryParamBuilderErrorType) {
    OOSQueryParamBuilderUnknownError,
    OOSQueryParamBuilderDefinitionFileIsEmpty,
    OOSQueryParamBuilderUndefinedActionRule,
    OOSQueryParamBuilderInternalError,
    OOSQueryParamBuilderInvalidParameter,
};

//defined domain for errors from OOSRuntime.
FOUNDATION_EXPORT NSString *const OOSEC2ParamBuilderErrorDomain;

/* NSError codes in OOSErrorDomain. */
typedef NS_ENUM(NSInteger, OOSEC2ParamBuilderErrorType) {
    OOSEC2ParamBuilderUnknownError,
    OOSEC2ParamBuilderDefinitionFileIsEmpty,
    OOSEC2ParamBuilderUndefinedActionRule,
    OOSEC2ParamBuilderInternalError,
    OOSEC2ParamBuilderInvalidParameter,
};

//defined domain for errors from OOSRuntime.
FOUNDATION_EXPORT NSString *const OOSJSONBuilderErrorDomain;

/* NSError codes in OOSErrorDomain. */
typedef NS_ENUM(NSInteger, OOSJSONBuilderErrorType) {
    OOSJSONBuilderUnknownError,
    OOSJSONBuilderDefinitionFileIsEmpty,
    OOSJSONBuilderUndefinedActionRule,
    OOSJSONBuilderInternalError,
    OOSJSONBuilderInvalidParameter,
};

//defined domain for errors from OOSRuntime.
FOUNDATION_EXPORT NSString *const OOSJSONParserErrorDomain;

/* NSError codes in OOSErrorDomain. */
typedef NS_ENUM(NSInteger, OOSJSONParserErrorType) {
    OOSJSONParserUnknownError,
    OOSJSONParserDefinitionFileIsEmpty,
    OOSJSONParserUndefinedActionRule,
    OOSJSONParserInternalError,
    OOSJSONParserInvalidParameter,
};

@interface OOSJSONDictionary : NSDictionary

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary
                JSONDefinitionRule:(NSDictionary *)rule;
- (NSUInteger)count;
- (id)objectForKey:(id)aKey;

@end

@interface OOSXMLBuilder : NSObject

+ (NSData *)xmlDataForDictionary:(NSDictionary *)params
                      actionName:(NSString *)actionName
           serviceDefinitionRule:(NSDictionary *)serviceDefinitionRule
                           error:(NSError *__autoreleasing *)error;

+ (NSString *)xmlStringForDictionary:(NSDictionary *)params
                          actionName:(NSString *)actionName
               serviceDefinitionRule:(NSDictionary *)serviceDefinitionRule
                               error:(NSError *__autoreleasing *)error;

@end

@interface OOSXMLParser : NSObject

+ (OOSXMLParser *)sharedInstance;

- (NSMutableDictionary *)dictionaryForXMLData:(NSData *)data
                                   actionName:(NSString *)actionName
						serviceDefinitionRule:(NSDictionary *)serviceDefinitionRule
                                        error:(NSError *__autoreleasing *)error;

@end

@interface OOSQueryParamBuilder : NSObject

+ (NSDictionary *)buildFormattedParams:(NSDictionary *)params
                            actionName:(NSString *)actionName
                 serviceDefinitionRule:(NSDictionary *)serviceDefinitionRule
                                 error:(NSError *__autoreleasing *)error;

@end

@interface OOSEC2ParamBuilder : NSObject

+ (NSDictionary *)buildFormattedParams:(NSDictionary *)params
                            actionName:(NSString *)actionName
                 serviceDefinitionRule:(NSDictionary *)serviceDefinitionRule
                                 error:(NSError *__autoreleasing *)error;

@end

@interface OOSJSONBuilder : NSObject

+ (NSData *)jsonDataForDictionary:(NSDictionary *)params
                       actionName:(NSString *)actionName
            serviceDefinitionRule:(NSDictionary *)serviceDefinitionRule
                            error:(NSError *__autoreleasing *)error;

@end

@interface OOSJSONParser : NSObject

+ (NSDictionary *)dictionaryForJsonData:(NSData *)data
                               response:(NSHTTPURLResponse *)response
                             actionName:(NSString *)actionName
                  serviceDefinitionRule:(NSDictionary *)serviceDefinitionRule
                                  error:(NSError *__autoreleasing *)error;

@end




