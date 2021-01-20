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

void OOSmtl_loadMTLPredefinedTransformerAdditions(void);

// The name for a value transformer that converts strings into URLs and back.
extern NSString * const OOSMTLURLValueTransformerName;

// Ensure an NSNumber is backed by __NSCFBoolean/CFBooleanRef
//
// NSJSONSerialization, and likely other serialization libraries, ordinarily
// serialize NSNumbers as numbers, and thus booleans would be serialized as
// 0/1. The exception is when the NSNumber is backed by __NSCFBoolean, which,
// though very much an implementation detail, is detected and serialized as a
// proper boolean.
extern NSString * const OOSMTLBooleanValueTransformerName;

@interface NSValueTransformer (OOSMTLPredefinedTransformerAdditions)

// Creates a reversible transformer to convert a JSON dictionary into a MTLModel
// object, and vice-versa.
//
// modelClass - The MTLModel subclass to attempt to parse from the JSON. This
//              class must conform to <MTLJSONSerializing>. This argument must
//              not be nil.
//
// Returns a reversible transformer which uses MTLJSONAdapter for transforming
// values back and forth.
+ (NSValueTransformer *)OOSmtl_JSONDictionaryTransformerWithModelClass:(Class)modelClass;

// Creates a reversible transformer to convert an array of JSON dictionaries
// into an array of MTLModel objects, and vice-versa.
//
// modelClass - The MTLModel subclass to attempt to parse from each JSON
//              dictionary. This class must conform to <MTLJSONSerializing>.
//              This argument must not be nil.
//
// Returns a reversible transformer which uses MTLJSONAdapter for transforming
// array elements back and forth.
+ (NSValueTransformer *)OOSmtl_JSONArrayTransformerWithModelClass:(Class)modelClass;

// A reversible value transformer to transform between the keys and objects of a
// dictionary.
//
// dictionary          - The dictionary whose keys and values should be
//                       transformed between. This argument must not be nil.
// defaultValue        - The result to fall back to, in case no key matching the
//                       input value was found during a forward transformation.
// reverseDefaultValue - The result to fall back to, in case no value matching
//                       the input value was found during a reverse
//                       transformation.
//
// Can for example be used for transforming between enum values and their string
// representation.
//
//   NSValueTransformer *valueTransformer = [NSValueTransformer OOSmtl_valueMappingTransformerWithDictionary:@{
//     @"foo": @(EnumDataTypeFoo),
//     @"bar": @(EnumDataTypeBar),
//   } defaultValue: @(EnumDataTypeUndefined) reverseDefaultValue: @"undefined"];
//
// Returns a transformer that will map from keys to values in dictionary
// for forward transformation, and from values to keys for reverse
// transformations. If no matching key or value can be found, the respective
// default value is returned.
+ (NSValueTransformer *)OOSmtl_valueMappingTransformerWithDictionary:(NSDictionary *)dictionary defaultValue:(id)defaultValue reverseDefaultValue:(id)reverseDefaultValue;

// Returns a value transformer created by calling
// `+mtl_valueMappingTransformerWithDictionary:defaultValue:reverseDefaultValue:`
// with a default value of `nil` and a reverse default value of `nil`.
+ (NSValueTransformer *)OOSmtl_valueMappingTransformerWithDictionary:(NSDictionary *)dictionary;

@end
