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
FOUNDATION_EXPORT NSString *const OOSValidationErrorDomain;

/* NSError codes in OOSErrorDomain. */
typedef NS_ENUM(NSInteger, OOSValidationErrorType) {
    // OOSJSON Validation related errors
    OOSValidationUnknownError, // Unknown Error found during JSON Validation
    OOSValidationUnexpectedParameter, // Unexpected Parameters found in HTTP Body
    OOSValidationUnhandledType,
    OOSValidationMissingRequiredParameter,
    OOSValidationOutOfRangeParameter,
    OOSValidationInvalidStringParameter,
    OOSValidationUnexpectedStringParameter,
    OOSValidationInvalidParameterType,
    OOSValidationInvalidBase64Data,
    OOSValidationHeaderTargetInvalid,
    OOSValidationHeaderAPIActionIsUndefined,
    OOSValidationHeaderDefinitionFileIsNotFound,
    OOSValidationHeaderDefinitionFileIsEmpty,
    OOSValidationHeaderAPIActionIsInvalid,
    OOSValidationURIIsInvalid
};
