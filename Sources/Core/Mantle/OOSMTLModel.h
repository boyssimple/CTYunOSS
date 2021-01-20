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

// An abstract base class for model objects, using reflection to provide
// sensible default behaviors.
//
// The default implementations of <NSCopying>, -hash, and -isEqual: make use of
// the +propertyKeys method.
@interface OOSMTLModel : NSObject <NSCopying>

// Returns a new instance of the receiver initialized using
// -initWithDictionary:error:.
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error;

// Initializes the receiver with default values.
//
// This is the designated initializer for this class.
- (instancetype)init;

// Initializes the receiver using key-value coding, setting the keys and values
// in the given dictionary.
//
// Subclass implementations may override this method, calling the super
// implementation, in order to perform further processing and initialization
// after deserialization.
//
// dictionaryValue - Property keys and values to set on the receiver. Any NSNull
//                   values will be converted to nil before being used. KVC
//                   validation methods will automatically be invoked for all of
//                   the properties given. If nil, this method is equivalent to
//                   -init.
// error           - If not NULL, this may be set to any error that occurs
//                   (like a KVC validation error).
//
// Returns an initialized model object, or nil if validation failed.
- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error;

// Returns the keys for all @property declarations, except for `readonly`
// properties without ivars, or properties on MTLModel itself.
+ (NSSet *)propertyKeys;

// A dictionary representing the properties of the receiver.
//
// The default implementation combines the values corresponding to all
// +propertyKeys into a dictionary, with any nil values represented by NSNull.
//
// This property must never be nil.
@property (nonatomic, copy, readonly) NSDictionary *dictionaryValue;

// Merges the value of the given key on the receiver with the value of the same
// key from the given model object, giving precedence to the other model object.
//
// By default, this method looks for a `-merge<Key>FromModel:` method on the
// receiver, and invokes it if found. If not found, and `model` is not nil, the
// value for the given key is taken from `model`.
- (void)mergeValueForKey:(NSString *)key fromModel:(OOSMTLModel *)model;

// Merges the values of the given model object into the receiver, using
// -mergeValueForKey:fromModel: for each key in +propertyKeys.
//
// `model` must be an instance of the receiver's class or a subclass thereof.
- (void)mergeValuesForKeysFromModel:(OOSMTLModel *)model;

// Compares the receiver with another object for equality.
//
// The default implementation is equivalent to comparing both models'
// -dictionaryValue.
//
// Note that this may lead to infinite loops if the receiver holds a circular
// reference to another MTLModel and both use the default behavior.
// It is recommended to override -isEqual: in this scenario.
- (BOOL)isEqual:(id)object;

// A string that describes the contents of the receiver.
//
// The default implementation is based on the receiver's class and its
// -dictionaryValue.
//
// Note that this may lead to infinite loops if the receiver holds a circular
// reference to another MTLModel and both use the default behavior.
// It is recommended to override -description in this scenario.
- (NSString *)description;

@end

// Implements validation logic for MTLModel.
@interface OOSMTLModel (Validation)

// Validates the model.
//
// The default implementation simply invokes -validateValue:forKey:error: with
// all +propertyKeys and their current value. If -validateValue:forKey:error:
// returns a new value, the property is set to that new value.
//
// error - If not NULL, this may be set to any error that occurs during
//         validation
//
// Returns YES if the model is valid, or NO if the validation failed.
- (BOOL)validate:(NSError **)error;

@end
