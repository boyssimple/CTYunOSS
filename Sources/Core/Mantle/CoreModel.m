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


#import "CoreModel.h"
#import "NSValueTransformer+OOSMTLPredefinedTransformerAdditions.h"

@implementation CoreModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return nil;
}

- (NSDictionary *)dictionaryValue {
	NSDictionary *dictionaryValue = [super dictionaryValue];
	NSMutableDictionary *mutableDictionaryValue = [dictionaryValue mutableCopy];
	
	[dictionaryValue enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if ([self valueForKey:key] == nil) {
			[mutableDictionaryValue removeObjectForKey:key];
		}
	}];
	
	return mutableDictionaryValue;
}

@end

@implementation OOSModelUtility

+ (NSDictionary *)mapMTLDictionaryFromJSONArrayDictionary:(NSDictionary *)JSONArrayDictionary arrayElementType:(NSString *)arrayElementType withModelClass:(Class) modelClass {
	
	NSMutableDictionary *mutableDictionary = [NSMutableDictionary new];
	for (NSString *key in [JSONArrayDictionary allKeys]) {
		if ([arrayElementType isEqualToString:@"map"]) {
			[mutableDictionary setObject:[OOSModelUtility mapMTLArrayFromJSONArray:JSONArrayDictionary[key] withModelClass:modelClass] forKey:key];
		} else if  ([arrayElementType isEqualToString:@"structure"]) {
			NSValueTransformer *valueFransformer =  [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[modelClass class]];
			[mutableDictionary setObject:[valueFransformer transformedValue:JSONArrayDictionary[key]] forKey:key];
		}
	}
	return mutableDictionary;
}

+ (NSDictionary *)JSONArrayDictionaryFromMapMTLDictionary:(NSDictionary *)mapMTLDictionary arrayElementType:(NSString *)arrayElementType{
	NSMutableDictionary *mutableDictionary = [NSMutableDictionary new];
	for (NSString *key in [mapMTLDictionary allKeys]) {
		if ([arrayElementType isEqualToString:@"map"]) {
			[mutableDictionary setObject:[OOSModelUtility JSONArrayFromMapMTLArray:mapMTLDictionary[key]] forKey:key];
		} else if ([arrayElementType isEqualToString:@"structure"]) {
			NSValueTransformer *valueFransformer = [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[CoreModel class]];
			[mutableDictionary setObject:[valueFransformer reverseTransformedValue:mapMTLDictionary[key]] forKey:key];
		}
	}
	return mutableDictionary;
}

//Forward transformation For Array of Map Type
+ (NSArray *)mapMTLArrayFromJSONArray:(NSArray *)JSONArray withModelClass:(Class)modelClass {
	NSMutableArray *mutableArray = [NSMutableArray new];
	for (NSDictionary *aDic in JSONArray) {
		NSDictionary *tmpDic = [OOSModelUtility mapMTLDictionaryFromJSONDictionary:aDic withModelClass:[modelClass class]];
		[mutableArray addObject:tmpDic];
	};
	return mutableArray;
}

//Reverse transform for Array of Map Type
+ (NSArray *)JSONArrayFromMapMTLArray:(NSArray *)mapMTLArray {
	NSMutableArray *mutableArray = [NSMutableArray new];
	for (NSDictionary *aDic in mapMTLArray) {
		NSDictionary *tmpDic = [OOSModelUtility JSONDictionaryFromMapMTLDictionary:aDic];
		[mutableArray addObject:tmpDic];
	};
	return mutableArray;
}

//Forward transformation for JSONDefinition Map Type
+ (NSDictionary *)mapMTLDictionaryFromJSONDictionary:(NSDictionary *)JSONDictionary withModelClass:(Class)modelClass {
	
	NSMutableDictionary *mutableDictionary = [NSMutableDictionary new];
	for (NSString *key in [JSONDictionary allKeys]) {
		[mutableDictionary setObject:[OOSMTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:JSONDictionary[key] error:nil] forKey:key];
	}
	return mutableDictionary;
}

//Reverse transfrom for JSONDefinition Map Type
+ (NSDictionary *)JSONDictionaryFromMapMTLDictionary:(NSDictionary *)mapMTLDictionary {
	
	NSMutableDictionary *mutableDictionary = [NSMutableDictionary new];
	for (NSString *key in [mapMTLDictionary allKeys]) {
		[mutableDictionary setObject:[OOSMTLJSONAdapter JSONDictionaryFromModel:[mapMTLDictionary objectForKey:key]]
							  forKey:key];
	}
	return mutableDictionary;
}

@end
