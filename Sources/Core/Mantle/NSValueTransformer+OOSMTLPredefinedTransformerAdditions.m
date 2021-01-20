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


#import "NSValueTransformer+OOSMTLPredefinedTransformerAdditions.h"
#import "CoreModel.h"
#import "OOSMTLJSONAdapter.h"
#import "OOSMTLValueTransformer.h"

void OOSmtl_loadMTLPredefinedTransformerAdditions(){
}

NSString * const OOSMTLURLValueTransformerName = @"OOSMTLURLValueTransformerName";
NSString * const OOSMTLBooleanValueTransformerName = @"OOSMTLBooleanValueTransformerName";

@implementation NSValueTransformer (OOSMTLPredefinedTransformerAdditions)

#pragma mark Category Loading

+ (void)load {
	@autoreleasepool {
		OOSMTLValueTransformer *URLValueTransformer = [OOSMTLValueTransformer
			reversibleTransformerWithForwardBlock:^ id (NSString *str) {
				if (![str isKindOfClass:NSString.class]) return nil;
				return [NSURL URLWithString:str];
			}
			reverseBlock:^ id (NSURL *URL) {
				if (![URL isKindOfClass:NSURL.class]) return nil;
				return URL.absoluteString;
			}];
		
		[NSValueTransformer setValueTransformer:URLValueTransformer forName:OOSMTLURLValueTransformerName];

		OOSMTLValueTransformer *booleanValueTransformer = [OOSMTLValueTransformer
			reversibleTransformerWithBlock:^ id (NSNumber *boolean) {
				if (![boolean isKindOfClass:NSNumber.class]) return nil;
				return (NSNumber *)(boolean.boolValue ? kCFBooleanTrue : kCFBooleanFalse);
			}];

		[NSValueTransformer setValueTransformer:booleanValueTransformer forName:OOSMTLBooleanValueTransformerName];
	}
}

#pragma mark Customizable Transformers

+ (NSValueTransformer *)OOSmtl_JSONDictionaryTransformerWithModelClass:(Class)modelClass {
	NSParameterAssert([modelClass isSubclassOfClass:OOSMTLModel.class]);
	NSParameterAssert([modelClass conformsToProtocol:@protocol(OOSMTLJSONSerializing)]);

	return [OOSMTLValueTransformer
		reversibleTransformerWithForwardBlock:^ id (id JSONDictionary) {
			if (JSONDictionary == nil) return nil;

			NSAssert([JSONDictionary isKindOfClass:NSDictionary.class], @"Expected a dictionary, got: %@", JSONDictionary);

			return [OOSMTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:JSONDictionary error:NULL];
		}
		reverseBlock:^ id (id model) {
			if (model == nil) return nil;

			NSAssert([model isKindOfClass:CoreModel.class], @"Expected a MTLModel object, got %@", model);
			NSAssert([model conformsToProtocol:@protocol(OOSMTLJSONSerializing)], @"Expected a model object conforming to <MTLJSONSerializing>, got %@", model);

			return [OOSMTLJSONAdapter JSONDictionaryFromModel:model];
		}];
}

+ (NSValueTransformer *)OOSmtl_JSONArrayTransformerWithModelClass:(Class)modelClass {
	NSValueTransformer *dictionaryTransformer = [self OOSmtl_JSONDictionaryTransformerWithModelClass:modelClass];

	return [OOSMTLValueTransformer
		reversibleTransformerWithForwardBlock:^ id (NSArray *dictionaries) {
			if (dictionaries == nil) return nil;

			NSAssert([dictionaries isKindOfClass:NSArray.class], @"Expected an array of dictionaries, got: %@", dictionaries);

			NSMutableArray *models = [NSMutableArray arrayWithCapacity:dictionaries.count];
			for (id JSONDictionary in dictionaries) {
				if (JSONDictionary == NSNull.null) {
					[models addObject:NSNull.null];
					continue;
				}

				NSAssert([JSONDictionary isKindOfClass:NSDictionary.class], @"Expected a dictionary or an NSNull, got: %@", JSONDictionary);

				id model = [dictionaryTransformer transformedValue:JSONDictionary];
				if (model == nil) continue;

				[models addObject:model];
			}

			return models;
		}
		reverseBlock:^ id (NSArray *models) {
			if (models == nil) return nil;

			NSAssert([models isKindOfClass:NSArray.class], @"Expected an array of MTLModels, got: %@", models);

			NSMutableArray *dictionaries = [NSMutableArray arrayWithCapacity:models.count];
			for (id model in models) {
				if (model == NSNull.null) {
					[dictionaries addObject:NSNull.null];
					continue;
				}

				NSAssert([model isKindOfClass:CoreModel.class], @"Expected an MTLModel or an NSNull, got: %@", model);

				NSDictionary *dict = [dictionaryTransformer reverseTransformedValue:model];
				if (dict == nil) continue;

				[dictionaries addObject:dict];
			}

			return dictionaries;
		}];
}

+ (NSValueTransformer *)OOSmtl_valueMappingTransformerWithDictionary:(NSDictionary *)dictionary {
	return [self OOSmtl_valueMappingTransformerWithDictionary:dictionary defaultValue:nil reverseDefaultValue:nil];
}

+ (NSValueTransformer *)OOSmtl_valueMappingTransformerWithDictionary:(NSDictionary *)dictionary defaultValue:(id)defaultValue reverseDefaultValue:(id)reverseDefaultValue {
	NSParameterAssert(dictionary != nil);
	NSParameterAssert(dictionary.count == [[NSSet setWithArray:dictionary.allValues] count]);

	return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^(id<NSCopying> key) {
		return dictionary[key ?: NSNull.null] ?: defaultValue;
	} reverseBlock:^(id object) {
		__block id result = nil;
		[dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id anObject, BOOL *stop) {
			if ([object isEqual:anObject]) {
				result = key;
				*stop = YES;
			}
		}];
		return result ?: reverseDefaultValue;
	}];
}

+ (NSValueTransformer *)OOSmtl_NSInputStreamValueTransformerWithData:(NSData *)data{
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^(NSData *data) {
         return [[NSInputStream alloc]initWithData:data];
    } reverseBlock:^(NSInputStream *object) {
        return object;
    }];
}

@end
