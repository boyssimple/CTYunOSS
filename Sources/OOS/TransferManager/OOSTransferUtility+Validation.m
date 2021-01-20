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


#import "OOSTransferUtility+Validation.h"

@implementation OOSTransferUtility (Validation)

- (OOSTask *) validateParameters: (NSString * )bucket fileURL:(NSURL *)fileURL accelerationModeEnabled: (BOOL) accelerationModeEnabled
{
    //Validate input parameter: bucket
    if (!bucket || [bucket length] == 0) {
        NSInteger errorCode = (accelerationModeEnabled) ?
        OOSPresignedURLErrorInvalidBucketNameForAccelerateModeEnabled : OOSPresignedURLErrorInvalidBucketName;
    
        NSString *errorMessage = @"Invalid bucket specified. Please specify a bucket name or configure the bucket property in `OOSTransferUtilityConfiguration`.";
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage
                                                         forKey:NSLocalizedDescriptionKey];
    
        return [OOSTask taskWithError:[NSError errorWithDomain:OOSPresignedURLErrorDomain
                                                      code:errorCode
                                                  userInfo:userInfo]];
    }

    NSString *filePath = [fileURL path];
    // Error out if the length of file name < minimum file path length (2 characters) or file does not exist
    if ([filePath length] < 2 ||
        ! [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferUtilityErrorDomain
                                                      code:OOSTransferUtilityErrorLocalFileNotFound
                                                  userInfo:nil]];
    }
    return nil;
}
@end
