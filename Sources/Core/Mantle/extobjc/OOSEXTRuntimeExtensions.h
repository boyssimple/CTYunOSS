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


#import <objc/runtime.h>

/**
 * Describes the memory management policy of a property.
 */
typedef enum {
    /**
     * The value is assigned.
     */
    OOSmtl_propertyMemoryManagementPolicyAssign = 0,

    /**
     * The value is retained.
     */
    OOSmtl_propertyMemoryManagementPolicyRetain,

    /**
     * The value is copied.
     */
    OOSmtl_propertyMemoryManagementPolicyCopy
} OOSmtl_propertyMemoryManagementPolicy;

/**
 * Describes the attributes and type information of a property.
 */
typedef struct {
    /**
     * Whether this property was declared with the \c readonly attribute.
     */
    BOOL readonly;

    /**
     * Whether this property was declared with the \c nonatomic attribute.
     */
    BOOL nonatomic;

    /**
     * Whether the property is a weak reference.
     */
    BOOL weak;

    /**
     * Whether the property is eligible for garbage collection.
     */
    BOOL canBeCollected;

    /**
     * Whether this property is defined with \c \@dynamic.
     */
    BOOL dynamic;

    /**
     * The memory management policy for this property. This will always be
     * #mtl_propertyMemoryManagementPolicyAssign if #readonly is \c YES.
     */
    OOSmtl_propertyMemoryManagementPolicy memoryManagementPolicy;

    /**
     * The selector for the getter of this property. This will reflect any
     * custom \c getter= attribute provided in the property declaration, or the
     * inferred getter name otherwise.
     */
    SEL getter;

    /**
     * The selector for the setter of this property. This will reflect any
     * custom \c setter= attribute provided in the property declaration, or the
     * inferred setter name otherwise.
     *
     * @note If #readonly is \c YES, this value will represent what the setter
     * \e would be, if the property were writable.
     */
    SEL setter;

    /**
     * The backing instance variable for this property, or \c NULL if \c
     * \c @synthesize was not used, and therefore no instance variable exists. This
     * would also be the case if the property is implemented dynamically.
     */
    const char *ivar;

    /**
     * If this property is defined as being an instance of a specific class,
     * this will be the class object representing it.
     *
     * This will be \c nil if the property was defined as type \c id, if the
     * property is not of an object type, or if the class could not be found at
     * runtime.
     */
    Class objectClass;

    /**
     * The type encoding for the value of this property. This is the type as it
     * would be returned by the \c \@encode() directive.
     */
    char type[];
} OOSmtl_propertyAttributes;

/**
 * Returns a pointer to a structure containing information about \a property.
 * You must \c free() the returned pointer. Returns \c NULL if there is an error
 * obtaining information from \a property.
 */
OOSmtl_propertyAttributes *OOSmtl_copyPropertyAttributes (objc_property_t property);
