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

#import "OOSURLRequestRetryHandler.h"
#import "OOSURLResponseSerialization.h"
#import "CoreService.h"

@interface OOSURLRequestRetryHandler ()

@property (atomic, assign) BOOL isClockSkewRetried;

@end

@implementation OOSURLRequestRetryHandler

- (instancetype)initWithMaximumRetryCount:(uint32_t)maxRetryCount {
    if (self = [super init]) {
        _maxRetryCount = maxRetryCount;
    }

    return self;
}

- (BOOL)isClockSkewError:(NSError *)error {
    if ([error.domain isEqualToString:OOSServiceErrorDomain]) {
        switch (error.code) {
            case OOSServiceErrorRequestTimeTooSkewed:
            case OOSServiceErrorInvalidSignatureException:
            case OOSServiceErrorRequestExpired:
            case OOSServiceErrorAuthFailure:
            case OOSServiceErrorSignatureDoesNotMatch:
                return YES;
            default:
                break;
        }
    }

    return NO;
}

- (OOSNetworkingRetryType)shouldRetry:(uint32_t)currentRetryCount
                      originalRequest:(OOSNetworkingRequest *)originalRequest
                             response:(NSHTTPURLResponse *)response
                                 data:(NSData *)data
                                error:(NSError *)error {
    if (currentRetryCount >= self.maxRetryCount) {
        return OOSNetworkingRetryTypeShouldNotRetry;
    }

    // Clock skew exceptions.
    if (!self.isClockSkewRetried && [self isClockSkewError:error]) {
        self.isClockSkewRetried = YES;
        return OOSNetworkingRetryTypeShouldCorrectClockSkewAndRetry;
    }

    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        switch (error.code) {
            case NSURLErrorCancelled:
            case NSURLErrorBadURL:
            case NSURLErrorNotConnectedToInternet:

            case NSURLErrorSecureConnectionFailed:
            case NSURLErrorServerCertificateHasBadDate:
            case NSURLErrorServerCertificateUntrusted:
            case NSURLErrorServerCertificateHasUnknownRoot:
            case NSURLErrorServerCertificateNotYetValid:
            case NSURLErrorClientCertificateRejected:
            case NSURLErrorClientCertificateRequired:
            case NSURLErrorCannotLoadFromNetwork:
                return OOSNetworkingRetryTypeShouldNotRetry;

            default:
                return OOSNetworkingRetryTypeShouldRetry;
        }
    }

    // Invalid temporary credentials exceptions.
    if ([error.domain isEqualToString:OOSServiceErrorDomain]) {
        switch (error.code) {
            case OOSServiceErrorIncompleteSignature:
            case OOSServiceErrorInvalidClientTokenId:
            case OOSServiceErrorMissingAuthenticationToken:
            case OOSServiceErrorAccessDenied:
            case OOSServiceErrorUnrecognizedClientException:
            case OOSServiceErrorAuthFailure:
            case OOSServiceErrorAccessDeniedException:
            case OOSServiceErrorExpiredToken:
            case OOSServiceErrorInvalidAccessKeyId:
            case OOSServiceErrorInvalidToken:
            case OOSServiceErrorTokenRefreshRequired:
            case OOSServiceErrorAccessFailure:
            case OOSServiceErrorAuthMissingFailure:
                return OOSNetworkingRetryTypeShouldRefreshCredentialsAndRetry;

            default:
                break;
        }
    }

    // Throttling exceptions.
    if ([error.domain isEqualToString:OOSServiceErrorDomain]) {
        switch (error.code) {
            case OOSServiceErrorThrottling:
            case OOSServiceErrorThrottlingException:
                return OOSNetworkingRetryTypeShouldRetry;

            default:
                break;
        }
    }

    switch (response.statusCode) {
        case 500:
        case 503:
            return OOSNetworkingRetryTypeShouldRetry;
            break;

        default:
            break;
    }

    return OOSNetworkingRetryTypeShouldNotRetry;
}

- (NSTimeInterval)timeIntervalForRetry:(uint32_t)currentRetryCount
                              response:(NSHTTPURLResponse *)response
                                  data:(NSData *)data
                                 error:(NSError *)error {
    return pow(2, currentRetryCount) * 100 / 1000;
}

@end
