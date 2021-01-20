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

#pragma once

/**
 This exists to use along with `OOSTask` and `OOSTaskCompletionSource`.

 Instead of returning a `OOSTask` with no generic type, or a generic type of 'NSNull'
 when there is no usable result from a task, we use the type 'OOSVoid', which will always have a value of `nil`.

 This allows you to provide a more enforced API contract to the caller,
 as sending any message to `OOSVoid` will result in a compile time error.
 */
@class _OOSVoid_Nonexistant;
typedef _OOSVoid_Nonexistant *OOSVoid;
