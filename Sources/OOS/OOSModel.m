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


#import "OOSModel.h"
#import "OOSCategory.h"
#import "OOSMTLValueTransformer.h"
#import "NSValueTransformer+OOSMTLPredefinedTransformerAdditions.h"

NSString *const OOSErrorDomain = @"cn.ctyun.OOSErrorDomain";

@implementation OOSAbortIncompleteMultipartUpload

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"daysAfterInitiation" : @"DaysAfterInitiation",
             };
}

@end

@implementation OOSAbortMultipartUploadOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"requestCharged" : @"RequestCharged",
             };
}

+ (NSValueTransformer *)requestChargedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestChargedRequester);
        }
        return @(OOSRequestChargedUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestChargedRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSAbortMultipartUploadRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"key" : @"Key",
             @"requestPayer" : @"RequestPayer",
             @"uploadId" : @"UploadId",
             };
}

+ (NSValueTransformer *)requestPayerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestPayerRequester);
        }
        return @(OOSRequestPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestPayerRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end


@implementation OOSIPWhiteLists

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"ips" : @"IPs",
			 };
}

@end

@implementation OOSAccelerateConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"status" : @"Status",
			 @"ipWhiteLists" : @"IPWhiteLists",
             };
}

+ (NSValueTransformer *)statusJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"Enabled"] == NSOrderedSame) {
            return @(OOSBucketAccelerateStatusEnabled);
        }
        if ([value caseInsensitiveCompare:@"Suspended"] == NSOrderedSame) {
            return @(OOSBucketAccelerateStatusSuspended);
        }
        return @(OOSBucketAccelerateStatusUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSBucketAccelerateStatusEnabled:
                return @"Enabled";
            case OOSBucketAccelerateStatusSuspended:
                return @"Suspended";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)ipWhiteListsJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSIPWhiteLists class]];
}

@end

@implementation OOSAccessControlPolicy

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"grants" : @"Grants",
             @"owner" : @"Owner",
             };
}

+ (NSValueTransformer *)grantsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSGrant class]];
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSOwner class]];
}

@end

@implementation OOSAccessControlTranslation

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"owner" : @"Owner",
             };
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"Destination"] == NSOrderedSame) {
            return @(OOSOwnerOverrideDestination);
        }
        return @(OOSOwnerOverrideUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSOwnerOverrideDestination:
                return @"Destination";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSAnalyticsAndOperator

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"prefix" : @"Prefix",
             @"tags" : @"Tags",
             };
}

+ (NSValueTransformer *)tagsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSTag class]];
}

@end

@implementation OOSAnalyticsConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"filter" : @"Filter",
             @"identifier" : @"Id",
             @"storageClassAnalysis" : @"StorageClassAnalysis",
             };
}

+ (NSValueTransformer *)filterJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSAnalyticsFilter class]];
}

+ (NSValueTransformer *)storageClassAnalysisJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSStorageClassAnalysis class]];
}

@end

@implementation OOSAnalyticsExportDestination

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"BucketDestination" : @"BucketDestination",
             };
}

+ (NSValueTransformer *)BucketDestinationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSAnalyticsBucketDestination class]];
}

@end

@implementation OOSAnalyticsFilter

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"AND" : @"And",
             @"prefix" : @"Prefix",
             @"tag" : @"Tag",
             };
}

+ (NSValueTransformer *)ANDJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSAnalyticsAndOperator class]];
}

+ (NSValueTransformer *)tagJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSTag class]];
}

@end

@implementation OOSAnalyticsBucketDestination

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"bucketAccountId" : @"BucketAccountId",
             @"format" : @"Format",
             @"prefix" : @"Prefix",
             };
}

+ (NSValueTransformer *)formatJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"CSV"] == NSOrderedSame) {
            return @(OOSAnalyticsExportFileFormatCsv);
        }
        return @(OOSAnalyticsExportFileFormatUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSAnalyticsExportFileFormatCsv:
                return @"CSV";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSBucket

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"creationDate" : @"CreationDate",
             @"name" : @"Name",
             };
}

+ (NSValueTransformer *)creationDateJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

@end

@implementation OOSBucketLifecycleConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"rules" : @"Rules",
             };
}

+ (NSValueTransformer *)rulesJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSLifecycleRule class]];
}

@end

@implementation OOSBucketLoggingStatus

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"loggingEnabled" : @"LoggingEnabled",
             };
}

+ (NSValueTransformer *)loggingEnabledJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSLoggingEnabled class]];
}

@end

@implementation OOSCORSConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"CORSRules" : @"CORSRules",
             };
}

+ (NSValueTransformer *)CORSRulesJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSCORSRule class]];
}

@end

@implementation OOSCORSRule

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"allowedHeaders" : @"AllowedHeaders",
             @"allowedMethods" : @"AllowedMethods",
             @"allowedOrigins" : @"AllowedOrigins",
             @"exposeHeaders" : @"ExposeHeaders",
             @"maxAgeSeconds" : @"MaxAgeSeconds",
			 @"identifier" : @"ID",
             };
}

@end

@implementation OOSCSVInput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"comments" : @"Comments",
             @"fieldDelimiter" : @"FieldDelimiter",
             @"fileHeaderInfo" : @"FileHeaderInfo",
             @"quoteCharacter" : @"QuoteCharacter",
             @"quoteEscapeCharacter" : @"QuoteEscapeCharacter",
             @"recordDelimiter" : @"RecordDelimiter",
             };
}

+ (NSValueTransformer *)fileHeaderInfoJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"USE"] == NSOrderedSame) {
            return @(OOSFileHeaderInfoUse);
        }
        if ([value caseInsensitiveCompare:@"IGNORE"] == NSOrderedSame) {
            return @(OOSFileHeaderInfoIgnore);
        }
        if ([value caseInsensitiveCompare:@"NONE"] == NSOrderedSame) {
            return @(OOSFileHeaderInfoNone);
        }
        return @(OOSFileHeaderInfoUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSFileHeaderInfoUse:
                return @"USE";
            case OOSFileHeaderInfoIgnore:
                return @"IGNORE";
            case OOSFileHeaderInfoNone:
                return @"NONE";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSCSVOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"fieldDelimiter" : @"FieldDelimiter",
             @"quoteCharacter" : @"QuoteCharacter",
             @"quoteEscapeCharacter" : @"QuoteEscapeCharacter",
             @"quoteFields" : @"QuoteFields",
             @"recordDelimiter" : @"RecordDelimiter",
             };
}

+ (NSValueTransformer *)quoteFieldsJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"ALWAYS"] == NSOrderedSame) {
            return @(OOSQuoteFieldsAlways);
        }
        if ([value caseInsensitiveCompare:@"ASNEEDED"] == NSOrderedSame) {
            return @(OOSQuoteFieldsAsneeded);
        }
        return @(OOSQuoteFieldsUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSQuoteFieldsAlways:
                return @"ALWAYS";
            case OOSQuoteFieldsAsneeded:
                return @"ASNEEDED";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSCloudFunctionConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"cloudFunction" : @"CloudFunction",
             @"event" : @"Event",
             @"events" : @"Events",
             @"identifier" : @"Id",
             @"invocationRole" : @"InvocationRole",
             };
}

+ (NSValueTransformer *)eventJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@":ReducedRedundancyLostObject"] == NSOrderedSame) {
            return @(OOSEventReducedRedundancyLostObject);
        }
        if ([value caseInsensitiveCompare:@":ObjectCreated:*"] == NSOrderedSame) {
            return @(OOSEventObjectCreated);
        }
        if ([value caseInsensitiveCompare:@":ObjectCreated:Put"] == NSOrderedSame) {
            return @(OOSEventObjectCreatedPut);
        }
        if ([value caseInsensitiveCompare:@":ObjectCreated:Post"] == NSOrderedSame) {
            return @(OOSEventObjectCreatedPost);
        }
        if ([value caseInsensitiveCompare:@":ObjectCreated:Copy"] == NSOrderedSame) {
            return @(OOSEventObjectCreatedCopy);
        }
        if ([value caseInsensitiveCompare:@":ObjectCreated:CompleteMultipartUpload"] == NSOrderedSame) {
            return @(OOSEventObjectCreatedCompleteMultipartUpload);
        }
        if ([value caseInsensitiveCompare:@":ObjectRemoved:*"] == NSOrderedSame) {
            return @(OOSEventObjectRemoved);
        }
        if ([value caseInsensitiveCompare:@":ObjectRemoved:Delete"] == NSOrderedSame) {
            return @(OOSEventObjectRemovedDelete);
        }
        if ([value caseInsensitiveCompare:@":ObjectRemoved:DeleteMarkerCreated"] == NSOrderedSame) {
            return @(OOSEventObjectRemovedDeleteMarkerCreated);
        }
        return @(OOSEventUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSEventReducedRedundancyLostObject:
                return @":ReducedRedundancyLostObject";
            case OOSEventObjectCreated:
                return @":ObjectCreated:*";
            case OOSEventObjectCreatedPut:
                return @":ObjectCreated:Put";
            case OOSEventObjectCreatedPost:
                return @":ObjectCreated:Post";
            case OOSEventObjectCreatedCopy:
                return @":ObjectCreated:Copy";
            case OOSEventObjectCreatedCompleteMultipartUpload:
                return @":ObjectCreated:CompleteMultipartUpload";
            case OOSEventObjectRemoved:
                return @":ObjectRemoved:*";
            case OOSEventObjectRemovedDelete:
                return @":ObjectRemoved:Delete";
            case OOSEventObjectRemovedDeleteMarkerCreated:
                return @":ObjectRemoved:DeleteMarkerCreated";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSCommonPrefix

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"prefix" : @"Prefix",
             };
}

@end

@implementation OOSCompleteMultipartUploadOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"ETag" : @"ETag",
             @"expiration" : @"Expiration",
             @"key" : @"Key",
             @"location" : @"Location",
             @"requestCharged" : @"RequestCharged",
             @"SSEKMSKeyId" : @"SSEKMSKeyId",
             @"serverSideEncryption" : @"ServerSideEncryption",
             @"versionId" : @"VersionId",
             };
}

+ (NSValueTransformer *)requestChargedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestChargedRequester);
        }
        return @(OOSRequestChargedUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestChargedRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)serverSideEncryptionJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"AES256"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionAES256);
        }
        if ([value caseInsensitiveCompare:@"OOS:kms"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionOOSKms);
        }
        return @(OOSServerSideEncryptionUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSServerSideEncryptionAES256:
                return @"AES256";
            case OOSServerSideEncryptionOOSKms:
                return @"OOS:kms";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSCompleteMultipartUploadRequest

- (instancetype) init {
	self = [super init];
	if (self) {
		self.contentType = @"application/xml";
	}
	
	return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
			 @"bucket" : @"Bucket",
			 @"multipartUpload": @"MultipartUpload",
             @"key" : @"Key",
			 @"contentType" : @"ContentType",
             @"requestPayer" : @"RequestPayer",
             @"uploadId" : @"UploadId",
             };
}

+ (NSValueTransformer *)requestPayerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestPayerRequester);
        }
        return @(OOSRequestPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestPayerRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)multipartUploadJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSCompletedMultipartUpload class]];
}

@end

@implementation OOSCompletedMultipartUpload

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"parts" : @"Parts",
             };
}

+ (NSValueTransformer *)partsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSCompletedPart class]];
}

@end

@implementation OOSCompletedPart

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"ETag" : @"ETag",
             @"partNumber" : @"PartNumber",
             };
}

@end

@implementation OOSCondition

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"httpErrorCodeReturnedEquals" : @"HttpErrorCodeReturnedEquals",
             @"keyPrefixEquals" : @"KeyPrefixEquals",
             };
}

@end

@implementation OOSContinuationEvent

@end

@implementation OOSCopyObjectOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"replicateObjectResult" : @"CopyObjectResult",
             };
}

+ (NSValueTransformer *)replicateObjectResultJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSReplicateObjectResult class]];
}

@end

@implementation OOSCopyObjectRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"ACL" : @"ACL",
             @"bucket" : @"Bucket",
             @"cacheControl" : @"CacheControl",
             @"contentDisposition" : @"ContentDisposition",
             @"contentEncoding" : @"ContentEncoding",
             @"contentLanguage" : @"ContentLanguage",
             @"contentType" : @"ContentType",
             @"replicateSource" : @"CopySource",
             @"replicateSourceIfMatch" : @"CopySourceIfMatch",
             @"replicateSourceIfModifiedSince" : @"CopySourceIfModifiedSince",
             @"replicateSourceIfNoneMatch" : @"CopySourceIfNoneMatch",
             @"replicateSourceIfUnmodifiedSince" : @"CopySourceIfUnmodifiedSince",
             @"replicateSourceSSECustomerAlgorithm" : @"CopySourceSSECustomerAlgorithm",
             @"replicateSourceSSECustomerKey" : @"CopySourceSSECustomerKey",
             @"replicateSourceSSECustomerKeyMD5" : @"CopySourceSSECustomerKeyMD5",
             @"expires" : @"Expires",
             @"grantFullControl" : @"GrantFullControl",
             @"grantRead" : @"GrantRead",
             @"grantReadACP" : @"GrantReadACP",
             @"grantWriteACP" : @"GrantWriteACP",
             @"key" : @"Key",
             @"metadata" : @"Metadata",
             @"metadataDirective" : @"MetadataDirective",
             @"requestPayer" : @"RequestPayer",
             @"SSECustomerAlgorithm" : @"SSECustomerAlgorithm",
             @"SSECustomerKey" : @"SSECustomerKey",
             @"SSECustomerKeyMD5" : @"SSECustomerKeyMD5",
             @"SSEKMSKeyId" : @"SSEKMSKeyId",
             @"serverSideEncryption" : @"ServerSideEncryption",
             @"storageClass" : @"StorageClass",
             @"tagging" : @"Tagging",
             @"taggingDirective" : @"TaggingDirective",
             @"websiteRedirectLocation" : @"WebsiteRedirectLocation",
			 @"dataLocation": @"DataLocation",
             };
}

+ (NSValueTransformer *)ACLJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"private"] == NSOrderedSame) {
            return @(OOSObjectCannedACLPrivate);
        }
        if ([value caseInsensitiveCompare:@"public-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLPublicRead);
        }
        if ([value caseInsensitiveCompare:@"public-read-write"] == NSOrderedSame) {
            return @(OOSObjectCannedACLPublicReadWrite);
        }
        if ([value caseInsensitiveCompare:@"authenticated-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLAuthenticatedRead);
        }
        if ([value caseInsensitiveCompare:@"OOS-exec-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLOOSExecRead);
        }
        if ([value caseInsensitiveCompare:@"bucket-owner-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLBucketOwnerRead);
        }
        if ([value caseInsensitiveCompare:@"bucket-owner-full-control"] == NSOrderedSame) {
            return @(OOSObjectCannedACLBucketOwnerFullControl);
        }
        return @(OOSObjectCannedACLUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSObjectCannedACLPrivate:
                return @"private";
            case OOSObjectCannedACLPublicRead:
                return @"public-read";
            case OOSObjectCannedACLPublicReadWrite:
                return @"public-read-write";
            case OOSObjectCannedACLAuthenticatedRead:
                return @"authenticated-read";
            case OOSObjectCannedACLOOSExecRead:
                return @"OOS-exec-read";
            case OOSObjectCannedACLBucketOwnerRead:
                return @"bucket-owner-read";
            case OOSObjectCannedACLBucketOwnerFullControl:
                return @"bucket-owner-full-control";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)replicateSourceIfModifiedSinceJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)replicateSourceIfUnmodifiedSinceJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)expiresJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)metadataDirectiveJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"COPY"] == NSOrderedSame) {
            return @(OOSMetadataDirectiveCopy);
        }
        if ([value caseInsensitiveCompare:@"REPLACE"] == NSOrderedSame) {
            return @(OOSMetadataDirectiveReplace);
        }
        return @(OOSMetadataDirectiveUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSMetadataDirectiveCopy:
                return @"COPY";
            case OOSMetadataDirectiveReplace:
                return @"REPLACE";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)requestPayerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestPayerRequester);
        }
        return @(OOSRequestPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestPayerRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)serverSideEncryptionJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"AES256"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionAES256);
        }
        if ([value caseInsensitiveCompare:@"OOS:kms"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionOOSKms);
        }
        return @(OOSServerSideEncryptionUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSServerSideEncryptionAES256:
                return @"AES256";
            case OOSServerSideEncryptionOOSKms:
                return @"OOS:kms";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)storageClassJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"STANDARD"] == NSOrderedSame) {
            return @(OOSStorageClassStandard);
        }
        if ([value caseInsensitiveCompare:@"REDUCED_REDUNDANCY"] == NSOrderedSame) {
            return @(OOSStorageClassReducedRedundancy);
        }
        return @(OOSStorageClassUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSStorageClassStandard:
                return @"STANDARD";
            case OOSStorageClassReducedRedundancy:
                return @"REDUCED_REDUNDANCY";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)taggingDirectiveJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"COPY"] == NSOrderedSame) {
            return @(OOSTaggingDirectiveCopy);
        }
        if ([value caseInsensitiveCompare:@"REPLACE"] == NSOrderedSame) {
            return @(OOSTaggingDirectiveReplace);
        }
        return @(OOSTaggingDirectiveUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSTaggingDirectiveCopy:
                return @"COPY";
            case OOSTaggingDirectiveReplace:
                return @"REPLACE";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSReplicateObjectResult

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"ETag" : @"ETag",
             @"lastModified" : @"LastModified",
             };
}

+ (NSValueTransformer *)lastModifiedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

@end

@implementation OOSReplicatePartResult

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"ETag" : @"ETag",
             @"lastModified" : @"LastModified",
             };
}

+ (NSValueTransformer *)lastModifiedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

@end

@implementation OOSMetaDataLocationConstraint

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"location" : @"Location",
			 };
}

@end

@implementation OOSDataLocationList

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"locations" : @"Locations",
			 };
}

@end

@implementation OOSDataLocationConstraint

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"type" : @"Type",
			 @"scheduleStrategy" : @"ScheduleStrategy",
			 @"locationList" : @"LocationList",
			 };
}

+ (NSValueTransformer *)locationListJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSDataLocationList class]];
}

@end

@implementation OOSCreateBucketConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"metadataLocationConstraint" : @"MetadataLocationConstraint",
			 @"dataLocationConstraint" : @"DataLocationConstraint",
             };
}

+ (NSValueTransformer *)metadataLocationConstraintJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSMetaDataLocationConstraint class]];
}

+ (NSValueTransformer *)dataLocationConstraintJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSDataLocationConstraint class]];
}

@end

@implementation OOSCreateBucketOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"location" : @"Location",
             };
}

@end

@implementation OOSCreateBucketRequest

- (instancetype) init {
	self = [super init];
	return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"ACL" : @"ACL",
             @"bucket" : @"Bucket",
             @"createBucketConfiguration" : @"CreateBucketConfiguration",
             @"grantFullControl" : @"GrantFullControl",
             @"grantRead" : @"GrantRead",
             @"grantReadACP" : @"GrantReadACP",
             @"grantWrite" : @"GrantWrite",
             @"grantWriteACP" : @"GrantWriteACP",
             };
}

+ (NSValueTransformer *)ACLJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"private"] == NSOrderedSame) {
            return @(OOSBucketCannedACLPrivate);
        }
        if ([value caseInsensitiveCompare:@"public-read"] == NSOrderedSame) {
            return @(OOSBucketCannedACLPublicRead);
        }
        if ([value caseInsensitiveCompare:@"public-read-write"] == NSOrderedSame) {
            return @(OOSBucketCannedACLPublicReadWrite);
        }
        return @(OOSBucketCannedACLUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSBucketCannedACLPrivate:
                return @"private";
            case OOSBucketCannedACLPublicRead:
                return @"public-read";
            case OOSBucketCannedACLPublicReadWrite:
                return @"public-read-write";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)createBucketConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSCreateBucketConfiguration class]];
}

@end

@implementation OOSCreateMultipartUploadOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"abortDate" : @"AbortDate",
             @"abortRuleId" : @"AbortRuleId",
             @"bucket" : @"Bucket",
             @"key" : @"Key",
             @"requestCharged" : @"RequestCharged",
             @"SSECustomerAlgorithm" : @"SSECustomerAlgorithm",
             @"SSECustomerKeyMD5" : @"SSECustomerKeyMD5",
             @"SSEKMSKeyId" : @"SSEKMSKeyId",
             @"serverSideEncryption" : @"ServerSideEncryption",
             @"uploadId" : @"UploadId",
             };
}

+ (NSValueTransformer *)abortDateJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)requestChargedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestChargedRequester);
        }
        return @(OOSRequestChargedUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestChargedRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)serverSideEncryptionJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"AES256"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionAES256);
        }
        if ([value caseInsensitiveCompare:@"OOS:kms"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionOOSKms);
        }
        return @(OOSServerSideEncryptionUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSServerSideEncryptionAES256:
                return @"AES256";
            case OOSServerSideEncryptionOOSKms:
                return @"OOS:kms";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSCreateMultipartUploadRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"ACL" : @"ACL",
             @"bucket" : @"Bucket",
             @"cacheControl" : @"CacheControl",
             @"contentDisposition" : @"ContentDisposition",
             @"contentEncoding" : @"ContentEncoding",
             @"contentLanguage" : @"ContentLanguage",
             @"contentType" : @"ContentType",
             @"expires" : @"Expires",
             @"grantFullControl" : @"GrantFullControl",
             @"grantRead" : @"GrantRead",
             @"grantReadACP" : @"GrantReadACP",
             @"grantWriteACP" : @"GrantWriteACP",
             @"key" : @"Key",
             @"metadata" : @"Metadata",
             @"requestPayer" : @"RequestPayer",
             @"SSECustomerAlgorithm" : @"SSECustomerAlgorithm",
             @"SSECustomerKey" : @"SSECustomerKey",
             @"SSECustomerKeyMD5" : @"SSECustomerKeyMD5",
             @"SSEKMSKeyId" : @"SSEKMSKeyId",
             @"serverSideEncryption" : @"ServerSideEncryption",
             @"storageClass" : @"StorageClass",
             @"tagging" : @"Tagging",
             @"websiteRedirectLocation" : @"WebsiteRedirectLocation",
			 @"dataLocation": @"DataLocation",
             };
}

+ (NSValueTransformer *)ACLJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"private"] == NSOrderedSame) {
            return @(OOSObjectCannedACLPrivate);
        }
        if ([value caseInsensitiveCompare:@"public-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLPublicRead);
        }
        if ([value caseInsensitiveCompare:@"public-read-write"] == NSOrderedSame) {
            return @(OOSObjectCannedACLPublicReadWrite);
        }
        if ([value caseInsensitiveCompare:@"authenticated-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLAuthenticatedRead);
        }
        if ([value caseInsensitiveCompare:@"OOS-exec-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLOOSExecRead);
        }
        if ([value caseInsensitiveCompare:@"bucket-owner-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLBucketOwnerRead);
        }
        if ([value caseInsensitiveCompare:@"bucket-owner-full-control"] == NSOrderedSame) {
            return @(OOSObjectCannedACLBucketOwnerFullControl);
        }
        return @(OOSObjectCannedACLUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSObjectCannedACLPrivate:
                return @"private";
            case OOSObjectCannedACLPublicRead:
                return @"public-read";
            case OOSObjectCannedACLPublicReadWrite:
                return @"public-read-write";
            case OOSObjectCannedACLAuthenticatedRead:
                return @"authenticated-read";
            case OOSObjectCannedACLOOSExecRead:
                return @"OOS-exec-read";
            case OOSObjectCannedACLBucketOwnerRead:
                return @"bucket-owner-read";
            case OOSObjectCannedACLBucketOwnerFullControl:
                return @"bucket-owner-full-control";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)expiresJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)requestPayerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestPayerRequester);
        }
        return @(OOSRequestPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestPayerRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)serverSideEncryptionJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"AES256"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionAES256);
        }
        if ([value caseInsensitiveCompare:@"OOS:kms"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionOOSKms);
        }
        return @(OOSServerSideEncryptionUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSServerSideEncryptionAES256:
                return @"AES256";
            case OOSServerSideEncryptionOOSKms:
                return @"OOS:kms";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)storageClassJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"STANDARD"] == NSOrderedSame) {
            return @(OOSStorageClassStandard);
        }
        if ([value caseInsensitiveCompare:@"REDUCED_REDUNDANCY"] == NSOrderedSame) {
            return @(OOSStorageClassReducedRedundancy);
        }
        return @(OOSStorageClassUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSStorageClassStandard:
                return @"STANDARD";
            case OOSStorageClassReducedRedundancy:
                return @"REDUCED_REDUNDANCY";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSRemove

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"objects" : @"Objects",
             @"quiet" : @"Quiet",
             };
}

+ (NSValueTransformer *)objectsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSObjectIdentifier class]];
}

@end

@implementation OOSDeleteBucketAnalyticsConfigurationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"identifier" : @"Id",
             };
}

@end

@implementation OOSDeleteBucketCorsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSDeleteBucketEncryptionRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSDeleteBucketInventoryConfigurationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"identifier" : @"Id",
             };
}

@end

@implementation OOSDeleteBucketLifecycleRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSDeleteBucketMetricsConfigurationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"identifier" : @"Id",
             };
}

@end

@implementation OOSDeleteBucketPolicyRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSDeleteBucketReplicationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSDeleteBucketRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSDeleteBucketTaggingRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSDeleteBucketWebsiteRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSDeleteMarkerEntry

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"isLatest" : @"IsLatest",
             @"key" : @"Key",
             @"lastModified" : @"LastModified",
             @"owner" : @"Owner",
             @"versionId" : @"VersionId",
             };
}

+ (NSValueTransformer *)lastModifiedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSOwner class]];
}

@end

@implementation OOSDeleteObjectOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"deleteMarker" : @"DeleteMarker",
             @"requestCharged" : @"RequestCharged",
             @"versionId" : @"VersionId",
             };
}

+ (NSValueTransformer *)requestChargedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestChargedRequester);
        }
        return @(OOSRequestChargedUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestChargedRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSDeleteObjectRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"key" : @"Key",
             @"MFA" : @"MFA",
             @"requestPayer" : @"RequestPayer",
             @"versionId" : @"VersionId",
             };
}

+ (NSValueTransformer *)requestPayerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestPayerRequester);
        }
        return @(OOSRequestPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestPayerRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSDeleteObjectTaggingOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"versionId" : @"VersionId",
             };
}

@end

@implementation OOSDeleteObjectTaggingRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"key" : @"Key",
             @"versionId" : @"VersionId",
             };
}

@end

@implementation OOSDeleteObjectsOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"deleted" : @"Deleted",
             @"errors" : @"Errors",
             @"requestCharged" : @"RequestCharged",
             };
}

+ (NSValueTransformer *)deletedJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSDeletedObject class]];
}

+ (NSValueTransformer *)errorsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSError class]];
}

+ (NSValueTransformer *)requestChargedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestChargedRequester);
        }
        return @(OOSRequestChargedUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestChargedRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSDeleteObjectsRequest

- (instancetype) init {
	self = [super init];
	if (self) {
		self.contentType = @"application/xml";
	}
	
	return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"remove" : @"Delete",
			 @"contentType": @"ContentType",
             @"MFA" : @"MFA",
             @"requestPayer" : @"RequestPayer",
             };
}

+ (NSValueTransformer *)removeJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSRemove class]];
}

+ (NSValueTransformer *)requestPayerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestPayerRequester);
        }
        return @(OOSRequestPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestPayerRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSDeletedObject

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"deleteMarker" : @"DeleteMarker",
             @"deleteMarkerVersionId" : @"DeleteMarkerVersionId",
             @"key" : @"Key",
             @"versionId" : @"VersionId",
             };
}

@end

@implementation OOSDestination

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"accessControlTranslation" : @"AccessControlTranslation",
             @"account" : @"Account",
             @"bucket" : @"Bucket",
             @"encryptionConfiguration" : @"EncryptionConfiguration",
             @"storageClass" : @"StorageClass",
             };
}

+ (NSValueTransformer *)accessControlTranslationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSAccessControlTranslation class]];
}

+ (NSValueTransformer *)encryptionConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSEncryptionConfiguration class]];
}

+ (NSValueTransformer *)storageClassJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"STANDARD"] == NSOrderedSame) {
            return @(OOSStorageClassStandard);
        }
        if ([value caseInsensitiveCompare:@"REDUCED_REDUNDANCY"] == NSOrderedSame) {
            return @(OOSStorageClassReducedRedundancy);
        }
        return @(OOSStorageClassUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSStorageClassStandard:
                return @"STANDARD";
            case OOSStorageClassReducedRedundancy:
                return @"REDUCED_REDUNDANCY";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSEncryption

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"encryptionType" : @"EncryptionType",
             @"KMSContext" : @"KMSContext",
             @"KMSKeyId" : @"KMSKeyId",
             };
}

+ (NSValueTransformer *)encryptionTypeJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"AES256"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionAES256);
        }
        if ([value caseInsensitiveCompare:@"OOS:kms"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionOOSKms);
        }
        return @(OOSServerSideEncryptionUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSServerSideEncryptionAES256:
                return @"AES256";
            case OOSServerSideEncryptionOOSKms:
                return @"OOS:kms";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSEncryptionConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"replicaKmsKeyID" : @"ReplicaKmsKeyID",
             };
}

@end

@implementation OOSEndEvent

@end

@implementation OOSError

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"code" : @"Code",
             @"key" : @"Key",
             @"message" : @"Message",
             @"versionId" : @"VersionId",
             };
}

@end

@implementation OOSErrorDocument

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"key" : @"Key",
             };
}

@end

@implementation OOSFilterRule

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"name" : @"Name",
             @"value" : @"Value",
             };
}

+ (NSValueTransformer *)nameJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"prefix"] == NSOrderedSame) {
            return @(OOSFilterRuleNamePrefix);
        }
        if ([value caseInsensitiveCompare:@"suffix"] == NSOrderedSame) {
            return @(OOSFilterRuleNameSuffix);
        }
        return @(OOSFilterRuleNameUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSFilterRuleNamePrefix:
                return @"prefix";
            case OOSFilterRuleNameSuffix:
                return @"suffix";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSGetBucketAccelerateConfigurationOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"status" : @"Status",
			 @"ipWhiteLists" : @"IPWhiteLists",
             };
}

+ (NSValueTransformer *)statusJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"Enabled"] == NSOrderedSame) {
            return @(OOSBucketAccelerateStatusEnabled);
        }
        if ([value caseInsensitiveCompare:@"Suspended"] == NSOrderedSame) {
            return @(OOSBucketAccelerateStatusSuspended);
        }
        return @(OOSBucketAccelerateStatusUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSBucketAccelerateStatusEnabled:
                return @"Enabled";
            case OOSBucketAccelerateStatusSuspended:
                return @"Suspended";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)ipWhiteListsJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSIPWhiteLists class]];
}

@end

@implementation OOSGetBucketAccelerateConfigurationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSGetBucketAclOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"grants" : @"Grants",
             @"owner" : @"Owner",
             };
}

+ (NSValueTransformer *)grantsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSGrant class]];
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSOwner class]];
}

@end

@implementation OOSGetBucketAclRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSGetBucketAnalyticsConfigurationOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"analyticsConfiguration" : @"AnalyticsConfiguration",
             };
}

+ (NSValueTransformer *)analyticsConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSAnalyticsConfiguration class]];
}

@end

@implementation OOSGetBucketAnalyticsConfigurationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"identifier" : @"Id",
             };
}

@end

@implementation OOSGetBucketCorsOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"CORSRules" : @"CORSRules",
             };
}

+ (NSValueTransformer *)CORSRulesJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSCORSRule class]];
}

@end

@implementation OOSGetBucketCorsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSGetBucketEncryptionOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"serverSideEncryptionConfiguration" : @"ServerSideEncryptionConfiguration",
             };
}

+ (NSValueTransformer *)serverSideEncryptionConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSServerSideEncryptionConfiguration class]];
}

@end

@implementation OOSGetBucketEncryptionRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSGetBucketInventoryConfigurationOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"inventoryConfiguration" : @"InventoryConfiguration",
             };
}

+ (NSValueTransformer *)inventoryConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSInventoryConfiguration class]];
}

@end

@implementation OOSGetBucketInventoryConfigurationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"identifier" : @"Id",
             };
}

@end

@implementation OOSGetBucketLifecycleConfigurationOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"rules" : @"Rules",
             };
}

+ (NSValueTransformer *)rulesJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSLifecycleRule class]];
}

@end

@implementation OOSGetBucketLifecycleConfigurationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSGetBucketLifecycleOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"rules" : @"Rules",
             };
}

+ (NSValueTransformer *)rulesJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSRule class]];
}

@end

@implementation OOSGetBucketLifecycleRequest

- (instancetype) init {
	self = [super init];
	if (self) {
		self.contentType = @"application/xml";
	}
	
	return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSGetBucketLocationOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"createBucketConfiguration" : @"CreateBucketConfiguration",
             };
}

+ (NSValueTransformer *)createBucketConfigurationJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSCreateBucketConfiguration class]];
}

@end

@implementation OOSGetBucketLocationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSGetBucketLoggingOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"loggingEnabled" : @"LoggingEnabled",
             };
}

+ (NSValueTransformer *)loggingEnabledJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSLoggingEnabled class]];
}

@end

@implementation OOSGetBucketLoggingRequest

- (instancetype) init {
	self = [super init];
	if (self) {
		self.contentType = @"application/xml";
	}
	
	return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSGetBucketMetricsConfigurationOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"metricsConfiguration" : @"MetricsConfiguration",
             };
}

+ (NSValueTransformer *)metricsConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSMetricsConfiguration class]];
}

@end

@implementation OOSGetBucketMetricsConfigurationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"identifier" : @"Id",
             };
}

@end

@implementation OOSGetBucketNotificationConfigurationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSGetBucketPolicyOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"policy" : @"Policy",
             };
}

@end

@implementation OOSGetBucketPolicyRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSGetBucketReplicationOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"replicationConfiguration" : @"ReplicationConfiguration",
             };
}

+ (NSValueTransformer *)replicationConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSReplicationConfiguration class]];
}

@end

@implementation OOSGetBucketReplicationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSGetBucketRequestPaymentOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"payer" : @"Payer",
             };
}

+ (NSValueTransformer *)payerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"Requester"] == NSOrderedSame) {
            return @(OOSPayerRequester);
        }
        if ([value caseInsensitiveCompare:@"BucketOwner"] == NSOrderedSame) {
            return @(OOSPayerBucketOwner);
        }
        return @(OOSPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSPayerRequester:
                return @"Requester";
            case OOSPayerBucketOwner:
                return @"BucketOwner";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSGetBucketRequestPaymentRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSGetBucketTaggingOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"tagSet" : @"TagSet",
             };
}

+ (NSValueTransformer *)tagSetJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSTag class]];
}

@end

@implementation OOSGetBucketTaggingRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSGetBucketVersioningOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"MFADelete" : @"MFADelete",
             @"status" : @"Status",
             };
}

+ (NSValueTransformer *)MFADeleteJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"Enabled"] == NSOrderedSame) {
            return @(OOSMFADeleteStatusEnabled);
        }
        if ([value caseInsensitiveCompare:@"Disabled"] == NSOrderedSame) {
            return @(OOSMFADeleteStatusDisabled);
        }
        return @(OOSMFADeleteStatusUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSMFADeleteStatusEnabled:
                return @"Enabled";
            case OOSMFADeleteStatusDisabled:
                return @"Disabled";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)statusJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"Enabled"] == NSOrderedSame) {
            return @(OOSBucketVersioningStatusEnabled);
        }
        if ([value caseInsensitiveCompare:@"Suspended"] == NSOrderedSame) {
            return @(OOSBucketVersioningStatusSuspended);
        }
        return @(OOSBucketVersioningStatusUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSBucketVersioningStatusEnabled:
                return @"Enabled";
            case OOSBucketVersioningStatusSuspended:
                return @"Suspended";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSGetBucketVersioningRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSGetBucketWebsiteOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"errorDocument" : @"ErrorDocument",
             @"indexDocument" : @"IndexDocument",
             };
}

+ (NSValueTransformer *)errorDocumentJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSErrorDocument class]];
}

+ (NSValueTransformer *)indexDocumentJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSIndexDocument class]];
}

+ (NSValueTransformer *)redirectAllRequestsToJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSRedirectAllRequestsTo class]];
}

+ (NSValueTransformer *)routingRulesJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSRoutingRule class]];
}

@end

@implementation OOSGetBucketWebsiteRequest

- (instancetype) init {
	self = [super init];
	if (self) {
		self.contentType = @"application/xml";
	}
	
	return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSGetObjectAclOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"grants" : @"Grants",
             @"owner" : @"Owner",
             @"requestCharged" : @"RequestCharged",
             };
}

+ (NSValueTransformer *)grantsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSGrant class]];
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSOwner class]];
}

+ (NSValueTransformer *)requestChargedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestChargedRequester);
        }
        return @(OOSRequestChargedUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestChargedRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSGetObjectAclRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"key" : @"Key",
             @"requestPayer" : @"RequestPayer",
             @"versionId" : @"VersionId",
             };
}

+ (NSValueTransformer *)requestPayerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestPayerRequester);
        }
        return @(OOSRequestPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestPayerRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSGetObjectOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"acceptRanges" : @"AcceptRanges",
             @"body" : @"Body",
             @"cacheControl" : @"CacheControl",
             @"contentDisposition" : @"ContentDisposition",
             @"contentEncoding" : @"ContentEncoding",
             @"contentLanguage" : @"ContentLanguage",
             @"contentLength" : @"ContentLength",
             @"contentRange" : @"ContentRange",
             @"contentType" : @"ContentType",
             @"deleteMarker" : @"DeleteMarker",
             @"ETag" : @"ETag",
             @"expiration" : @"Expiration",
             @"expires" : @"Expires",
             @"lastModified" : @"LastModified",
             @"metadata" : @"Metadata",
             @"missingMeta" : @"MissingMeta",
             @"partsCount" : @"PartsCount",
             @"replicationStatus" : @"ReplicationStatus",
             @"requestCharged" : @"RequestCharged",
             @"restore" : @"Restore",
             @"SSECustomerAlgorithm" : @"SSECustomerAlgorithm",
             @"SSECustomerKeyMD5" : @"SSECustomerKeyMD5",
             @"SSEKMSKeyId" : @"SSEKMSKeyId",
             @"serverSideEncryption" : @"ServerSideEncryption",
             @"storageClass" : @"StorageClass",
             @"tagCount" : @"TagCount",
             @"versionId" : @"VersionId",
             @"websiteRedirectLocation" : @"WebsiteRedirectLocation",
			 @"dataLocation": @"DataLocation",
			 @"metaDataLocation": @"MetaDataLocation",
             };
}

+ (NSValueTransformer *)expiresJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)lastModifiedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)replicationStatusJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"COMPLETE"] == NSOrderedSame) {
            return @(OOSReplicationStatusComplete);
        }
        if ([value caseInsensitiveCompare:@"PENDING"] == NSOrderedSame) {
            return @(OOSReplicationStatusPending);
        }
        if ([value caseInsensitiveCompare:@"FAILED"] == NSOrderedSame) {
            return @(OOSReplicationStatusFailed);
        }
        if ([value caseInsensitiveCompare:@"REPLICA"] == NSOrderedSame) {
            return @(OOSReplicationStatusReplica);
        }
        return @(OOSReplicationStatusUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSReplicationStatusComplete:
                return @"COMPLETE";
            case OOSReplicationStatusPending:
                return @"PENDING";
            case OOSReplicationStatusFailed:
                return @"FAILED";
            case OOSReplicationStatusReplica:
                return @"REPLICA";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)requestChargedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestChargedRequester);
        }
        return @(OOSRequestChargedUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestChargedRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)serverSideEncryptionJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"AES256"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionAES256);
        }
        if ([value caseInsensitiveCompare:@"OOS:kms"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionOOSKms);
        }
        return @(OOSServerSideEncryptionUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSServerSideEncryptionAES256:
                return @"AES256";
            case OOSServerSideEncryptionOOSKms:
                return @"OOS:kms";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)storageClassJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"STANDARD"] == NSOrderedSame) {
            return @(OOSStorageClassStandard);
        }
        if ([value caseInsensitiveCompare:@"REDUCED_REDUNDANCY"] == NSOrderedSame) {
            return @(OOSStorageClassReducedRedundancy);
        }
        return @(OOSStorageClassUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSStorageClassStandard:
                return @"STANDARD";
            case OOSStorageClassReducedRedundancy:
                return @"REDUCED_REDUNDANCY";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSGetObjectRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"ifMatch" : @"IfMatch",
             @"ifModifiedSince" : @"IfModifiedSince",
             @"ifNoneMatch" : @"IfNoneMatch",
             @"ifUnmodifiedSince" : @"IfUnmodifiedSince",
             @"key" : @"Key",
             @"partNumber" : @"PartNumber",
             @"range" : @"Range",
             @"requestPayer" : @"RequestPayer",
             @"responseCacheControl" : @"ResponseCacheControl",
             @"responseContentDisposition" : @"ResponseContentDisposition",
             @"responseContentEncoding" : @"ResponseContentEncoding",
             @"responseContentLanguage" : @"ResponseContentLanguage",
             @"responseContentType" : @"ResponseContentType",
             @"responseExpires" : @"ResponseExpires",
             @"SSECustomerAlgorithm" : @"SSECustomerAlgorithm",
             @"SSECustomerKey" : @"SSECustomerKey",
             @"SSECustomerKeyMD5" : @"SSECustomerKeyMD5",
             @"versionId" : @"VersionId",
             };
}

+ (NSValueTransformer *)ifModifiedSinceJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)ifUnmodifiedSinceJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)requestPayerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestPayerRequester);
        }
        return @(OOSRequestPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestPayerRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)responseExpiresJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

@end

@implementation OOSGetObjectTaggingOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"tagSet" : @"TagSet",
             @"versionId" : @"VersionId",
             };
}

+ (NSValueTransformer *)tagSetJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSTag class]];
}

@end

@implementation OOSGetObjectTaggingRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"key" : @"Key",
             @"versionId" : @"VersionId",
             };
}

@end

@implementation OOSGetObjectTorrentOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"body" : @"Body",
             @"requestCharged" : @"RequestCharged",
             };
}

+ (NSValueTransformer *)requestChargedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestChargedRequester);
        }
        return @(OOSRequestChargedUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestChargedRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSGetObjectTorrentRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"key" : @"Key",
             @"requestPayer" : @"RequestPayer",
             };
}

+ (NSValueTransformer *)requestPayerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestPayerRequester);
        }
        return @(OOSRequestPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestPayerRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSGlacierJobParameters

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"tier" : @"Tier",
             };
}

+ (NSValueTransformer *)tierJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"Standard"] == NSOrderedSame) {
            return @(OOSTierStandard);
        }
        if ([value caseInsensitiveCompare:@"Bulk"] == NSOrderedSame) {
            return @(OOSTierBulk);
        }
        if ([value caseInsensitiveCompare:@"Expedited"] == NSOrderedSame) {
            return @(OOSTierExpedited);
        }
        return @(OOSTierUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSTierStandard:
                return @"Standard";
            case OOSTierBulk:
                return @"Bulk";
            case OOSTierExpedited:
                return @"Expedited";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSGrant

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"grantee" : @"Grantee",
             @"permission" : @"Permission",
             };
}

+ (NSValueTransformer *)granteeJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSGrantee class]];
}

+ (NSValueTransformer *)permissionJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"FULL_CONTROL"] == NSOrderedSame) {
            return @(OOSPermissionFullControl);
        }
        if ([value caseInsensitiveCompare:@"WRITE"] == NSOrderedSame) {
            return @(OOSPermissionWrite);
        }
        if ([value caseInsensitiveCompare:@"WRITE_ACP"] == NSOrderedSame) {
            return @(OOSPermissionWriteAcp);
        }
        if ([value caseInsensitiveCompare:@"READ"] == NSOrderedSame) {
            return @(OOSPermissionRead);
        }
        if ([value caseInsensitiveCompare:@"READ_ACP"] == NSOrderedSame) {
            return @(OOSPermissionReadAcp);
        }
        return @(OOSPermissionUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSPermissionFullControl:
                return @"FULL_CONTROL";
            case OOSPermissionWrite:
                return @"WRITE";
            case OOSPermissionWriteAcp:
                return @"WRITE_ACP";
            case OOSPermissionRead:
                return @"READ";
            case OOSPermissionReadAcp:
                return @"READ_ACP";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSGrantee

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"displayName" : @"DisplayName",
             @"emailAddress" : @"EmailAddress",
             @"identifier" : @"ID",
             @"types" : @"Type",
             @"URI" : @"URI",
             };
}

+ (NSValueTransformer *)typesJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"CanonicalUser"] == NSOrderedSame) {
            return @(OOSTypesCanonicalUser);
        }
        if ([value caseInsensitiveCompare:@"AmazonCustomerByEmail"] == NSOrderedSame) {
            return @(OOSTypesAmazonCustomerByEmail);
        }
        if ([value caseInsensitiveCompare:@"Group"] == NSOrderedSame) {
            return @(OOSTypesGroup);
        }
        return @(OOSTypesUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSTypesCanonicalUser:
                return @"CanonicalUser";
            case OOSTypesAmazonCustomerByEmail:
                return @"AmazonCustomerByEmail";
            case OOSTypesGroup:
                return @"Group";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSHeadBucketRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             };
}

@end

@implementation OOSHeadObjectOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"acceptRanges" : @"AcceptRanges",
             @"cacheControl" : @"CacheControl",
             @"contentDisposition" : @"ContentDisposition",
             @"contentEncoding" : @"ContentEncoding",
             @"contentLanguage" : @"ContentLanguage",
             @"contentLength" : @"ContentLength",
             @"contentType" : @"ContentType",
             @"deleteMarker" : @"DeleteMarker",
             @"ETag" : @"ETag",
             @"expiration" : @"Expiration",
             @"expires" : @"Expires",
             @"lastModified" : @"LastModified",
             @"metadata" : @"Metadata",
             @"missingMeta" : @"MissingMeta",
             @"partsCount" : @"PartsCount",
             @"replicationStatus" : @"ReplicationStatus",
             @"requestCharged" : @"RequestCharged",
             @"restore" : @"Restore",
             @"SSECustomerAlgorithm" : @"SSECustomerAlgorithm",
             @"SSECustomerKeyMD5" : @"SSECustomerKeyMD5",
             @"SSEKMSKeyId" : @"SSEKMSKeyId",
             @"serverSideEncryption" : @"ServerSideEncryption",
             @"storageClass" : @"StorageClass",
             @"versionId" : @"VersionId",
             @"websiteRedirectLocation" : @"WebsiteRedirectLocation",
			 @"dataLocation": @"DataLocation",
			 @"metadataLocation": @"MetadataLocation"
             };
}

+ (NSValueTransformer *)expiresJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)lastModifiedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)replicationStatusJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"COMPLETE"] == NSOrderedSame) {
            return @(OOSReplicationStatusComplete);
        }
        if ([value caseInsensitiveCompare:@"PENDING"] == NSOrderedSame) {
            return @(OOSReplicationStatusPending);
        }
        if ([value caseInsensitiveCompare:@"FAILED"] == NSOrderedSame) {
            return @(OOSReplicationStatusFailed);
        }
        if ([value caseInsensitiveCompare:@"REPLICA"] == NSOrderedSame) {
            return @(OOSReplicationStatusReplica);
        }
        return @(OOSReplicationStatusUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSReplicationStatusComplete:
                return @"COMPLETE";
            case OOSReplicationStatusPending:
                return @"PENDING";
            case OOSReplicationStatusFailed:
                return @"FAILED";
            case OOSReplicationStatusReplica:
                return @"REPLICA";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)requestChargedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestChargedRequester);
        }
        return @(OOSRequestChargedUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestChargedRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)serverSideEncryptionJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"AES256"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionAES256);
        }
        if ([value caseInsensitiveCompare:@"OOS:kms"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionOOSKms);
        }
        return @(OOSServerSideEncryptionUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSServerSideEncryptionAES256:
                return @"AES256";
            case OOSServerSideEncryptionOOSKms:
                return @"OOS:kms";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)storageClassJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"STANDARD"] == NSOrderedSame) {
            return @(OOSStorageClassStandard);
        }
        if ([value caseInsensitiveCompare:@"REDUCED_REDUNDANCY"] == NSOrderedSame) {
            return @(OOSStorageClassReducedRedundancy);
        }
        return @(OOSStorageClassUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSStorageClassStandard:
                return @"STANDARD";
            case OOSStorageClassReducedRedundancy:
                return @"REDUCED_REDUNDANCY";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSHeadObjectRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"ifMatch" : @"IfMatch",
             @"ifModifiedSince" : @"IfModifiedSince",
             @"ifNoneMatch" : @"IfNoneMatch",
             @"ifUnmodifiedSince" : @"IfUnmodifiedSince",
             @"key" : @"Key",
             @"partNumber" : @"PartNumber",
             @"range" : @"Range",
             @"requestPayer" : @"RequestPayer",
             @"SSECustomerAlgorithm" : @"SSECustomerAlgorithm",
             @"SSECustomerKey" : @"SSECustomerKey",
             @"SSECustomerKeyMD5" : @"SSECustomerKeyMD5",
             @"versionId" : @"VersionId",
             };
}

+ (NSValueTransformer *)ifModifiedSinceJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)ifUnmodifiedSinceJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)requestPayerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestPayerRequester);
        }
        return @(OOSRequestPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestPayerRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSIndexDocument

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"suffix" : @"Suffix",
             };
}

@end

@implementation OOSInitiator

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"displayName" : @"DisplayName",
             @"identifier" : @"ID",
             };
}

@end

@implementation OOSInputSerialization

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"CSV" : @"CSV",
             @"compressionType" : @"CompressionType",
             @"JSON" : @"JSON",
             };
}

+ (NSValueTransformer *)CSVJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSCSVInput class]];
}

+ (NSValueTransformer *)compressionTypeJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"NONE"] == NSOrderedSame) {
            return @(OOSCompressionTypeNone);
        }
        if ([value caseInsensitiveCompare:@"GZIP"] == NSOrderedSame) {
            return @(OOSCompressionTypeGzip);
        }
        return @(OOSCompressionTypeUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSCompressionTypeNone:
                return @"NONE";
            case OOSCompressionTypeGzip:
                return @"GZIP";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)JSONJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSJSONInput class]];
}

@end

@implementation OOSInventoryConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"destination" : @"Destination",
             @"filter" : @"Filter",
             @"identifier" : @"Id",
             @"includedObjectVersions" : @"IncludedObjectVersions",
             @"isEnabled" : @"IsEnabled",
             @"optionalFields" : @"OptionalFields",
             @"schedule" : @"Schedule",
             };
}

+ (NSValueTransformer *)destinationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSInventoryDestination class]];
}

+ (NSValueTransformer *)filterJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSInventoryFilter class]];
}

+ (NSValueTransformer *)includedObjectVersionsJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"All"] == NSOrderedSame) {
            return @(OOSInventoryIncludedObjectVersionsAll);
        }
        if ([value caseInsensitiveCompare:@"Current"] == NSOrderedSame) {
            return @(OOSInventoryIncludedObjectVersionsCurrent);
        }
        return @(OOSInventoryIncludedObjectVersionsUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSInventoryIncludedObjectVersionsAll:
                return @"All";
            case OOSInventoryIncludedObjectVersionsCurrent:
                return @"Current";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)scheduleJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSInventorySchedule class]];
}

@end

@implementation OOSInventoryDestination

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"BucketDestination" : @"BucketDestination",
             };
}

+ (NSValueTransformer *)BucketDestinationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSInventoryBucketDestination class]];
}

@end

@implementation OOSInventoryEncryption

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"SSEKMS" : @"SSEKMS",
             @"SSE" : @"SSE",
             };
}

+ (NSValueTransformer *)SSEKMSJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSSSEKMS class]];
}

+ (NSValueTransformer *)SSEJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSSSE class]];
}

@end

@implementation OOSInventoryFilter

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"prefix" : @"Prefix",
             };
}

@end

@implementation OOSInventoryBucketDestination

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"accountId" : @"AccountId",
             @"bucket" : @"Bucket",
             @"encryption" : @"Encryption",
             @"format" : @"Format",
             @"prefix" : @"Prefix",
             };
}

+ (NSValueTransformer *)encryptionJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSInventoryEncryption class]];
}

+ (NSValueTransformer *)formatJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"CSV"] == NSOrderedSame) {
            return @(OOSInventoryFormatCsv);
        }
        if ([value caseInsensitiveCompare:@"ORC"] == NSOrderedSame) {
            return @(OOSInventoryFormatOrc);
        }
        return @(OOSInventoryFormatUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSInventoryFormatCsv:
                return @"CSV";
            case OOSInventoryFormatOrc:
                return @"ORC";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSInventorySchedule

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"frequency" : @"Frequency",
             };
}

+ (NSValueTransformer *)frequencyJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"Daily"] == NSOrderedSame) {
            return @(OOSInventoryFrequencyDaily);
        }
        if ([value caseInsensitiveCompare:@"Weekly"] == NSOrderedSame) {
            return @(OOSInventoryFrequencyWeekly);
        }
        return @(OOSInventoryFrequencyUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSInventoryFrequencyDaily:
                return @"Daily";
            case OOSInventoryFrequencyWeekly:
                return @"Weekly";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSJSONInput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"types" : @"Type",
             };
}

+ (NSValueTransformer *)typesJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"DOCUMENT"] == NSOrderedSame) {
            return @(OOSJSONTypeDocument);
        }
        if ([value caseInsensitiveCompare:@"LINES"] == NSOrderedSame) {
            return @(OOSJSONTypeLines);
        }
        return @(OOSJSONTypeUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSJSONTypeDocument:
                return @"DOCUMENT";
            case OOSJSONTypeLines:
                return @"LINES";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSJSONOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"recordDelimiter" : @"RecordDelimiter",
             };
}

@end

@implementation OOSLambdaFunctionConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"events" : @"Events",
             @"filter" : @"Filter",
             @"identifier" : @"Id",
             @"lambdaFunctionArn" : @"LambdaFunctionArn",
             };
}

+ (NSValueTransformer *)filterJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSNotificationConfigurationFilter class]];
}

@end

@implementation OOSLifecycleConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"rules" : @"Rules",
             };
}

+ (NSValueTransformer *)rulesJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSRule class]];
}

@end

@implementation OOSLifecycleExpiration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"date" : @"Date",
             @"days" : @"Days",
             @"expiredObjectDeleteMarker" : @"ExpiredObjectDeleteMarker",
             };
}

+ (NSValueTransformer *)dateJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

@end

@implementation OOSLifecycleRule

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"abortIncompleteMultipartUpload" : @"AbortIncompleteMultipartUpload",
             @"expiration" : @"Expiration",
             @"filter" : @"Filter",
             @"identifier" : @"ID",
             @"noncurrentVersionExpiration" : @"NoncurrentVersionExpiration",
             @"noncurrentVersionTransitions" : @"NoncurrentVersionTransitions",
             @"prefix" : @"Prefix",
             @"status" : @"Status",
             @"transitions" : @"Transitions",
             };
}

+ (NSValueTransformer *)abortIncompleteMultipartUploadJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSAbortIncompleteMultipartUpload class]];
}

+ (NSValueTransformer *)expirationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSLifecycleExpiration class]];
}

+ (NSValueTransformer *)filterJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSLifecycleRuleFilter class]];
}

+ (NSValueTransformer *)noncurrentVersionExpirationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSNoncurrentVersionExpiration class]];
}

+ (NSValueTransformer *)noncurrentVersionTransitionsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSNoncurrentVersionTransition class]];
}

+ (NSValueTransformer *)statusJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"Enabled"] == NSOrderedSame) {
            return @(OOSExpirationStatusEnabled);
        }
        if ([value caseInsensitiveCompare:@"Disabled"] == NSOrderedSame) {
            return @(OOSExpirationStatusDisabled);
        }
        return @(OOSExpirationStatusUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSExpirationStatusEnabled:
                return @"Enabled";
            case OOSExpirationStatusDisabled:
                return @"Disabled";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)transitionsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSTransition class]];
}

@end

@implementation OOSLifecycleRuleAndOperator

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"prefix" : @"Prefix",
             @"tags" : @"Tags",
             };
}

+ (NSValueTransformer *)tagsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSTag class]];
}

@end

@implementation OOSLifecycleRuleFilter

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"AND" : @"And",
             @"prefix" : @"Prefix",
             @"tag" : @"Tag",
             };
}

+ (NSValueTransformer *)ANDJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSLifecycleRuleAndOperator class]];
}

+ (NSValueTransformer *)tagJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSTag class]];
}

@end

@implementation OOSListBucketAnalyticsConfigurationsOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"analyticsConfigurationList" : @"AnalyticsConfigurationList",
             @"continuationToken" : @"ContinuationToken",
             @"isTruncated" : @"IsTruncated",
             @"nextContinuationToken" : @"NextContinuationToken",
             };
}

+ (NSValueTransformer *)analyticsConfigurationListJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSAnalyticsConfiguration class]];
}

@end

@implementation OOSListBucketAnalyticsConfigurationsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"continuationToken" : @"ContinuationToken",
             };
}

@end

@implementation OOSListBucketInventoryConfigurationsOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"continuationToken" : @"ContinuationToken",
             @"inventoryConfigurationList" : @"InventoryConfigurationList",
             @"isTruncated" : @"IsTruncated",
             @"nextContinuationToken" : @"NextContinuationToken",
             };
}

+ (NSValueTransformer *)inventoryConfigurationListJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSInventoryConfiguration class]];
}

@end

@implementation OOSListBucketInventoryConfigurationsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"continuationToken" : @"ContinuationToken",
             };
}

@end

@implementation OOSListBucketMetricsConfigurationsOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"continuationToken" : @"ContinuationToken",
             @"isTruncated" : @"IsTruncated",
             @"metricsConfigurationList" : @"MetricsConfigurationList",
             @"nextContinuationToken" : @"NextContinuationToken",
             };
}

+ (NSValueTransformer *)metricsConfigurationListJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSMetricsConfiguration class]];
}

@end

@implementation OOSListBucketMetricsConfigurationsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"continuationToken" : @"ContinuationToken",
             };
}

@end

@implementation OOSListBucketsOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"buckets" : @"Buckets",
             @"owner" : @"Owner",
             };
}

+ (NSValueTransformer *)bucketsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSBucket class]];
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSOwner class]];
}

@end

@implementation OOSListMultipartUploadsOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"commonPrefixes" : @"CommonPrefixes",
             @"delimiter" : @"Delimiter",
             @"encodingType" : @"EncodingType",
             @"isTruncated" : @"IsTruncated",
             @"keyMarker" : @"KeyMarker",
             @"maxUploads" : @"MaxUploads",
             @"nextKeyMarker" : @"NextKeyMarker",
             @"nextUploadIdMarker" : @"NextUploadIdMarker",
             @"prefix" : @"Prefix",
             @"uploadIdMarker" : @"UploadIdMarker",
             @"uploads" : @"Uploads",
             };
}

+ (NSValueTransformer *)commonPrefixesJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSCommonPrefix class]];
}

+ (NSValueTransformer *)encodingTypeJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"url"] == NSOrderedSame) {
            return @(OOSEncodingTypeURL);
        }
        return @(OOSEncodingTypeUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSEncodingTypeURL:
                return @"url";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)uploadsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSMultipartUpload class]];
}

@end

@implementation OOSListMultipartUploadsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"delimiter" : @"Delimiter",
             @"encodingType" : @"EncodingType",
             @"keyMarker" : @"KeyMarker",
             @"maxUploads" : @"MaxUploads",
             @"prefix" : @"Prefix",
             @"uploadIdMarker" : @"UploadIdMarker",
             };
}

+ (NSValueTransformer *)encodingTypeJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"url"] == NSOrderedSame) {
            return @(OOSEncodingTypeURL);
        }
        return @(OOSEncodingTypeUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSEncodingTypeURL:
                return @"url";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSListObjectVersionsOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"commonPrefixes" : @"CommonPrefixes",
             @"deleteMarkers" : @"DeleteMarkers",
             @"delimiter" : @"Delimiter",
             @"encodingType" : @"EncodingType",
             @"isTruncated" : @"IsTruncated",
             @"keyMarker" : @"KeyMarker",
             @"maxKeys" : @"MaxKeys",
             @"name" : @"Name",
             @"nextKeyMarker" : @"NextKeyMarker",
             @"nextVersionIdMarker" : @"NextVersionIdMarker",
             @"prefix" : @"Prefix",
             @"versionIdMarker" : @"VersionIdMarker",
             @"versions" : @"Versions",
             };
}

+ (NSValueTransformer *)commonPrefixesJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSCommonPrefix class]];
}

+ (NSValueTransformer *)deleteMarkersJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSDeleteMarkerEntry class]];
}

+ (NSValueTransformer *)encodingTypeJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"url"] == NSOrderedSame) {
            return @(OOSEncodingTypeURL);
        }
        return @(OOSEncodingTypeUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSEncodingTypeURL:
                return @"url";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)versionsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSObjectVersion class]];
}

@end

@implementation OOSListObjectVersionsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"delimiter" : @"Delimiter",
             @"encodingType" : @"EncodingType",
             @"keyMarker" : @"KeyMarker",
             @"maxKeys" : @"MaxKeys",
             @"prefix" : @"Prefix",
             @"versionIdMarker" : @"VersionIdMarker",
             };
}

+ (NSValueTransformer *)encodingTypeJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"url"] == NSOrderedSame) {
            return @(OOSEncodingTypeURL);
        }
        return @(OOSEncodingTypeUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSEncodingTypeURL:
                return @"url";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSListObjectsOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"commonPrefixes" : @"CommonPrefixes",
             @"contents" : @"Contents",
             @"delimiter" : @"Delimiter",
             @"encodingType" : @"EncodingType",
             @"isTruncated" : @"IsTruncated",
             @"marker" : @"Marker",
             @"maxKeys" : @"MaxKeys",
             @"name" : @"Name",
             @"nextMarker" : @"NextMarker",
             @"prefix" : @"Prefix",
             };
}

+ (NSValueTransformer *)commonPrefixesJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSCommonPrefix class]];
}

+ (NSValueTransformer *)contentsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSObject class]];
}

+ (NSValueTransformer *)encodingTypeJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"url"] == NSOrderedSame) {
            return @(OOSEncodingTypeURL);
        }
        return @(OOSEncodingTypeUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSEncodingTypeURL:
                return @"url";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSListObjectsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"delimiter" : @"Delimiter",
             @"encodingType" : @"EncodingType",
             @"marker" : @"Marker",
             @"maxKeys" : @"MaxKeys",
             @"prefix" : @"Prefix",
             @"requestPayer" : @"RequestPayer",
             };
}

+ (NSValueTransformer *)encodingTypeJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"url"] == NSOrderedSame) {
            return @(OOSEncodingTypeURL);
        }
        return @(OOSEncodingTypeUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSEncodingTypeURL:
                return @"url";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)requestPayerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestPayerRequester);
        }
        return @(OOSRequestPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestPayerRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSListObjectsV2Output

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"commonPrefixes" : @"CommonPrefixes",
             @"contents" : @"Contents",
             @"continuationToken" : @"ContinuationToken",
             @"delimiter" : @"Delimiter",
             @"encodingType" : @"EncodingType",
             @"isTruncated" : @"IsTruncated",
             @"keyCount" : @"KeyCount",
             @"maxKeys" : @"MaxKeys",
             @"name" : @"Name",
             @"nextContinuationToken" : @"NextContinuationToken",
             @"prefix" : @"Prefix",
             @"startAfter" : @"StartAfter",
             };
}

+ (NSValueTransformer *)commonPrefixesJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSCommonPrefix class]];
}

+ (NSValueTransformer *)contentsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSObject class]];
}

+ (NSValueTransformer *)encodingTypeJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"url"] == NSOrderedSame) {
            return @(OOSEncodingTypeURL);
        }
        return @(OOSEncodingTypeUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSEncodingTypeURL:
                return @"url";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSListObjectsV2Request

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"continuationToken" : @"ContinuationToken",
             @"delimiter" : @"Delimiter",
             @"encodingType" : @"EncodingType",
             @"fetchOwner" : @"FetchOwner",
             @"maxKeys" : @"MaxKeys",
             @"prefix" : @"Prefix",
             @"requestPayer" : @"RequestPayer",
             @"startAfter" : @"StartAfter",
             };
}

+ (NSValueTransformer *)encodingTypeJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"url"] == NSOrderedSame) {
            return @(OOSEncodingTypeURL);
        }
        return @(OOSEncodingTypeUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSEncodingTypeURL:
                return @"url";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)requestPayerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestPayerRequester);
        }
        return @(OOSRequestPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestPayerRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSListPartsOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"abortDate" : @"AbortDate",
             @"abortRuleId" : @"AbortRuleId",
             @"bucket" : @"Bucket",
             @"initiator" : @"Initiator",
             @"isTruncated" : @"IsTruncated",
             @"key" : @"Key",
             @"maxParts" : @"MaxParts",
             @"nextPartNumberMarker" : @"NextPartNumberMarker",
             @"owner" : @"Owner",
             @"partNumberMarker" : @"PartNumberMarker",
             @"parts" : @"Parts",
             @"requestCharged" : @"RequestCharged",
             @"storageClass" : @"StorageClass",
             @"uploadId" : @"UploadId",
             };
}

+ (NSValueTransformer *)abortDateJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)initiatorJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSInitiator class]];
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSOwner class]];
}

+ (NSValueTransformer *)partsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSPart class]];
}

+ (NSValueTransformer *)requestChargedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestChargedRequester);
        }
        return @(OOSRequestChargedUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestChargedRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)storageClassJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"STANDARD"] == NSOrderedSame) {
            return @(OOSStorageClassStandard);
        }
        if ([value caseInsensitiveCompare:@"REDUCED_REDUNDANCY"] == NSOrderedSame) {
            return @(OOSStorageClassReducedRedundancy);
        }
        return @(OOSStorageClassUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSStorageClassStandard:
                return @"STANDARD";
            case OOSStorageClassReducedRedundancy:
                return @"REDUCED_REDUNDANCY";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSListPartsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"key" : @"Key",
             @"maxParts" : @"MaxParts",
             @"partNumberMarker" : @"PartNumberMarker",
             @"requestPayer" : @"RequestPayer",
             @"uploadId" : @"UploadId",
             };
}

+ (NSValueTransformer *)requestPayerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestPayerRequester);
        }
        return @(OOSRequestPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestPayerRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSLoggingEnabled

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"targetBucket" : @"TargetBucket",
             @"targetPrefix" : @"TargetPrefix",
             };
}

+ (NSValueTransformer *)targetGrantsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSTargetGrant class]];
}

@end

@implementation OOSMetadataEntry

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"name" : @"Name",
             @"value" : @"Value",
             };
}

@end

@implementation OOSMetricsAndOperator

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"prefix" : @"Prefix",
             @"tags" : @"Tags",
             };
}

+ (NSValueTransformer *)tagsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSTag class]];
}

@end

@implementation OOSMetricsConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"filter" : @"Filter",
             @"identifier" : @"Id",
             };
}

+ (NSValueTransformer *)filterJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSMetricsFilter class]];
}

@end

@implementation OOSMetricsFilter

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"AND" : @"And",
             @"prefix" : @"Prefix",
             @"tag" : @"Tag",
             };
}

+ (NSValueTransformer *)ANDJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSMetricsAndOperator class]];
}

+ (NSValueTransformer *)tagJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSTag class]];
}

@end

@implementation OOSMultipartUpload

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"initiated" : @"Initiated",
             @"initiator" : @"Initiator",
             @"key" : @"Key",
             @"owner" : @"Owner",
             @"storageClass" : @"StorageClass",
             @"uploadId" : @"UploadId",
             };
}

+ (NSValueTransformer *)initiatedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)initiatorJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSInitiator class]];
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSOwner class]];
}

+ (NSValueTransformer *)storageClassJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"STANDARD"] == NSOrderedSame) {
            return @(OOSStorageClassStandard);
        }
        if ([value caseInsensitiveCompare:@"REDUCED_REDUNDANCY"] == NSOrderedSame) {
            return @(OOSStorageClassReducedRedundancy);
        }
        return @(OOSStorageClassUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSStorageClassStandard:
                return @"STANDARD";
            case OOSStorageClassReducedRedundancy:
                return @"REDUCED_REDUNDANCY";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSNoncurrentVersionExpiration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"noncurrentDays" : @"NoncurrentDays",
             };
}

@end

@implementation OOSNoncurrentVersionTransition

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"noncurrentDays" : @"NoncurrentDays",
             @"storageClass" : @"StorageClass",
             };
}

+ (NSValueTransformer *)storageClassJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"GLACIER"] == NSOrderedSame) {
            return @(OOSTransitionStorageClassGlacier);
        }
        if ([value caseInsensitiveCompare:@"STANDARD_IA"] == NSOrderedSame) {
            return @(OOSTransitionStorageClassStandardIa);
        }
        if ([value caseInsensitiveCompare:@"ONEZONE_IA"] == NSOrderedSame) {
            return @(OOSTransitionStorageClassOnezoneIa);
        }
        return @(OOSTransitionStorageClassUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSTransitionStorageClassGlacier:
                return @"GLACIER";
            case OOSTransitionStorageClassStandardIa:
                return @"STANDARD_IA";
            case OOSTransitionStorageClassOnezoneIa:
                return @"ONEZONE_IA";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSNotificationConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"lambdaFunctionConfigurations" : @"LambdaFunctionConfigurations",
             @"queueConfigurations" : @"QueueConfigurations",
             @"topicConfigurations" : @"TopicConfigurations",
             };
}

+ (NSValueTransformer *)lambdaFunctionConfigurationsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSLambdaFunctionConfiguration class]];
}

+ (NSValueTransformer *)queueConfigurationsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSQueueConfiguration class]];
}

+ (NSValueTransformer *)topicConfigurationsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSTopicConfiguration class]];
}

@end

@implementation OOSNotificationConfigurationDeprecated

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"cloudFunctionConfiguration" : @"CloudFunctionConfiguration",
             @"queueConfiguration" : @"QueueConfiguration",
             @"topicConfiguration" : @"TopicConfiguration",
             };
}

+ (NSValueTransformer *)cloudFunctionConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSCloudFunctionConfiguration class]];
}

+ (NSValueTransformer *)queueConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSQueueConfigurationDeprecated class]];
}

+ (NSValueTransformer *)topicConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSTopicConfigurationDeprecated class]];
}

@end

@implementation OOSNotificationConfigurationFilter

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"key" : @"Key",
             };
}

+ (NSValueTransformer *)keyJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSKeyFilter class]];
}

@end

@implementation OOSObject

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"ETag" : @"ETag",
             @"key" : @"Key",
             @"lastModified" : @"LastModified",
             @"owner" : @"Owner",
             @"size" : @"Size",
             @"storageClass" : @"StorageClass",
             };
}

+ (NSValueTransformer *)lastModifiedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSOwner class]];
}

+ (NSValueTransformer *)storageClassJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"STANDARD"] == NSOrderedSame) {
            return @(OOSObjectStorageClassStandard);
        }
        if ([value caseInsensitiveCompare:@"REDUCED_REDUNDANCY"] == NSOrderedSame) {
            return @(OOSObjectStorageClassReducedRedundancy);
        }
        if ([value caseInsensitiveCompare:@"GLACIER"] == NSOrderedSame) {
            return @(OOSObjectStorageClassGlacier);
        }
        if ([value caseInsensitiveCompare:@"STANDARD_IA"] == NSOrderedSame) {
            return @(OOSObjectStorageClassStandardIa);
        }
        if ([value caseInsensitiveCompare:@"ONEZONE_IA"] == NSOrderedSame) {
            return @(OOSObjectStorageClassOnezoneIa);
        }
        return @(OOSObjectStorageClassUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSObjectStorageClassStandard:
                return @"STANDARD";
            case OOSObjectStorageClassReducedRedundancy:
                return @"REDUCED_REDUNDANCY";
            case OOSObjectStorageClassGlacier:
                return @"GLACIER";
            case OOSObjectStorageClassStandardIa:
                return @"STANDARD_IA";
            case OOSObjectStorageClassOnezoneIa:
                return @"ONEZONE_IA";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSObjectIdentifier

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"key" : @"Key",
             @"versionId" : @"VersionId",
             };
}

@end

@implementation OOSObjectVersion

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"ETag" : @"ETag",
             @"isLatest" : @"IsLatest",
             @"key" : @"Key",
             @"lastModified" : @"LastModified",
             @"owner" : @"Owner",
             @"size" : @"Size",
             @"storageClass" : @"StorageClass",
             @"versionId" : @"VersionId",
             };
}

+ (NSValueTransformer *)lastModifiedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSOwner class]];
}

+ (NSValueTransformer *)storageClassJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"STANDARD"] == NSOrderedSame) {
            return @(OOSObjectVersionStorageClassStandard);
        }
        return @(OOSObjectVersionStorageClassUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSObjectVersionStorageClassStandard:
                return @"STANDARD";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSOutputSerialization

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"CSV" : @"CSV",
             @"JSON" : @"JSON",
             };
}

+ (NSValueTransformer *)CSVJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSCSVOutput class]];
}

+ (NSValueTransformer *)JSONJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSJSONOutput class]];
}

@end

@implementation OOSOwner

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"displayName" : @"DisplayName",
             @"identifier" : @"ID",
             };
}

@end

@implementation OOSPart

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"ETag" : @"ETag",
             @"lastModified" : @"LastModified",
             @"partNumber" : @"PartNumber",
             @"size" : @"Size",
             };
}

+ (NSValueTransformer *)lastModifiedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

@end

@implementation OOSProgress

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bytesProcessed" : @"BytesProcessed",
             @"bytesScanned" : @"BytesScanned",
             };
}

@end

@implementation OOSProgressEvent

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"details" : @"Details",
             };
}

+ (NSValueTransformer *)detailsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSProgress class]];
}

@end

@implementation OOSPutBucketAccelerateConfigurationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"accelerateConfiguration" : @"AccelerateConfiguration",
             @"bucket" : @"Bucket",
             };
}

+ (NSValueTransformer *)accelerateConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSAccelerateConfiguration class]];
}

@end

@implementation OOSPutBucketAclRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"ACL" : @"ACL",
             @"accessControlPolicy" : @"AccessControlPolicy",
             @"bucket" : @"Bucket",
             @"contentMD5" : @"ContentMD5",
             @"grantFullControl" : @"GrantFullControl",
             @"grantRead" : @"GrantRead",
             @"grantReadACP" : @"GrantReadACP",
             @"grantWrite" : @"GrantWrite",
             @"grantWriteACP" : @"GrantWriteACP",
             };
}

+ (NSValueTransformer *)ACLJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"private"] == NSOrderedSame) {
            return @(OOSBucketCannedACLPrivate);
        }
        if ([value caseInsensitiveCompare:@"public-read"] == NSOrderedSame) {
            return @(OOSBucketCannedACLPublicRead);
        }
        if ([value caseInsensitiveCompare:@"public-read-write"] == NSOrderedSame) {
            return @(OOSBucketCannedACLPublicReadWrite);
        }
        return @(OOSBucketCannedACLUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSBucketCannedACLPrivate:
                return @"private";
            case OOSBucketCannedACLPublicRead:
                return @"public-read";
            case OOSBucketCannedACLPublicReadWrite:
                return @"public-read-write";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)accessControlPolicyJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSAccessControlPolicy class]];
}

@end

@implementation OOSPutBucketAnalyticsConfigurationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"analyticsConfiguration" : @"AnalyticsConfiguration",
             @"bucket" : @"Bucket",
             @"identifier" : @"Id",
             };
}

+ (NSValueTransformer *)analyticsConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSAnalyticsConfiguration class]];
}

@end

@implementation OOSPutBucketCorsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"CORSConfiguration" : @"CORSConfiguration",
             @"contentMD5" : @"ContentMD5",
             };
}

+ (NSValueTransformer *)CORSConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSCORSConfiguration class]];
}

@end

@implementation OOSPutBucketEncryptionRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"contentMD5" : @"ContentMD5",
             @"serverSideEncryptionConfiguration" : @"ServerSideEncryptionConfiguration",
             };
}

+ (NSValueTransformer *)serverSideEncryptionConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSServerSideEncryptionConfiguration class]];
}

@end

@implementation OOSPutBucketInventoryConfigurationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"identifier" : @"Id",
             @"inventoryConfiguration" : @"InventoryConfiguration",
             };
}

+ (NSValueTransformer *)inventoryConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSInventoryConfiguration class]];
}

@end

@implementation OOSPutBucketLifecycleConfigurationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"lifecycleConfiguration" : @"LifecycleConfiguration",
             };
}

+ (NSValueTransformer *)lifecycleConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSBucketLifecycleConfiguration class]];
}

@end

@implementation OOSPutBucketLifecycleRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"contentMD5" : @"ContentMD5",
             @"lifecycleConfiguration" : @"LifecycleConfiguration",
             };
}

+ (NSValueTransformer *)lifecycleConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSLifecycleConfiguration class]];
}

@end

@implementation OOSPutBucketLoggingRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"bucketLoggingStatus" : @"BucketLoggingStatus",
             @"contentMD5" : @"ContentMD5",
             };
}

+ (NSValueTransformer *)bucketLoggingStatusJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSBucketLoggingStatus class]];
}

@end

@implementation OOSPutBucketMetricsConfigurationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"identifier" : @"Id",
             @"metricsConfiguration" : @"MetricsConfiguration",
             };
}

+ (NSValueTransformer *)metricsConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSMetricsConfiguration class]];
}

@end

@implementation OOSPutBucketNotificationConfigurationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"notificationConfiguration" : @"NotificationConfiguration",
             };
}

+ (NSValueTransformer *)notificationConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSNotificationConfiguration class]];
}

@end

@implementation OOSPutBucketNotificationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"contentMD5" : @"ContentMD5",
             @"notificationConfiguration" : @"NotificationConfiguration",
             };
}

+ (NSValueTransformer *)notificationConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSNotificationConfigurationDeprecated class]];
}

@end

@implementation OOSPutBucketPolicyRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"contentMD5" : @"ContentMD5",
             @"policy" : @"Policy",
             };
}

@end

@implementation OOSPutBucketReplicationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"contentMD5" : @"ContentMD5",
             @"replicationConfiguration" : @"ReplicationConfiguration",
             };
}

+ (NSValueTransformer *)replicationConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSReplicationConfiguration class]];
}

@end

@implementation OOSPutBucketRequestPaymentRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"contentMD5" : @"ContentMD5",
             @"requestPaymentConfiguration" : @"RequestPaymentConfiguration",
             };
}

+ (NSValueTransformer *)requestPaymentConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSRequestPaymentConfiguration class]];
}

@end

@implementation OOSPutBucketTaggingRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"contentMD5" : @"ContentMD5",
             @"tagging" : @"Tagging",
             };
}

+ (NSValueTransformer *)taggingJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSTagging class]];
}

@end

@implementation OOSPutBucketVersioningRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"contentMD5" : @"ContentMD5",
             @"MFA" : @"MFA",
             @"versioningConfiguration" : @"VersioningConfiguration",
             };
}

+ (NSValueTransformer *)versioningConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSVersioningConfiguration class]];
}

@end

@implementation OOSPutBucketWebsiteRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"contentMD5" : @"ContentMD5",
             @"websiteConfiguration" : @"WebsiteConfiguration",
             };
}

+ (NSValueTransformer *)websiteConfigurationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSWebsiteConfiguration class]];
}

@end

@implementation OOSPutObjectAclOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"requestCharged" : @"RequestCharged",
             };
}

+ (NSValueTransformer *)requestChargedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestChargedRequester);
        }
        return @(OOSRequestChargedUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestChargedRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSPutObjectAclRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"ACL" : @"ACL",
             @"accessControlPolicy" : @"AccessControlPolicy",
             @"bucket" : @"Bucket",
             @"contentMD5" : @"ContentMD5",
             @"grantFullControl" : @"GrantFullControl",
             @"grantRead" : @"GrantRead",
             @"grantReadACP" : @"GrantReadACP",
             @"grantWrite" : @"GrantWrite",
             @"grantWriteACP" : @"GrantWriteACP",
             @"key" : @"Key",
             @"requestPayer" : @"RequestPayer",
             @"versionId" : @"VersionId",
             };
}

+ (NSValueTransformer *)ACLJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"private"] == NSOrderedSame) {
            return @(OOSObjectCannedACLPrivate);
        }
        if ([value caseInsensitiveCompare:@"public-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLPublicRead);
        }
        if ([value caseInsensitiveCompare:@"public-read-write"] == NSOrderedSame) {
            return @(OOSObjectCannedACLPublicReadWrite);
        }
        if ([value caseInsensitiveCompare:@"authenticated-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLAuthenticatedRead);
        }
        if ([value caseInsensitiveCompare:@"OOS-exec-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLOOSExecRead);
        }
        if ([value caseInsensitiveCompare:@"bucket-owner-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLBucketOwnerRead);
        }
        if ([value caseInsensitiveCompare:@"bucket-owner-full-control"] == NSOrderedSame) {
            return @(OOSObjectCannedACLBucketOwnerFullControl);
        }
        return @(OOSObjectCannedACLUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSObjectCannedACLPrivate:
                return @"private";
            case OOSObjectCannedACLPublicRead:
                return @"public-read";
            case OOSObjectCannedACLPublicReadWrite:
                return @"public-read-write";
            case OOSObjectCannedACLAuthenticatedRead:
                return @"authenticated-read";
            case OOSObjectCannedACLOOSExecRead:
                return @"OOS-exec-read";
            case OOSObjectCannedACLBucketOwnerRead:
                return @"bucket-owner-read";
            case OOSObjectCannedACLBucketOwnerFullControl:
                return @"bucket-owner-full-control";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)accessControlPolicyJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSAccessControlPolicy class]];
}

+ (NSValueTransformer *)requestPayerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestPayerRequester);
        }
        return @(OOSRequestPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestPayerRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSPutObjectOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"ETag" : @"ETag",
             @"expiration" : @"Expiration",
             @"requestCharged" : @"RequestCharged",
             @"SSECustomerAlgorithm" : @"SSECustomerAlgorithm",
             @"SSECustomerKeyMD5" : @"SSECustomerKeyMD5",
             @"SSEKMSKeyId" : @"SSEKMSKeyId",
             @"serverSideEncryption" : @"ServerSideEncryption",
             @"versionId" : @"VersionId",
             };
}

+ (NSValueTransformer *)requestChargedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestChargedRequester);
        }
        return @(OOSRequestChargedUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestChargedRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)serverSideEncryptionJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"AES256"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionAES256);
        }
        if ([value caseInsensitiveCompare:@"OOS:kms"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionOOSKms);
        }
        return @(OOSServerSideEncryptionUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSServerSideEncryptionAES256:
                return @"AES256";
            case OOSServerSideEncryptionOOSKms:
                return @"OOS:kms";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSPutObjectRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"ACL" : @"ACL",
             @"body" : @"Body",
             @"bucket" : @"Bucket",
             @"cacheControl" : @"CacheControl",
             @"contentDisposition" : @"ContentDisposition",
             @"contentEncoding" : @"ContentEncoding",
             @"contentLanguage" : @"ContentLanguage",
             @"contentLength" : @"ContentLength",
             @"contentMD5" : @"ContentMD5",
             @"contentType" : @"ContentType",
             @"expires" : @"Expires",
             @"grantFullControl" : @"GrantFullControl",
             @"grantRead" : @"GrantRead",
             @"grantReadACP" : @"GrantReadACP",
             @"grantWriteACP" : @"GrantWriteACP",
             @"key" : @"Key",
             @"metadata" : @"Metadata",
             @"serverSideEncryption" : @"ServerSideEncryption",
             @"storageClass" : @"StorageClass",
			 @"dataLocation" : @"DataLocation",
             };
}

+ (NSValueTransformer *)ACLJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"private"] == NSOrderedSame) {
            return @(OOSObjectCannedACLPrivate);
        }
        if ([value caseInsensitiveCompare:@"public-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLPublicRead);
        }
        if ([value caseInsensitiveCompare:@"public-read-write"] == NSOrderedSame) {
            return @(OOSObjectCannedACLPublicReadWrite);
        }
        if ([value caseInsensitiveCompare:@"authenticated-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLAuthenticatedRead);
        }
        if ([value caseInsensitiveCompare:@"OOS-exec-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLOOSExecRead);
        }
        if ([value caseInsensitiveCompare:@"bucket-owner-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLBucketOwnerRead);
        }
        if ([value caseInsensitiveCompare:@"bucket-owner-full-control"] == NSOrderedSame) {
            return @(OOSObjectCannedACLBucketOwnerFullControl);
        }
        return @(OOSObjectCannedACLUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSObjectCannedACLPrivate:
                return @"private";
            case OOSObjectCannedACLPublicRead:
                return @"public-read";
            case OOSObjectCannedACLPublicReadWrite:
                return @"public-read-write";
            case OOSObjectCannedACLAuthenticatedRead:
                return @"authenticated-read";
            case OOSObjectCannedACLOOSExecRead:
                return @"OOS-exec-read";
            case OOSObjectCannedACLBucketOwnerRead:
                return @"bucket-owner-read";
            case OOSObjectCannedACLBucketOwnerFullControl:
                return @"bucket-owner-full-control";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)expiresJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)serverSideEncryptionJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"AES256"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionAES256);
        }
        if ([value caseInsensitiveCompare:@"OOS:kms"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionOOSKms);
        }
        return @(OOSServerSideEncryptionUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSServerSideEncryptionAES256:
                return @"AES256";
            case OOSServerSideEncryptionOOSKms:
                return @"OOS:kms";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)storageClassJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"STANDARD"] == NSOrderedSame) {
            return @(OOSStorageClassStandard);
        }
        if ([value caseInsensitiveCompare:@"REDUCED_REDUNDANCY"] == NSOrderedSame) {
            return @(OOSStorageClassReducedRedundancy);
        }
        return @(OOSStorageClassUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSStorageClassStandard:
                return @"STANDARD";
            case OOSStorageClassReducedRedundancy:
                return @"REDUCED_REDUNDANCY";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSPutObjectTaggingOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"versionId" : @"VersionId",
             };
}

@end

@implementation OOSPutObjectTaggingRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"contentMD5" : @"ContentMD5",
             @"key" : @"Key",
             @"tagging" : @"Tagging",
             @"versionId" : @"VersionId",
             };
}

+ (NSValueTransformer *)taggingJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSTagging class]];
}

@end

@implementation OOSQueueConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"events" : @"Events",
             @"filter" : @"Filter",
             @"identifier" : @"Id",
             @"queueArn" : @"QueueArn",
             };
}

+ (NSValueTransformer *)filterJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSNotificationConfigurationFilter class]];
}

@end

@implementation OOSQueueConfigurationDeprecated

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"event" : @"Event",
             @"events" : @"Events",
             @"identifier" : @"Id",
             @"queue" : @"Queue",
             };
}

+ (NSValueTransformer *)eventJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@":ReducedRedundancyLostObject"] == NSOrderedSame) {
            return @(OOSEventReducedRedundancyLostObject);
        }
        if ([value caseInsensitiveCompare:@":ObjectCreated:*"] == NSOrderedSame) {
            return @(OOSEventObjectCreated);
        }
        if ([value caseInsensitiveCompare:@":ObjectCreated:Put"] == NSOrderedSame) {
            return @(OOSEventObjectCreatedPut);
        }
        if ([value caseInsensitiveCompare:@":ObjectCreated:Post"] == NSOrderedSame) {
            return @(OOSEventObjectCreatedPost);
        }
        if ([value caseInsensitiveCompare:@":ObjectCreated:Copy"] == NSOrderedSame) {
            return @(OOSEventObjectCreatedCopy);
        }
        if ([value caseInsensitiveCompare:@":ObjectCreated:CompleteMultipartUpload"] == NSOrderedSame) {
            return @(OOSEventObjectCreatedCompleteMultipartUpload);
        }
        if ([value caseInsensitiveCompare:@":ObjectRemoved:*"] == NSOrderedSame) {
            return @(OOSEventObjectRemoved);
        }
        if ([value caseInsensitiveCompare:@":ObjectRemoved:Delete"] == NSOrderedSame) {
            return @(OOSEventObjectRemovedDelete);
        }
        if ([value caseInsensitiveCompare:@":ObjectRemoved:DeleteMarkerCreated"] == NSOrderedSame) {
            return @(OOSEventObjectRemovedDeleteMarkerCreated);
        }
        return @(OOSEventUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSEventReducedRedundancyLostObject:
                return @":ReducedRedundancyLostObject";
            case OOSEventObjectCreated:
                return @":ObjectCreated:*";
            case OOSEventObjectCreatedPut:
                return @":ObjectCreated:Put";
            case OOSEventObjectCreatedPost:
                return @":ObjectCreated:Post";
            case OOSEventObjectCreatedCopy:
                return @":ObjectCreated:Copy";
            case OOSEventObjectCreatedCompleteMultipartUpload:
                return @":ObjectCreated:CompleteMultipartUpload";
            case OOSEventObjectRemoved:
                return @":ObjectRemoved:*";
            case OOSEventObjectRemovedDelete:
                return @":ObjectRemoved:Delete";
            case OOSEventObjectRemovedDeleteMarkerCreated:
                return @":ObjectRemoved:DeleteMarkerCreated";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSRecordsEvent

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"payload" : @"Payload",
             };
}

@end

@implementation OOSRedirect

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"hostName" : @"HostName",
             @"httpRedirectCode" : @"HttpRedirectCode",
             @"protocols" : @"Protocol",
             @"replaceKeyPrefixWith" : @"ReplaceKeyPrefixWith",
             @"replaceKeyWith" : @"ReplaceKeyWith",
             };
}

+ (NSValueTransformer *)protocolsJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"http"] == NSOrderedSame) {
            return @(OOSProtocolsHTTP);
        }
        if ([value caseInsensitiveCompare:@"https"] == NSOrderedSame) {
            return @(OOSProtocolsHTTPS);
        }
        return @(OOSProtocolsUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSProtocolsHTTP:
                return @"http";
            case OOSProtocolsHTTPS:
                return @"https";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSRedirectAllRequestsTo

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"hostName" : @"HostName",
             @"protocols" : @"Protocol",
             };
}

+ (NSValueTransformer *)protocolsJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"http"] == NSOrderedSame) {
            return @(OOSProtocolsHTTP);
        }
        if ([value caseInsensitiveCompare:@"https"] == NSOrderedSame) {
            return @(OOSProtocolsHTTPS);
        }
        return @(OOSProtocolsUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSProtocolsHTTP:
                return @"http";
            case OOSProtocolsHTTPS:
                return @"https";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSReplicationConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"role" : @"Role",
             @"rules" : @"Rules",
             };
}

+ (NSValueTransformer *)rulesJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSReplicationRule class]];
}

@end

@implementation OOSReplicationRule

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"destination" : @"Destination",
             @"identifier" : @"ID",
             @"prefix" : @"Prefix",
             @"sourceSelectionCriteria" : @"SourceSelectionCriteria",
             @"status" : @"Status",
             };
}

+ (NSValueTransformer *)destinationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSDestination class]];
}

+ (NSValueTransformer *)sourceSelectionCriteriaJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSSourceSelectionCriteria class]];
}

+ (NSValueTransformer *)statusJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"Enabled"] == NSOrderedSame) {
            return @(OOSReplicationRuleStatusEnabled);
        }
        if ([value caseInsensitiveCompare:@"Disabled"] == NSOrderedSame) {
            return @(OOSReplicationRuleStatusDisabled);
        }
        return @(OOSReplicationRuleStatusUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSReplicationRuleStatusEnabled:
                return @"Enabled";
            case OOSReplicationRuleStatusDisabled:
                return @"Disabled";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSRequestPaymentConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"payer" : @"Payer",
             };
}

+ (NSValueTransformer *)payerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"Requester"] == NSOrderedSame) {
            return @(OOSPayerRequester);
        }
        if ([value caseInsensitiveCompare:@"BucketOwner"] == NSOrderedSame) {
            return @(OOSPayerBucketOwner);
        }
        return @(OOSPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSPayerRequester:
                return @"Requester";
            case OOSPayerBucketOwner:
                return @"BucketOwner";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSRequestProgress

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"enabled" : @"Enabled",
             };
}

@end

@implementation OOSRestoreObjectOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"requestCharged" : @"RequestCharged",
             @"restoreOutputPath" : @"RestoreOutputPath",
             };
}

+ (NSValueTransformer *)requestChargedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestChargedRequester);
        }
        return @(OOSRequestChargedUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestChargedRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSRestoreObjectRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"key" : @"Key",
             @"requestPayer" : @"RequestPayer",
             @"restoreRequest" : @"RestoreRequest",
             @"versionId" : @"VersionId",
             };
}

+ (NSValueTransformer *)requestPayerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestPayerRequester);
        }
        return @(OOSRequestPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestPayerRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)restoreRequestJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSRestoreRequest class]];
}

@end

@implementation OOSRestoreRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"days" : @"Days",
             @"detail" : @"Description",
             @"glacierJobParameters" : @"GlacierJobParameters",
             @"selectParameters" : @"SelectParameters",
             @"tier" : @"Tier",
             @"types" : @"Type",
             };
}

+ (NSValueTransformer *)glacierJobParametersJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSGlacierJobParameters class]];
}

+ (NSValueTransformer *)selectParametersJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSSelectParameters class]];
}

+ (NSValueTransformer *)tierJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"Standard"] == NSOrderedSame) {
            return @(OOSTierStandard);
        }
        if ([value caseInsensitiveCompare:@"Bulk"] == NSOrderedSame) {
            return @(OOSTierBulk);
        }
        if ([value caseInsensitiveCompare:@"Expedited"] == NSOrderedSame) {
            return @(OOSTierExpedited);
        }
        return @(OOSTierUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSTierStandard:
                return @"Standard";
            case OOSTierBulk:
                return @"Bulk";
            case OOSTierExpedited:
                return @"Expedited";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)typesJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"SELECT"] == NSOrderedSame) {
            return @(OOSRestoreRequestTypeSelect);
        }
        return @(OOSRestoreRequestTypeUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRestoreRequestTypeSelect:
                return @"SELECT";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSRoutingRule

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"condition" : @"Condition",
             @"redirect" : @"Redirect",
             };
}

+ (NSValueTransformer *)conditionJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSCondition class]];
}

+ (NSValueTransformer *)redirectJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSRedirect class]];
}

@end

@implementation OOSRule

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"abortIncompleteMultipartUpload" : @"AbortIncompleteMultipartUpload",
             @"expiration" : @"Expiration",
             @"identifier" : @"ID",
             @"noncurrentVersionExpiration" : @"NoncurrentVersionExpiration",
             @"noncurrentVersionTransition" : @"NoncurrentVersionTransition",
             @"prefix" : @"Prefix",
             @"status" : @"Status",
             @"transition" : @"Transition",
             };
}

+ (NSValueTransformer *)abortIncompleteMultipartUploadJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSAbortIncompleteMultipartUpload class]];
}

+ (NSValueTransformer *)expirationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSLifecycleExpiration class]];
}

+ (NSValueTransformer *)noncurrentVersionExpirationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSNoncurrentVersionExpiration class]];
}

+ (NSValueTransformer *)noncurrentVersionTransitionJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSNoncurrentVersionTransition class]];
}

+ (NSValueTransformer *)statusJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"Enabled"] == NSOrderedSame) {
            return @(OOSExpirationStatusEnabled);
        }
        if ([value caseInsensitiveCompare:@"Disabled"] == NSOrderedSame) {
            return @(OOSExpirationStatusDisabled);
        }
        return @(OOSExpirationStatusUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSExpirationStatusEnabled:
                return @"Enabled";
            case OOSExpirationStatusDisabled:
                return @"Disabled";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)transitionJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSTransition class]];
}

@end

@implementation OOSKeyFilter

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"filterRules" : @"FilterRules",
             };
}

+ (NSValueTransformer *)filterRulesJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSFilterRule class]];
}

@end

@implementation OOSLocation

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"accessControlList" : @"AccessControlList",
             @"bucketName" : @"BucketName",
             @"cannedACL" : @"CannedACL",
             @"encryption" : @"Encryption",
             @"prefix" : @"Prefix",
             @"storageClass" : @"StorageClass",
             @"tagging" : @"Tagging",
             @"userMetadata" : @"UserMetadata",
             };
}

+ (NSValueTransformer *)accessControlListJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSGrant class]];
}

+ (NSValueTransformer *)cannedACLJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"private"] == NSOrderedSame) {
            return @(OOSObjectCannedACLPrivate);
        }
        if ([value caseInsensitiveCompare:@"public-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLPublicRead);
        }
        if ([value caseInsensitiveCompare:@"public-read-write"] == NSOrderedSame) {
            return @(OOSObjectCannedACLPublicReadWrite);
        }
        if ([value caseInsensitiveCompare:@"authenticated-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLAuthenticatedRead);
        }
        if ([value caseInsensitiveCompare:@"OOS-exec-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLOOSExecRead);
        }
        if ([value caseInsensitiveCompare:@"bucket-owner-read"] == NSOrderedSame) {
            return @(OOSObjectCannedACLBucketOwnerRead);
        }
        if ([value caseInsensitiveCompare:@"bucket-owner-full-control"] == NSOrderedSame) {
            return @(OOSObjectCannedACLBucketOwnerFullControl);
        }
        return @(OOSObjectCannedACLUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSObjectCannedACLPrivate:
                return @"private";
            case OOSObjectCannedACLPublicRead:
                return @"public-read";
            case OOSObjectCannedACLPublicReadWrite:
                return @"public-read-write";
            case OOSObjectCannedACLAuthenticatedRead:
                return @"authenticated-read";
            case OOSObjectCannedACLOOSExecRead:
                return @"OOS-exec-read";
            case OOSObjectCannedACLBucketOwnerRead:
                return @"bucket-owner-read";
            case OOSObjectCannedACLBucketOwnerFullControl:
                return @"bucket-owner-full-control";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)encryptionJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSEncryption class]];
}

+ (NSValueTransformer *)storageClassJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"STANDARD"] == NSOrderedSame) {
            return @(OOSStorageClassStandard);
        }
        if ([value caseInsensitiveCompare:@"REDUCED_REDUNDANCY"] == NSOrderedSame) {
            return @(OOSStorageClassReducedRedundancy);
        }
        return @(OOSStorageClassUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSStorageClassStandard:
                return @"STANDARD";
            case OOSStorageClassReducedRedundancy:
                return @"REDUCED_REDUNDANCY";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)taggingJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSTagging class]];
}

+ (NSValueTransformer *)userMetadataJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSMetadataEntry class]];
}

@end

@implementation OOSSSEKMS

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"keyId" : @"KeyId",
             };
}

@end

@implementation OOSSSE

@end

@implementation OOSSelectObjectContentEventStream

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"cont" : @"Cont",
             @"end" : @"End",
             @"progress" : @"Progress",
             @"records" : @"Records",
             @"stats" : @"Stats",
             };
}

+ (NSValueTransformer *)contJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSContinuationEvent class]];
}

+ (NSValueTransformer *)endJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSEndEvent class]];
}

+ (NSValueTransformer *)progressJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSProgressEvent class]];
}

+ (NSValueTransformer *)recordsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSRecordsEvent class]];
}

+ (NSValueTransformer *)statsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSStatsEvent class]];
}

@end

@implementation OOSSelectObjectContentOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"payload" : @"Payload",
             };
}

+ (NSValueTransformer *)payloadJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSSelectObjectContentEventStream class]];
}

@end

@implementation OOSSelectObjectContentRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"expression" : @"Expression",
             @"expressionType" : @"ExpressionType",
             @"inputSerialization" : @"InputSerialization",
             @"key" : @"Key",
             @"outputSerialization" : @"OutputSerialization",
             @"requestProgress" : @"RequestProgress",
             @"SSECustomerAlgorithm" : @"SSECustomerAlgorithm",
             @"SSECustomerKey" : @"SSECustomerKey",
             @"SSECustomerKeyMD5" : @"SSECustomerKeyMD5",
             };
}

+ (NSValueTransformer *)expressionTypeJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"SQL"] == NSOrderedSame) {
            return @(OOSExpressionTypeSql);
        }
        return @(OOSExpressionTypeUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSExpressionTypeSql:
                return @"SQL";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)inputSerializationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSInputSerialization class]];
}

+ (NSValueTransformer *)outputSerializationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSOutputSerialization class]];
}

+ (NSValueTransformer *)requestProgressJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSRequestProgress class]];
}

@end

@implementation OOSSelectParameters

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"expression" : @"Expression",
             @"expressionType" : @"ExpressionType",
             @"inputSerialization" : @"InputSerialization",
             @"outputSerialization" : @"OutputSerialization",
             };
}

+ (NSValueTransformer *)expressionTypeJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"SQL"] == NSOrderedSame) {
            return @(OOSExpressionTypeSql);
        }
        return @(OOSExpressionTypeUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSExpressionTypeSql:
                return @"SQL";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)inputSerializationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSInputSerialization class]];
}

+ (NSValueTransformer *)outputSerializationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSOutputSerialization class]];
}

@end

@implementation OOSServerSideEncryptionByDefault

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"KMSMasterKeyID" : @"KMSMasterKeyID",
             @"SSEAlgorithm" : @"SSEAlgorithm",
             };
}

+ (NSValueTransformer *)SSEAlgorithmJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"AES256"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionAES256);
        }
        if ([value caseInsensitiveCompare:@"OOS:kms"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionOOSKms);
        }
        return @(OOSServerSideEncryptionUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSServerSideEncryptionAES256:
                return @"AES256";
            case OOSServerSideEncryptionOOSKms:
                return @"OOS:kms";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSServerSideEncryptionConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"rules" : @"Rules",
             };
}

+ (NSValueTransformer *)rulesJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSServerSideEncryptionRule class]];
}

@end

@implementation OOSServerSideEncryptionRule

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"applyServerSideEncryptionByDefault" : @"ApplyServerSideEncryptionByDefault",
             };
}

+ (NSValueTransformer *)applyServerSideEncryptionByDefaultJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSServerSideEncryptionByDefault class]];
}

@end

@implementation OOSSourceSelectionCriteria

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"sseKmsEncryptedObjects" : @"SseKmsEncryptedObjects",
             };
}

+ (NSValueTransformer *)sseKmsEncryptedObjectsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSSseKmsEncryptedObjects class]];
}

@end

@implementation OOSSseKmsEncryptedObjects

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"status" : @"Status",
             };
}

+ (NSValueTransformer *)statusJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"Enabled"] == NSOrderedSame) {
            return @(OOSSseKmsEncryptedObjectsStatusEnabled);
        }
        if ([value caseInsensitiveCompare:@"Disabled"] == NSOrderedSame) {
            return @(OOSSseKmsEncryptedObjectsStatusDisabled);
        }
        return @(OOSSseKmsEncryptedObjectsStatusUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSSseKmsEncryptedObjectsStatusEnabled:
                return @"Enabled";
            case OOSSseKmsEncryptedObjectsStatusDisabled:
                return @"Disabled";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSStats

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bytesProcessed" : @"BytesProcessed",
             @"bytesScanned" : @"BytesScanned",
             };
}

@end

@implementation OOSStatsEvent

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"details" : @"Details",
             };
}

+ (NSValueTransformer *)detailsJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSStats class]];
}

@end

@implementation OOSStorageClassAnalysis

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"dataExport" : @"DataExport",
             };
}

+ (NSValueTransformer *)dataExportJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSStorageClassAnalysisDataExport class]];
}

@end

@implementation OOSStorageClassAnalysisDataExport

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"destination" : @"Destination",
             @"outputSchemaVersion" : @"OutputSchemaVersion",
             };
}

+ (NSValueTransformer *)destinationJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSAnalyticsExportDestination class]];
}

+ (NSValueTransformer *)outputSchemaVersionJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"V_1"] == NSOrderedSame) {
            return @(OOSStorageClassAnalysisSchemaVersionV1);
        }
        return @(OOSStorageClassAnalysisSchemaVersionUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSStorageClassAnalysisSchemaVersionV1:
                return @"V_1";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSTag

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"key" : @"Key",
             @"value" : @"Value",
             };
}

@end

@implementation OOSTagging

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"tagSet" : @"TagSet",
             };
}

+ (NSValueTransformer *)tagSetJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSTag class]];
}

@end

@implementation OOSTargetGrant

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"grantee" : @"Grantee",
             @"permission" : @"Permission",
             };
}

+ (NSValueTransformer *)granteeJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSGrantee class]];
}

+ (NSValueTransformer *)permissionJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"FULL_CONTROL"] == NSOrderedSame) {
            return @(OOSBucketLogsPermissionFullControl);
        }
        if ([value caseInsensitiveCompare:@"READ"] == NSOrderedSame) {
            return @(OOSBucketLogsPermissionRead);
        }
        if ([value caseInsensitiveCompare:@"WRITE"] == NSOrderedSame) {
            return @(OOSBucketLogsPermissionWrite);
        }
        return @(OOSBucketLogsPermissionUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSBucketLogsPermissionFullControl:
                return @"FULL_CONTROL";
            case OOSBucketLogsPermissionRead:
                return @"READ";
            case OOSBucketLogsPermissionWrite:
                return @"WRITE";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSTopicConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"events" : @"Events",
             @"filter" : @"Filter",
             @"identifier" : @"Id",
             @"topicArn" : @"TopicArn",
             };
}

+ (NSValueTransformer *)filterJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSNotificationConfigurationFilter class]];
}

@end

@implementation OOSTopicConfigurationDeprecated

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"event" : @"Event",
             @"events" : @"Events",
             @"identifier" : @"Id",
             @"topic" : @"Topic",
             };
}

+ (NSValueTransformer *)eventJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@":ReducedRedundancyLostObject"] == NSOrderedSame) {
            return @(OOSEventReducedRedundancyLostObject);
        }
        if ([value caseInsensitiveCompare:@":ObjectCreated:*"] == NSOrderedSame) {
            return @(OOSEventObjectCreated);
        }
        if ([value caseInsensitiveCompare:@":ObjectCreated:Put"] == NSOrderedSame) {
            return @(OOSEventObjectCreatedPut);
        }
        if ([value caseInsensitiveCompare:@":ObjectCreated:Post"] == NSOrderedSame) {
            return @(OOSEventObjectCreatedPost);
        }
        if ([value caseInsensitiveCompare:@":ObjectCreated:Copy"] == NSOrderedSame) {
            return @(OOSEventObjectCreatedCopy);
        }
        if ([value caseInsensitiveCompare:@":ObjectCreated:CompleteMultipartUpload"] == NSOrderedSame) {
            return @(OOSEventObjectCreatedCompleteMultipartUpload);
        }
        if ([value caseInsensitiveCompare:@":ObjectRemoved:*"] == NSOrderedSame) {
            return @(OOSEventObjectRemoved);
        }
        if ([value caseInsensitiveCompare:@":ObjectRemoved:Delete"] == NSOrderedSame) {
            return @(OOSEventObjectRemovedDelete);
        }
        if ([value caseInsensitiveCompare:@":ObjectRemoved:DeleteMarkerCreated"] == NSOrderedSame) {
            return @(OOSEventObjectRemovedDeleteMarkerCreated);
        }
        return @(OOSEventUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSEventReducedRedundancyLostObject:
                return @":ReducedRedundancyLostObject";
            case OOSEventObjectCreated:
                return @":ObjectCreated:*";
            case OOSEventObjectCreatedPut:
                return @":ObjectCreated:Put";
            case OOSEventObjectCreatedPost:
                return @":ObjectCreated:Post";
            case OOSEventObjectCreatedCopy:
                return @":ObjectCreated:Copy";
            case OOSEventObjectCreatedCompleteMultipartUpload:
                return @":ObjectCreated:CompleteMultipartUpload";
            case OOSEventObjectRemoved:
                return @":ObjectRemoved:*";
            case OOSEventObjectRemovedDelete:
                return @":ObjectRemoved:Delete";
            case OOSEventObjectRemovedDeleteMarkerCreated:
                return @":ObjectRemoved:DeleteMarkerCreated";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSTransition

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"date" : @"Date",
             @"days" : @"Days",
             @"storageClass" : @"StorageClass",
             };
}

+ (NSValueTransformer *)dateJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)storageClassJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"GLACIER"] == NSOrderedSame) {
            return @(OOSTransitionStorageClassGlacier);
        }
        if ([value caseInsensitiveCompare:@"STANDARD_IA"] == NSOrderedSame) {
            return @(OOSTransitionStorageClassStandardIa);
        }
        if ([value caseInsensitiveCompare:@"ONEZONE_IA"] == NSOrderedSame) {
            return @(OOSTransitionStorageClassOnezoneIa);
        }
        return @(OOSTransitionStorageClassUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSTransitionStorageClassGlacier:
                return @"GLACIER";
            case OOSTransitionStorageClassStandardIa:
                return @"STANDARD_IA";
            case OOSTransitionStorageClassOnezoneIa:
                return @"ONEZONE_IA";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSUploadPartCopyOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"replicatePartResult" : @"CopyPartResult",
             @"replicateSourceVersionId" : @"CopySourceVersionId",
             @"requestCharged" : @"RequestCharged",
             @"SSECustomerAlgorithm" : @"SSECustomerAlgorithm",
             @"SSECustomerKeyMD5" : @"SSECustomerKeyMD5",
             @"SSEKMSKeyId" : @"SSEKMSKeyId",
             @"serverSideEncryption" : @"ServerSideEncryption",
             };
}

+ (NSValueTransformer *)replicatePartResultJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSReplicatePartResult class]];
}

+ (NSValueTransformer *)requestChargedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestChargedRequester);
        }
        return @(OOSRequestChargedUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestChargedRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)serverSideEncryptionJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"AES256"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionAES256);
        }
        if ([value caseInsensitiveCompare:@"OOS:kms"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionOOSKms);
        }
        return @(OOSServerSideEncryptionUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSServerSideEncryptionAES256:
                return @"AES256";
            case OOSServerSideEncryptionOOSKms:
                return @"OOS:kms";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSUploadPartCopyRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bucket" : @"Bucket",
             @"replicateSource" : @"CopySource",
             @"replicateSourceIfMatch" : @"CopySourceIfMatch",
             @"replicateSourceIfModifiedSince" : @"CopySourceIfModifiedSince",
             @"replicateSourceIfNoneMatch" : @"CopySourceIfNoneMatch",
             @"replicateSourceIfUnmodifiedSince" : @"CopySourceIfUnmodifiedSince",
             @"replicateSourceRange" : @"CopySourceRange",
             @"replicateSourceSSECustomerAlgorithm" : @"CopySourceSSECustomerAlgorithm",
             @"replicateSourceSSECustomerKey" : @"CopySourceSSECustomerKey",
             @"replicateSourceSSECustomerKeyMD5" : @"CopySourceSSECustomerKeyMD5",
             @"key" : @"Key",
             @"partNumber" : @"PartNumber",
             @"requestPayer" : @"RequestPayer",
             @"SSECustomerAlgorithm" : @"SSECustomerAlgorithm",
             @"SSECustomerKey" : @"SSECustomerKey",
             @"SSECustomerKeyMD5" : @"SSECustomerKeyMD5",
             @"uploadId" : @"UploadId",
             };
}

+ (NSValueTransformer *)replicateSourceIfModifiedSinceJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)replicateSourceIfUnmodifiedSinceJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return [NSDate OOS_dateFromString:str];
    } reverseBlock:^id(NSDate *date) {
return [date OOS_stringValue:OOSDateRFC822DateFormat1];
    }];
}

+ (NSValueTransformer *)requestPayerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestPayerRequester);
        }
        return @(OOSRequestPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestPayerRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSUploadPartOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"ETag" : @"ETag",
             @"requestCharged" : @"RequestCharged",
             @"SSECustomerAlgorithm" : @"SSECustomerAlgorithm",
             @"SSECustomerKeyMD5" : @"SSECustomerKeyMD5",
             @"SSEKMSKeyId" : @"SSEKMSKeyId",
             @"serverSideEncryption" : @"ServerSideEncryption",
             };
}

+ (NSValueTransformer *)requestChargedJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestChargedRequester);
        }
        return @(OOSRequestChargedUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestChargedRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)serverSideEncryptionJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"AES256"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionAES256);
        }
        if ([value caseInsensitiveCompare:@"OOS:kms"] == NSOrderedSame) {
            return @(OOSServerSideEncryptionOOSKms);
        }
        return @(OOSServerSideEncryptionUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSServerSideEncryptionAES256:
                return @"AES256";
            case OOSServerSideEncryptionOOSKms:
                return @"OOS:kms";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSUploadPartRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"body" : @"Body",
             @"bucket" : @"Bucket",
             @"contentLength" : @"ContentLength",
             @"contentMD5" : @"ContentMD5",
             @"key" : @"Key",
             @"partNumber" : @"PartNumber",
             @"requestPayer" : @"RequestPayer",
             @"SSECustomerAlgorithm" : @"SSECustomerAlgorithm",
             @"SSECustomerKey" : @"SSECustomerKey",
             @"SSECustomerKeyMD5" : @"SSECustomerKeyMD5",
             @"uploadId" : @"UploadId",
             };
}

+ (NSValueTransformer *)requestPayerJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"requester"] == NSOrderedSame) {
            return @(OOSRequestPayerRequester);
        }
        return @(OOSRequestPayerUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSRequestPayerRequester:
                return @"requester";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSVersioningConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"MFADelete" : @"MFADelete",
             @"status" : @"Status",
             };
}

+ (NSValueTransformer *)MFADeleteJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"Enabled"] == NSOrderedSame) {
            return @(OOSMFADeleteEnabled);
        }
        if ([value caseInsensitiveCompare:@"Disabled"] == NSOrderedSame) {
            return @(OOSMFADeleteDisabled);
        }
        return @(OOSMFADeleteUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSMFADeleteEnabled:
                return @"Enabled";
            case OOSMFADeleteDisabled:
                return @"Disabled";
            default:
                return nil;
        }
    }];
}

+ (NSValueTransformer *)statusJSONTransformer {
    return [OOSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value caseInsensitiveCompare:@"Enabled"] == NSOrderedSame) {
            return @(OOSBucketVersioningStatusEnabled);
        }
        if ([value caseInsensitiveCompare:@"Suspended"] == NSOrderedSame) {
            return @(OOSBucketVersioningStatusSuspended);
        }
        return @(OOSBucketVersioningStatusUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case OOSBucketVersioningStatusEnabled:
                return @"Enabled";
            case OOSBucketVersioningStatusSuspended:
                return @"Suspended";
            default:
                return nil;
        }
    }];
}

@end

@implementation OOSWebsiteConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"errorDocument" : @"ErrorDocument",
             @"indexDocument" : @"IndexDocument",
             };
}

+ (NSValueTransformer *)errorDocumentJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSErrorDocument class]];
}

+ (NSValueTransformer *)indexDocumentJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSIndexDocument class]];
}

+ (NSValueTransformer *)redirectAllRequestsToJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSRedirectAllRequestsTo class]];
}

+ (NSValueTransformer *)routingRulesJSONTransformer {
    return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSRoutingRule class]];
}

@end

@implementation OOSRemoteSite

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"remoteEndPoint" : @"RemontEndPoint",
			 @"replicaMode" : @"ReplicaMode",
			 @"remoteBucketName" : @"RemoteBucketName",
			 @"remoteAK" : @"RemoteAK",
			 @"remoteSK" : @"RemoteSK"
			 };
}

@end

@implementation OOSTrigger

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"triggerName" : @"TriggerName",
			 @"isDefault" : @"IsDefault",
			 @"remoteSite" : @"RemoteSite"
			 };
}

+ (NSValueTransformer *)remoteSiteJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSRemoteSite class]];
}

@end

@implementation OOSTriggerConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"triggers" : @"Triggers"
			 };
}

+ (NSValueTransformer *)triggersJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSTrigger class]];
}

@end

@implementation OOSPutBucketTriggerRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"triggerConfiguration" : @"TriggerConfiguration",
			 @"bucket": @"Bucket"
			 };
}

+ (NSValueTransformer *)triggerConfigurationJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSTriggerConfiguration class]];
}

@end

@implementation OOSGetBucketTriggerRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"bucket" : @"Bucket",
			 };
}

@end

@implementation OOSDeleteBucketTriggerRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"bucket" : @"Bucket",
			 @"triggerName": @"TriggerName"
			 };
}

@end

@implementation OOSGetBucketTriggerOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"triggerConfiguration" : @"TriggerConfiguration"
			 };
}

+ (NSValueTransformer *)triggerConfigurationJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSTriggerConfiguration class]];
}

@end

@implementation OOSCreateAccessKeyRequest

- (instancetype) init {
	self = [super init];
	if (self) {
		_action = @"CreateAccessKey";
	}
	
	return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"action": @"Action"
			 };
}

@end

@implementation OOSAccessKey

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"userName": @"UserName",
			 @"accessKeyId": @"AccessKeyId",
			 @"status": @"Status",
			 @"isPrimary": @"IsPrimary",
			 @"secretAccessKey": @"SecretAccessKey"
			 };
}

@end

@implementation OOSCreateAccessKeyResult

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"accessKey": @"AccessKey"
			 };
}

+ (NSValueTransformer *)accessKeyJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSAccessKey class]];
}

@end

@implementation OOSResponseMetadata

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"requestId": @"RequestId"
			 };
}

@end

@implementation OOSCreateAccessKeyResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"createAccessKeyResult": @"CreateAccessKeyResult",
			 @"responseMetadata": @"ResponseMetadata"
			 };
}

+ (NSValueTransformer *)createAccessKeyResultJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSCreateAccessKeyResult class]];
}

+ (NSValueTransformer *)responseMetadataJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSResponseMetadata class]];
}

@end

@implementation OOSCreateAccessKeyOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"createAccessKeyResponse": @"CreateAccessKeyResponse"
			 };
}

+ (NSValueTransformer *)createAccessKeyResponseJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSCreateAccessKeyResponse class]];
}

@end

@implementation OOSDeleteAccessKeyRequest

- (instancetype) init {
	self = [super init];
	if (self) {
		_action = @"DeleteAccessKey";
	}
	
	return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"action" : @"Action",
			 @"accessKeyId" : @"AccessKeyId"
			 };
}

@end

@implementation OOSDeleteAccessKeyResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"responseMetadata": @"ResponseMetadata"
			 };
}

+ (NSValueTransformer *)responseMetadataJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSResponseMetadata class]];
}

@end

@implementation OOSDeleteAccessKeyOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"deleteAccessKeyResponse": @"DeleteAccessKeyResponse"
			 };
}

+ (NSValueTransformer *)deleteAccessKeyResponseJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSDeleteAccessKeyResponse class]];
}

@end

@implementation OOSUpdateAccessKeyRequest

- (instancetype) init {
	self = [super init];
	if (self) {
		_action = @"UpdateAccessKey";
	}
	
	return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"action" : @"Action",
			 @"accessKeyId" : @"AccessKeyId",
			 @"status" : @"Status",
			 @"isPrimary" : @"IsPrimary"
			 };
}

@end

@implementation OOSUpdateAccessKeyResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"responseMetadata": @"ResponseMetadata"
			 };
}

+ (NSValueTransformer *)responseMetadataJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSResponseMetadata class]];
}

@end

@implementation OOSUpdateAccessKeyOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"updateAccessKeyResponse": @"UpdateAccessKeyResponse"
			 };
}

+ (NSValueTransformer *)updateAccessKeyResponseJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSUpdateAccessKeyResponse class]];
}

@end

@implementation OOSListAccessKeyRequest

- (instancetype) init {
	self = [super init];
	if (self) {
		_action = @"ListAccessKey";
	}
	
	return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"action" : @"Action",
			 @"maxItems" : @"MaxItems",
			 @"marker" : @"Marker",
			 };
}

@end

@implementation OOSAccessKeyMember

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"userName": @"UserName",
			 @"accessKeyId": @"AccessKeyId",
			 @"status": @"Status",
			 @"isPrimary": @"IsPrimary"
			 };
}

@end

@implementation OOSAccessKeyMetadata : CoreModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"members": @"Members",
			 };
}

+ (NSValueTransformer *)membersJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONArrayTransformerWithModelClass:[OOSAccessKeyMember class]];
}

@end

@implementation OOSListAccessKeysResult : CoreModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"userName": @"UserName",
			 @"isTruncated": @"IsTruncated",
			 @"marker": @"Marker",
			 @"accessKeyMetadata": @"AccessKeyMetadata",
			 };
}

+ (NSValueTransformer *)accessKeyMetadataJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSAccessKeyMetadata class]];
}

@end

@implementation OOSListAccessKeysResponse : CoreModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"listAccessKeysResult": @"ListAccessKeysResult",
			 @"responseMetadata": @"ResponseMetadata"
			 };
}

+ (NSValueTransformer *)listAccessKeysResultJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSListAccessKeysResult class]];
}

+ (NSValueTransformer *)responseMetadataJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSResponseMetadata class]];
}

@end


@implementation OOSListAccessKeyOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"listAccessKeysResponse": @"ListAccessKeysResponse"
			 };
}

+ (NSValueTransformer *)listAccessKeysResponseJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSListAccessKeysResponse class]];
}

@end

@implementation OOSGetRegionsRequest

@end

@implementation OOSMetadataRegions

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"regions": @"Regions"
			 };
}

@end

@implementation OOSDataRegions

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"regions": @"Regions"
			 };
}

@end

@implementation OOSBucketRegions

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"metadataRegions": @"MetadataRegions",
			 @"dataRegions": @"DataRegions",
			 };
}

+ (NSValueTransformer *)metadataRegionsJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSMetadataRegions class]];
}

+ (NSValueTransformer *)dataRegionsJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSDataRegions class]];
}

@end

@implementation OOSGetRegionsOutput

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			 @"bucketRegions": @"BucketRegions",
			 };
}

+ (NSValueTransformer *)bucketRegionsJSONTransformer {
	return [NSValueTransformer OOSmtl_JSONDictionaryTransformerWithModelClass:[OOSBucketRegions class]];
}

@end

