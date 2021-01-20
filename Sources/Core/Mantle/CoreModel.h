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
#import "OOSMTLModel.h"
#import "OOSMTLJSONAdapter.h"
#import "OOSMTLModel+NSCoding.h"
#import "OOSCocoaLumberjack.h"

@interface CoreModel : OOSMTLModel <OOSMTLJSONSerializing>

@end

@interface OOSModelUtility : NSObject

+ (NSDictionary *)mapMTLDictionaryFromJSONArrayDictionary:(NSDictionary *)JSONArrayDictionary
										 arrayElementType:(NSString *)arrayElementType
										   withModelClass:(Class)modelClass;
+ (NSDictionary *)JSONArrayDictionaryFromMapMTLDictionary:(NSDictionary *)mapMTLDictionary
										 arrayElementType:(NSString *)arrayElementType;

+ (NSArray *)mapMTLArrayFromJSONArray:(NSArray *)JSONArray
					   withModelClass:(Class)modelClass;
+ (NSArray *)JSONArrayFromMapMTLArray:(NSArray *)mapMTLArray;

+ (NSDictionary *)mapMTLDictionaryFromJSONDictionary:(NSDictionary *)JSONDictionary
									  withModelClass:(Class)modelClass;
+ (NSDictionary *)JSONDictionaryFromMapMTLDictionary:(NSDictionary *)mapMTLDictionary;

@end
