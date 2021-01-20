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
#import "OOSNetworking.h"
#import "CoreModel.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const OOSErrorDomain;

typedef NS_ENUM(NSInteger, OOSErrorType) {
    OOSErrorUnknown,
    OOSErrorBucketAlreadyExists,
    OOSErrorBucketAlreadyOwnedByYou,
    OOSErrorNoSuchBucket,
    OOSErrorNoSuchKey,
    OOSErrorNoSuchUpload,
    OOSErrorObjectAlreadyInActiveTier,
    OOSErrorObjectNotInActiveTier,
};

typedef NS_ENUM(NSInteger, OOSAnalyticsExportFileFormat) {
    OOSAnalyticsExportFileFormatUnknown,
    OOSAnalyticsExportFileFormatCsv,
};

typedef NS_ENUM(NSInteger, OOSBucketAccelerateStatus) {
    OOSBucketAccelerateStatusUnknown,
    OOSBucketAccelerateStatusEnabled,
    OOSBucketAccelerateStatusSuspended,
};

typedef NS_ENUM(NSInteger, OOSBucketCannedACL) {
    OOSBucketCannedACLUnknown,
    OOSBucketCannedACLPrivate,
    OOSBucketCannedACLPublicRead,
    OOSBucketCannedACLPublicReadWrite,
};

typedef NS_ENUM(NSInteger, OOSBucketLogsPermission) {
    OOSBucketLogsPermissionUnknown,
    OOSBucketLogsPermissionFullControl,
    OOSBucketLogsPermissionRead,
    OOSBucketLogsPermissionWrite,
};

typedef NS_ENUM(NSInteger, OOSBucketVersioningStatus) {
    OOSBucketVersioningStatusUnknown,
    OOSBucketVersioningStatusEnabled,
    OOSBucketVersioningStatusSuspended,
};

typedef NS_ENUM(NSInteger, OOSCompressionType) {
    OOSCompressionTypeUnknown,
    OOSCompressionTypeNone,
    OOSCompressionTypeGzip,
};

typedef NS_ENUM(NSInteger, OOSEncodingType) {
    OOSEncodingTypeUnknown,
    OOSEncodingTypeURL,
};

typedef NS_ENUM(NSInteger, OOSEvent) {
    OOSEventUnknown,
    OOSEventReducedRedundancyLostObject,
    OOSEventObjectCreated,
    OOSEventObjectCreatedPut,
    OOSEventObjectCreatedPost,
    OOSEventObjectCreatedCopy,
    OOSEventObjectCreatedCompleteMultipartUpload,
    OOSEventObjectRemoved,
    OOSEventObjectRemovedDelete,
    OOSEventObjectRemovedDeleteMarkerCreated,
};

typedef NS_ENUM(NSInteger, OOSExpirationStatus) {
    OOSExpirationStatusUnknown,
    OOSExpirationStatusEnabled,
    OOSExpirationStatusDisabled,
};

typedef NS_ENUM(NSInteger, OOSExpressionType) {
    OOSExpressionTypeUnknown,
    OOSExpressionTypeSql,
};

typedef NS_ENUM(NSInteger, OOSFileHeaderInfo) {
    OOSFileHeaderInfoUnknown,
    OOSFileHeaderInfoUse,
    OOSFileHeaderInfoIgnore,
    OOSFileHeaderInfoNone,
};

typedef NS_ENUM(NSInteger, OOSFilterRuleName) {
    OOSFilterRuleNameUnknown,
    OOSFilterRuleNamePrefix,
    OOSFilterRuleNameSuffix,
};

typedef NS_ENUM(NSInteger, OOSInventoryFormat) {
    OOSInventoryFormatUnknown,
    OOSInventoryFormatCsv,
    OOSInventoryFormatOrc,
};

typedef NS_ENUM(NSInteger, OOSInventoryFrequency) {
    OOSInventoryFrequencyUnknown,
    OOSInventoryFrequencyDaily,
    OOSInventoryFrequencyWeekly,
};

typedef NS_ENUM(NSInteger, OOSInventoryIncludedObjectVersions) {
    OOSInventoryIncludedObjectVersionsUnknown,
    OOSInventoryIncludedObjectVersionsAll,
    OOSInventoryIncludedObjectVersionsCurrent,
};

typedef NS_ENUM(NSInteger, OOSInventoryOptionalField) {
    OOSInventoryOptionalFieldUnknown,
    OOSInventoryOptionalFieldSize,
    OOSInventoryOptionalFieldLastModifiedDate,
    OOSInventoryOptionalFieldStorageClass,
    OOSInventoryOptionalFieldETag,
    OOSInventoryOptionalFieldIsMultipartUploaded,
    OOSInventoryOptionalFieldReplicationStatus,
    OOSInventoryOptionalFieldEncryptionStatus,
};

typedef NS_ENUM(NSInteger, OOSJSONType) {
    OOSJSONTypeUnknown,
    OOSJSONTypeDocument,
    OOSJSONTypeLines,
};

typedef NS_ENUM(NSInteger, OOSMFADelete) {
    OOSMFADeleteUnknown,
    OOSMFADeleteEnabled,
    OOSMFADeleteDisabled,
};

typedef NS_ENUM(NSInteger, OOSMFADeleteStatus) {
    OOSMFADeleteStatusUnknown,
    OOSMFADeleteStatusEnabled,
    OOSMFADeleteStatusDisabled,
};

typedef NS_ENUM(NSInteger, OOSMetadataDirective) {
    OOSMetadataDirectiveUnknown,
    OOSMetadataDirectiveCopy,
    OOSMetadataDirectiveReplace,
};

typedef NS_ENUM(NSInteger, OOSObjectCannedACL) {
    OOSObjectCannedACLUnknown,
    OOSObjectCannedACLPrivate,
    OOSObjectCannedACLPublicRead,
    OOSObjectCannedACLPublicReadWrite,
    OOSObjectCannedACLAuthenticatedRead,
    OOSObjectCannedACLOOSExecRead,
    OOSObjectCannedACLBucketOwnerRead,
    OOSObjectCannedACLBucketOwnerFullControl,
};

typedef NS_ENUM(NSInteger, OOSObjectStorageClass) {
    OOSObjectStorageClassUnknown,
    OOSObjectStorageClassStandard,
    OOSObjectStorageClassReducedRedundancy,
    OOSObjectStorageClassGlacier,
    OOSObjectStorageClassStandardIa,
    OOSObjectStorageClassOnezoneIa,
};

typedef NS_ENUM(NSInteger, OOSObjectVersionStorageClass) {
    OOSObjectVersionStorageClassUnknown,
    OOSObjectVersionStorageClassStandard,
};

typedef NS_ENUM(NSInteger, OOSOwnerOverride) {
    OOSOwnerOverrideUnknown,
    OOSOwnerOverrideDestination,
};

typedef NS_ENUM(NSInteger, OOSPayer) {
    OOSPayerUnknown,
    OOSPayerRequester,
    OOSPayerBucketOwner,
};

typedef NS_ENUM(NSInteger, OOSPermission) {
    OOSPermissionUnknown,
    OOSPermissionFullControl,
    OOSPermissionWrite,
    OOSPermissionWriteAcp,
    OOSPermissionRead,
    OOSPermissionReadAcp,
};

typedef NS_ENUM(NSInteger, OOSProtocols) {
    OOSProtocolsUnknown,
    OOSProtocolsHTTP,
    OOSProtocolsHTTPS,
};

typedef NS_ENUM(NSInteger, OOSQuoteFields) {
    OOSQuoteFieldsUnknown,
    OOSQuoteFieldsAlways,
    OOSQuoteFieldsAsneeded,
};

typedef NS_ENUM(NSInteger, OOSReplicationRuleStatus) {
    OOSReplicationRuleStatusUnknown,
    OOSReplicationRuleStatusEnabled,
    OOSReplicationRuleStatusDisabled,
};

typedef NS_ENUM(NSInteger, OOSReplicationStatus) {
    OOSReplicationStatusUnknown,
    OOSReplicationStatusComplete,
    OOSReplicationStatusPending,
    OOSReplicationStatusFailed,
    OOSReplicationStatusReplica,
};

typedef NS_ENUM(NSInteger, OOSRequestCharged) {
    OOSRequestChargedUnknown,
    OOSRequestChargedRequester,
};

typedef NS_ENUM(NSInteger, OOSRequestPayer) {
    OOSRequestPayerUnknown,
    OOSRequestPayerRequester,
};

typedef NS_ENUM(NSInteger, OOSRestoreRequestType) {
    OOSRestoreRequestTypeUnknown,
    OOSRestoreRequestTypeSelect,
};

typedef NS_ENUM(NSInteger, OOSServerSideEncryption) {
    OOSServerSideEncryptionUnknown,
    OOSServerSideEncryptionAES256,
    OOSServerSideEncryptionOOSKms,
};

typedef NS_ENUM(NSInteger, OOSSseKmsEncryptedObjectsStatus) {
    OOSSseKmsEncryptedObjectsStatusUnknown,
    OOSSseKmsEncryptedObjectsStatusEnabled,
    OOSSseKmsEncryptedObjectsStatusDisabled,
};

typedef NS_ENUM(NSInteger, OOSStorageClass) {
    OOSStorageClassUnknown,
    OOSStorageClassStandard,
    OOSStorageClassReducedRedundancy,
};

typedef NS_ENUM(NSInteger, OOSStorageClassAnalysisSchemaVersion) {
    OOSStorageClassAnalysisSchemaVersionUnknown,
    OOSStorageClassAnalysisSchemaVersionV1,
};

typedef NS_ENUM(NSInteger, OOSTaggingDirective) {
    OOSTaggingDirectiveUnknown,
    OOSTaggingDirectiveCopy,
    OOSTaggingDirectiveReplace,
};

typedef NS_ENUM(NSInteger, OOSTier) {
    OOSTierUnknown,
    OOSTierStandard,
    OOSTierBulk,
    OOSTierExpedited,
};

typedef NS_ENUM(NSInteger, OOSTransitionStorageClass) {
    OOSTransitionStorageClassUnknown,
    OOSTransitionStorageClassGlacier,
    OOSTransitionStorageClassStandardIa,
    OOSTransitionStorageClassOnezoneIa,
};

typedef NS_ENUM(NSInteger, OOSTypes) {
    OOSTypesUnknown,
    OOSTypesCanonicalUser,
    OOSTypesAmazonCustomerByEmail,
    OOSTypesGroup,
};

@class OOSAbortIncompleteMultipartUpload;
@class OOSAbortMultipartUploadOutput;
@class OOSAbortMultipartUploadRequest;
@class OOSAccelerateConfiguration;
@class OOSAccessControlPolicy;
@class OOSAccessControlTranslation;
@class OOSAnalyticsAndOperator;
@class OOSAnalyticsConfiguration;
@class OOSAnalyticsExportDestination;
@class OOSAnalyticsFilter;
@class OOSAnalyticsBucketDestination;
@class OOSBucket;
@class OOSBucketLifecycleConfiguration;
@class OOSBucketLoggingStatus;
@class OOSCORSConfiguration;
@class OOSCORSRule;
@class OOSCSVInput;
@class OOSCSVOutput;
@class OOSCloudFunctionConfiguration;
@class OOSCommonPrefix;
@class OOSCompleteMultipartUploadOutput;
@class OOSCompleteMultipartUploadRequest;
@class OOSCompletedMultipartUpload;
@class OOSCompletedPart;
@class OOSCondition;
@class OOSContinuationEvent;
@class OOSCopyObjectOutput;
@class OOSCopyObjectRequest;
@class OOSReplicateObjectResult;
@class OOSReplicatePartResult;
@class OOSCreateBucketConfiguration;
@class OOSCreateBucketOutput;
@class OOSCreateBucketRequest;
@class OOSCreateMultipartUploadOutput;
@class OOSCreateMultipartUploadRequest;
@class OOSRemove;
@class OOSDeleteBucketAnalyticsConfigurationRequest;
@class OOSDeleteBucketCorsRequest;
@class OOSDeleteBucketEncryptionRequest;
@class OOSDeleteBucketInventoryConfigurationRequest;
@class OOSDeleteBucketLifecycleRequest;
@class OOSDeleteBucketMetricsConfigurationRequest;
@class OOSDeleteBucketPolicyRequest;
@class OOSDeleteBucketReplicationRequest;
@class OOSDeleteBucketRequest;
@class OOSDeleteBucketTaggingRequest;
@class OOSDeleteBucketWebsiteRequest;
@class OOSDeleteMarkerEntry;
@class OOSDeleteObjectOutput;
@class OOSDeleteObjectRequest;
@class OOSDeleteObjectTaggingOutput;
@class OOSDeleteObjectTaggingRequest;
@class OOSDeleteObjectsOutput;
@class OOSDeleteObjectsRequest;
@class OOSDeletedObject;
@class OOSDestination;
@class OOSEncryption;
@class OOSEncryptionConfiguration;
@class OOSEndEvent;
@class OOSError;
@class OOSErrorDocument;
@class OOSFilterRule;
@class OOSGetBucketAccelerateConfigurationOutput;
@class OOSGetBucketAccelerateConfigurationRequest;
@class OOSGetBucketAclOutput;
@class OOSGetBucketAclRequest;
@class OOSGetBucketAnalyticsConfigurationOutput;
@class OOSGetBucketAnalyticsConfigurationRequest;
@class OOSGetBucketCorsOutput;
@class OOSGetBucketCorsRequest;
@class OOSGetBucketEncryptionOutput;
@class OOSGetBucketEncryptionRequest;
@class OOSGetBucketInventoryConfigurationOutput;
@class OOSGetBucketInventoryConfigurationRequest;
@class OOSGetBucketLifecycleConfigurationOutput;
@class OOSGetBucketLifecycleConfigurationRequest;
@class OOSGetBucketLifecycleOutput;
@class OOSGetBucketLifecycleRequest;
@class OOSGetBucketLoggingOutput;
@class OOSGetBucketLoggingRequest;
@class OOSGetBucketMetricsConfigurationOutput;
@class OOSGetBucketMetricsConfigurationRequest;
@class OOSGetBucketNotificationConfigurationRequest;
@class OOSGetBucketPolicyOutput;
@class OOSGetBucketPolicyRequest;
@class OOSGetBucketReplicationOutput;
@class OOSGetBucketReplicationRequest;
@class OOSGetBucketRequestPaymentOutput;
@class OOSGetBucketRequestPaymentRequest;
@class OOSGetBucketTaggingOutput;
@class OOSGetBucketTaggingRequest;
@class OOSGetBucketVersioningOutput;
@class OOSGetBucketVersioningRequest;
@class OOSGetBucketWebsiteOutput;
@class OOSGetBucketWebsiteRequest;
@class OOSGetObjectAclOutput;
@class OOSGetObjectAclRequest;
@class OOSGetObjectOutput;
@class OOSGetObjectRequest;
@class OOSGetObjectTaggingOutput;
@class OOSGetObjectTaggingRequest;
@class OOSGetObjectTorrentOutput;
@class OOSGetObjectTorrentRequest;
@class OOSGlacierJobParameters;
@class OOSGrant;
@class OOSGrantee;
@class OOSHeadBucketRequest;
@class OOSHeadObjectOutput;
@class OOSHeadObjectRequest;
@class OOSIndexDocument;
@class OOSInitiator;
@class OOSInputSerialization;
@class OOSInventoryConfiguration;
@class OOSInventoryDestination;
@class OOSInventoryEncryption;
@class OOSInventoryFilter;
@class OOSInventoryBucketDestination;
@class OOSInventorySchedule;
@class OOSJSONInput;
@class OOSJSONOutput;
@class OOSLambdaFunctionConfiguration;
@class OOSLifecycleConfiguration;
@class OOSLifecycleExpiration;
@class OOSLifecycleRule;
@class OOSLifecycleRuleAndOperator;
@class OOSLifecycleRuleFilter;
@class OOSListBucketAnalyticsConfigurationsOutput;
@class OOSListBucketAnalyticsConfigurationsRequest;
@class OOSListBucketInventoryConfigurationsOutput;
@class OOSListBucketInventoryConfigurationsRequest;
@class OOSListBucketMetricsConfigurationsOutput;
@class OOSListBucketMetricsConfigurationsRequest;
@class OOSListBucketsOutput;
@class OOSListMultipartUploadsOutput;
@class OOSListMultipartUploadsRequest;
@class OOSListObjectVersionsOutput;
@class OOSListObjectVersionsRequest;
@class OOSListObjectsOutput;
@class OOSListObjectsRequest;
@class OOSListObjectsV2Output;
@class OOSListObjectsV2Request;
@class OOSListPartsOutput;
@class OOSListPartsRequest;
@class OOSLoggingEnabled;
@class OOSMetadataEntry;
@class OOSMetricsAndOperator;
@class OOSMetricsConfiguration;
@class OOSMetricsFilter;
@class OOSMultipartUpload;
@class OOSNoncurrentVersionExpiration;
@class OOSNoncurrentVersionTransition;
@class OOSNotificationConfiguration;
@class OOSNotificationConfigurationDeprecated;
@class OOSNotificationConfigurationFilter;
@class OOSObject;
@class OOSObjectIdentifier;
@class OOSObjectVersion;
@class OOSOutputSerialization;
@class OOSOwner;
@class OOSPart;
@class OOSProgress;
@class OOSProgressEvent;
@class OOSPutBucketAccelerateConfigurationRequest;
@class OOSPutBucketAclRequest;
@class OOSPutBucketAnalyticsConfigurationRequest;
@class OOSPutBucketCorsRequest;
@class OOSPutBucketEncryptionRequest;
@class OOSPutBucketInventoryConfigurationRequest;
@class OOSPutBucketLifecycleConfigurationRequest;
@class OOSPutBucketLifecycleRequest;
@class OOSPutBucketLoggingRequest;
@class OOSPutBucketMetricsConfigurationRequest;
@class OOSPutBucketNotificationConfigurationRequest;
@class OOSPutBucketNotificationRequest;
@class OOSPutBucketPolicyRequest;
@class OOSPutBucketReplicationRequest;
@class OOSPutBucketRequestPaymentRequest;
@class OOSPutBucketTaggingRequest;
@class OOSPutBucketVersioningRequest;
@class OOSPutBucketWebsiteRequest;
@class OOSPutObjectAclOutput;
@class OOSPutObjectAclRequest;
@class OOSPutObjectOutput;
@class OOSPutObjectRequest;
@class OOSPutObjectTaggingOutput;
@class OOSPutObjectTaggingRequest;
@class OOSQueueConfiguration;
@class OOSQueueConfigurationDeprecated;
@class OOSRecordsEvent;
@class OOSRedirect;
@class OOSRedirectAllRequestsTo;
@class OOSReplicationConfiguration;
@class OOSReplicationRule;
@class OOSRequestPaymentConfiguration;
@class OOSRequestProgress;
@class OOSRestoreObjectOutput;
@class OOSRestoreObjectRequest;
@class OOSRestoreRequest;
@class OOSRoutingRule;
@class OOSRule;
@class OOSKeyFilter;
@class OOSLocation;
@class OOSSSEKMS;
@class OOSSSE;
@class OOSSelectObjectContentEventStream;
@class OOSSelectObjectContentOutput;
@class OOSSelectObjectContentRequest;
@class OOSSelectParameters;
@class OOSServerSideEncryptionByDefault;
@class OOSServerSideEncryptionConfiguration;
@class OOSServerSideEncryptionRule;
@class OOSSourceSelectionCriteria;
@class OOSSseKmsEncryptedObjects;
@class OOSStats;
@class OOSStatsEvent;
@class OOSStorageClassAnalysis;
@class OOSStorageClassAnalysisDataExport;
@class OOSTag;
@class OOSTagging;
@class OOSTargetGrant;
@class OOSTopicConfiguration;
@class OOSTopicConfigurationDeprecated;
@class OOSTransition;
@class OOSUploadPartCopyOutput;
@class OOSUploadPartCopyRequest;
@class OOSUploadPartOutput;
@class OOSUploadPartRequest;
@class OOSVersioningConfiguration;
@class OOSWebsiteConfiguration;
@class OOSPutBucketTriggerRequest;
@class OOSGetBucketTriggerRequest;
@class OOSDeleteBucketTriggerRequest;
@class OOSGetBucketTriggerOutput;
@class OOSTriggerConfiguration;
@class OOSTrigger;
@class OOSRemoteSite;
@class OOSCreateAccessKeyRequest;
@class OOSCreateAccessKeyOutput;
@class OOSDeleteAccessKeyRequest;
@class OOSDeleteAccessKeyOutput;
@class OOSUpdateAccessKeyRequest;
@class OOSUpdateAccessKeyOutput;
@class OOSListAccessKeyRequest;
@class OOSListAccessKeyOutput;
@class OOSGetBucketLocationRequest;
@class OOSGetBucketLocationOutput;
@class OOSGetRegionsRequest;
@class OOSGetRegionsOutput;

/**
 Specifies the days since the initiation of an Incomplete Multipart Upload that Lifecycle will wait before permanently removing all parts of the upload.
 */
@interface OOSAbortIncompleteMultipartUpload : CoreModel


/**
 Indicates the number of days that must pass since initiation for Lifecycle to abort an Incomplete Multipart Upload.
 */
@property (nonatomic, strong) NSNumber * _Nullable daysAfterInitiation;

@end

/**
 
 */
@interface OOSAbortMultipartUploadOutput : CoreModel


/**
 If present, indicates that the requester was successfully charged for the request.
 */
@property (nonatomic, assign) OOSRequestCharged requestCharged;

@end

/**
 
 */
@interface OOSAbortMultipartUploadRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 Confirms that the requester knows that she or he will be charged for the request. Bucket owners need not specify this parameter in their requests. Documentation on downloading objects from requester pays buckets can be found at http://docs.OOS.amazon.com/Amazon/latest/dev/ObjectsinRequesterPaysBuckets.html
 */
@property (nonatomic, assign) OOSRequestPayer requestPayer;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable uploadId;

@end


@interface OOSIPWhiteLists : CoreModel

@property (nonatomic, strong) NSArray<NSString *> * _Nullable ips;

@end

/**
 
 */
@interface OOSAccelerateConfiguration : CoreModel


/**
 The accelerate configuration of the bucket.
 */
@property (nonatomic, assign) OOSBucketAccelerateStatus status;


/**
 A list of ips.
 */
@property (nonatomic, strong) OOSIPWhiteLists * _Nullable ipWhiteLists;

@end

/**
 
 */
@interface OOSAccessControlPolicy : CoreModel


/**
 A list of grants.
 */
@property (nonatomic, strong) NSArray<OOSGrant *> * _Nullable grants;

/**
 
 */
@property (nonatomic, strong) OOSOwner * _Nullable owner;

@end

/**
 Container for information regarding the access control for replicas.
 Required parameters: [Owner]
 */
@interface OOSAccessControlTranslation : CoreModel


/**
 The override value for the owner of the replica object.
 */
@property (nonatomic, assign) OOSOwnerOverride owner;

@end

/**
 
 */
@interface OOSAnalyticsAndOperator : CoreModel


/**
 The prefix to use when evaluating an AND predicate.
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

/**
 The list of tags to use when evaluating an AND predicate.
 */
@property (nonatomic, strong) NSArray<OOSTag *> * _Nullable tags;

@end

/**
 
 */
@interface OOSAnalyticsConfiguration : CoreModel


/**
 The filter used to describe a set of objects for analyses. A filter must have exactly one prefix, one tag, or one conjunction (AnalyticsAndOperator). If no filter is provided, all objects will be considered in any analysis.
 */
@property (nonatomic, strong) OOSAnalyticsFilter * _Nullable filter;

/**
 The identifier used to represent an analytics configuration.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

/**
 If present, it indicates that data related to access patterns will be collected and made available to analyze the tradeoffs between different storage classes.
 */
@property (nonatomic, strong) OOSStorageClassAnalysis * _Nullable storageClassAnalysis;

@end

/**
 
 */
@interface OOSAnalyticsExportDestination : CoreModel


/**
 A destination signifying output to an  bucket.
 */
@property (nonatomic, strong) OOSAnalyticsBucketDestination * _Nullable BucketDestination;

@end

/**
 
 */
@interface OOSAnalyticsFilter : CoreModel


/**
 A conjunction (logical AND) of predicates, which is used in evaluating an analytics filter. The operator must have at least two predicates.
 */
@property (nonatomic, strong) OOSAnalyticsAndOperator * _Nullable AND;

/**
 The prefix to use when evaluating an analytics filter.
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

/**
 The tag to use when evaluating an analytics filter.
 */
@property (nonatomic, strong) OOSTag * _Nullable tag;

@end

/**
 
 */
@interface OOSAnalyticsBucketDestination : CoreModel


/**
 The Amazon resource name (ARN) of the bucket to which data is exported.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 The account ID that owns the destination bucket. If no account ID is provided, the owner will not be validated prior to exporting data.
 */
@property (nonatomic, strong) NSString * _Nullable bucketAccountId;

/**
 The file format used when exporting data to Amazon .
 */
@property (nonatomic, assign) OOSAnalyticsExportFileFormat format;

/**
 The prefix to use when exporting data. The exported data begins with this prefix.
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

@end

/**
 
 */
@interface OOSBucket : CoreModel


/**
 Date the bucket was created.
 */
@property (nonatomic, strong) NSDate * _Nullable creationDate;

/**
 The name of the bucket.
 */
@property (nonatomic, strong) NSString * _Nullable name;

@end

/**
 
 */
@interface OOSBucketLifecycleConfiguration : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<OOSLifecycleRule *> * _Nullable rules;

@end

/**
 
 */
@interface OOSBucketLoggingStatus : CoreModel


/**
 Container for logging information. Presence of this element indicates that logging is enabled. Parameters TargetBucket and TargetPrefix are required in this case.
 */
@property (nonatomic, strong) OOSLoggingEnabled * _Nullable loggingEnabled;

@end

/**
 
 */
@interface OOSCORSConfiguration : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<OOSCORSRule *> * _Nullable CORSRules;

@end

/**
 
 */
@interface OOSCORSRule : CoreModel

/**
 ID
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

/**
 Specifies which headers are allowed in a pre-flight OPTIONS request.
 */
@property (nonatomic, strong) NSArray<NSString *> * _Nullable allowedHeaders;

/**
 Identifies HTTP methods that the domain/origin specified in the rule is allowed to execute.
 */
@property (nonatomic, strong) NSArray<NSString *> * _Nullable allowedMethods;

/**
 One or more origins you want customers to be able to access the bucket from.
 */
@property (nonatomic, strong) NSArray<NSString *> * _Nullable allowedOrigins;

/**
 One or more headers in the response that you want customers to be able to access from their applications (for example, from a JavaScript XMLHttpRequest object).
 */
@property (nonatomic, strong) NSArray<NSString *> * _Nullable exposeHeaders;

/**
 The time in seconds that your browser is to cache the preflight response for the specified resource.
 */
@property (nonatomic, strong) NSNumber * _Nullable maxAgeSeconds;

@end

/**
 Describes how a CSV-formatted input object is formatted.
 */
@interface OOSCSVInput : CoreModel


/**
 Single character used to indicate a row should be ignored when present at the start of a row.
 */
@property (nonatomic, strong) NSString * _Nullable comments;

/**
 Value used to separate individual fields in a record.
 */
@property (nonatomic, strong) NSString * _Nullable fieldDelimiter;

/**
 Describes the first line of input. Valid values: None, Ignore, Use.
 */
@property (nonatomic, assign) OOSFileHeaderInfo fileHeaderInfo;

/**
 Value used for escaping where the field delimiter is part of the value.
 */
@property (nonatomic, strong) NSString * _Nullable quoteCharacter;

/**
 Single character used for escaping the quote character inside an already escaped value.
 */
@property (nonatomic, strong) NSString * _Nullable quoteEscapeCharacter;

/**
 Value used to separate individual records.
 */
@property (nonatomic, strong) NSString * _Nullable recordDelimiter;

@end

/**
 Describes how CSV-formatted results are formatted.
 */
@interface OOSCSVOutput : CoreModel


/**
 Value used to separate individual fields in a record.
 */
@property (nonatomic, strong) NSString * _Nullable fieldDelimiter;

/**
 Value used for escaping where the field delimiter is part of the value.
 */
@property (nonatomic, strong) NSString * _Nullable quoteCharacter;

/**
 Single character used for escaping the quote character inside an already escaped value.
 */
@property (nonatomic, strong) NSString * _Nullable quoteEscapeCharacter;

/**
 Indicates whether or not all output fields should be quoted.
 */
@property (nonatomic, assign) OOSQuoteFields quoteFields;

/**
 Value used to separate individual records.
 */
@property (nonatomic, strong) NSString * _Nullable recordDelimiter;

@end

/**
 
 */
@interface OOSCloudFunctionConfiguration : CoreModel


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable cloudFunction;

/**
 Bucket event for which to send notifications.
 */
@property (nonatomic, assign) OOSEvent event;

/**
 
 */
@property (nonatomic, strong) NSArray<NSString *> * _Nullable events;

/**
 Optional unique identifier for configurations in a notification configuration. If you don't provide one, Amazon  will assign an ID.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable invocationRole;

@end

/**
 
 */
@interface OOSCommonPrefix : CoreModel


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

@end

/**
 
 */
@interface OOSCompleteMultipartUploadOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 Entity tag of the object.
 */
@property (nonatomic, strong) NSString * _Nullable ETag;

/**
 If the object expiration is configured, this will contain the expiration date (expiry-date) and rule ID (rule-id). The value of rule-id is URL encoded.
 */
@property (nonatomic, strong) NSString * _Nullable expiration;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable location;

/**
 If present, indicates that the requester was successfully charged for the request.
 */
@property (nonatomic, assign) OOSRequestCharged requestCharged;

/**
 If present, specifies the ID of the OOS Key Management Service (KMS) master encryption key that was used for the object.
 */
@property (nonatomic, strong) NSString * _Nullable SSEKMSKeyId;

/**
 The Server-side encryption algorithm used when storing this object in  (e.g., AES256, OOS:kms).
 */
@property (nonatomic, assign) OOSServerSideEncryption serverSideEncryption;

/**
 Version of the object.
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 
 */
@interface OOSCompleteMultipartUploadRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 用户首先初始化分片上传过程，然后通过 Upload Part 接口上传所有分片。 在成功将一次分片上传过程的所有相关片段上传之后，调用这个接口来结束分片 上传过程。当收到这个请求的时候，OOS 会以分片号升序排列的方式将所有片段 依次拼接来创建一个新的对象。在这个 Complete Multipart Upload 请求中，用 户需要提供一个片段列表。
 */
@property (nonatomic, strong) OOSCompletedMultipartUpload * _Nullable multipartUpload;

/**
 A standard MIME type describing the format of the object data.
 */
@property (nonatomic, strong) NSString * _Nullable contentType;

/**
 Confirms that the requester knows that she or he will be charged for the request. Bucket owners need not specify this parameter in their requests. Documentation on downloading objects from requester pays buckets can be found at http://docs.OOS.amazon.com/Amazon/latest/dev/ObjectsinRequesterPaysBuckets.html
 */
@property (nonatomic, assign) OOSRequestPayer requestPayer;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable uploadId;

@end

/**
 
 */
@interface OOSCompletedMultipartUpload : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<OOSCompletedPart *> * _Nullable parts;

@end

/**
 
 */
@interface OOSCompletedPart : CoreModel


/**
 Entity tag returned when the part was uploaded.
 */
@property (nonatomic, strong) NSString * _Nullable ETag;

/**
 Part number that identifies the part. This is a positive integer between 1 and 10,000.
 */
@property (nonatomic, strong) NSNumber * _Nullable partNumber;

@end

/**
 
 */
@interface OOSCondition : CoreModel


/**
 The HTTP error code when the redirect is applied. In the event of an error, if the error code equals this value, then the specified redirect is applied. Required when parent element Condition is specified and sibling KeyPrefixEquals is not specified. If both are specified, then both must be true for the redirect to be applied.
 */
@property (nonatomic, strong) NSString * _Nullable httpErrorCodeReturnedEquals;

/**
 The object key name prefix when the redirect is applied. For example, to redirect requests for ExamplePage.html, the key prefix will be ExamplePage.html. To redirect request for all pages with the prefix docs/, the key prefix will be /docs, which identifies all objects in the docs/ folder. Required when the parent element Condition is specified and sibling HttpErrorCodeReturnedEquals is not specified. If both conditions are specified, both must be true for the redirect to be applied.
 */
@property (nonatomic, strong) NSString * _Nullable keyPrefixEquals;

@end

/**
 
 */
@interface OOSContinuationEvent : CoreModel


@end

/**
 
 */
@interface OOSCopyObjectOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) OOSReplicateObjectResult * _Nullable replicateObjectResult;

@end

/**
 
 */
@interface OOSCopyObjectRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 Specifies caching behavior along the request/reply chain.
 */
@property (nonatomic, strong) NSString * _Nullable cacheControl;

/**
 需要复制的目标源，写法为：bucket/key
 */
@property (nonatomic, strong) NSString * _Nullable replicateSource;

/**
 Copies the object if its entity tag (ETag) matches the specified tag.
 */
@property (nonatomic, strong) NSString * _Nullable replicateSourceIfMatch;

/**
 Copies the object if it has been modified since the specified time.
 */
@property (nonatomic, strong) NSDate * _Nullable replicateSourceIfModifiedSince;

/**
 Copies the object if its entity tag (ETag) is different than the specified ETag.
 */
@property (nonatomic, strong) NSString * _Nullable replicateSourceIfNoneMatch;

/**
 Copies the object if it hasn't been modified since the specified time.
 */
@property (nonatomic, strong) NSDate * _Nullable replicateSourceIfUnmodifiedSince;

/**
 The date and time at which the object is no longer cacheable.
 */
@property (nonatomic, strong) NSDate * _Nullable expires;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 A map of metadata to store with the object in .
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> * _Nullable metadata;

/**
 Specifies whether the metadata is copied from the source object or replaced with metadata provided in the request.
 */
@property (nonatomic, assign) OOSMetadataDirective metadataDirective;

/**
 The type of storage to use for the object. Defaults to 'STANDARD'.
 */
@property (nonatomic, assign) OOSStorageClass storageClass;

/**
 The tag-set for the object destination object this value must be used in conjunction with the TaggingDirective. The tag-set must be encoded as URL Query parameters
 */
@property (nonatomic, strong) NSString * _Nullable tagging;

/**
 Specifies whether the object tag-set are copied from the source object or replaced with tag-set provided in the request.
 */
@property (nonatomic, assign) OOSTaggingDirective taggingDirective;

/**
 设置bucket的数据位置。
 类型：key-value形式
 有效值：
 type=[ Local|Specified],location=[ ChengDu|ShenYa
 ng|...],scheduleStrategy=[ Allowed|NotAllowed]
 type=local表示就近写入本地。type= Specified表示指定
 位置。location表示指定的数据位置，可以填写多个，以
 逗号分隔。scheduleStrategy表示调度策略，是否允许
 OOS自动调度数据存储位置。
 */
@property (nonatomic, strong) NSString * _Nullable dataLocation;


@end

/**
 
 */
@interface OOSReplicateObjectResult : CoreModel


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable ETag;

/**
 
 */
@property (nonatomic, strong) NSDate * _Nullable lastModified;

@end

/**
 
 */
@interface OOSReplicatePartResult : CoreModel


/**
 Entity tag of the object.
 */
@property (nonatomic, strong) NSString * _Nullable ETag;

/**
 Date and time at which the object was uploaded.
 */
@property (nonatomic, strong) NSDate * _Nullable lastModified;

@end

@interface OOSMetaDataLocationConstraint : CoreModel

@property (nonatomic, strong) NSString * _Nullable location;

@end

@interface OOSDataLocationList : CoreModel

@property (nonatomic, strong) NSArray<NSString *> * _Nullable locations;

@end

@interface OOSDataLocationConstraint : CoreModel

@property (nonatomic, strong) NSString * _Nullable type;
@property (nonatomic, strong) NSString * _Nullable scheduleStrategy;
@property (nonatomic, strong) OOSDataLocationList * _Nullable locationList;

@end

/**
 
 */
@interface OOSCreateBucketConfiguration : CoreModel

@property (nonatomic, strong) OOSMetaDataLocationConstraint * _Nullable metadataLocationConstraint;
@property (nonatomic, strong) OOSDataLocationConstraint * _Nullable dataLocationConstraint;

@end


/**
 
 */
@interface OOSCreateBucketOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable location;

@end

/**
 
 */
@interface OOSCreateBucketRequest : OOSRequest

/**
 The canned ACL to apply to the bucket.
 */
@property (nonatomic, assign) OOSBucketCannedACL ACL;

/**
 Bucket name
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) OOSCreateBucketConfiguration * _Nullable createBucketConfiguration;

/**
 Allows grantee the read, write, read ACP, and write ACP permissions on the bucket.
 */
@property (nonatomic, strong) NSString * _Nullable grantFullControl;

/**
 Allows grantee to list the objects in the bucket.
 */
@property (nonatomic, strong) NSString * _Nullable grantRead;

/**
 Allows grantee to read the bucket ACL.
 */
@property (nonatomic, strong) NSString * _Nullable grantReadACP;

/**
 Allows grantee to create, overwrite, and delete any object in the bucket.
 */
@property (nonatomic, strong) NSString * _Nullable grantWrite;

/**
 Allows grantee to write the ACL for the applicable bucket.
 */
@property (nonatomic, strong) NSString * _Nullable grantWriteACP;

@end

/**
 
 */
@interface OOSCreateMultipartUploadOutput : CoreModel


/**
 Date when multipart upload will become eligible for abort operation by lifecycle.
 */
@property (nonatomic, strong) NSDate * _Nullable abortDate;

/**
 Id of the lifecycle rule that makes a multipart upload eligible for abort operation.
 */
@property (nonatomic, strong) NSString * _Nullable abortRuleId;

/**
 Name of the bucket to which the multipart upload was initiated.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 Object key for which the multipart upload was initiated.
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 If present, indicates that the requester was successfully charged for the request.
 */
@property (nonatomic, assign) OOSRequestCharged requestCharged;

/**
 If server-side encryption with a customer-provided encryption key was requested, the response will include this header confirming the encryption algorithm used.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerAlgorithm;

/**
 If server-side encryption with a customer-provided encryption key was requested, the response will include this header to provide round trip message integrity verification of the customer-provided encryption key.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerKeyMD5;

/**
 If present, specifies the ID of the OOS Key Management Service (KMS) master encryption key that was used for the object.
 */
@property (nonatomic, strong) NSString * _Nullable SSEKMSKeyId;

/**
 The Server-side encryption algorithm used when storing this object in  (e.g., AES256, OOS:kms).
 */
@property (nonatomic, assign) OOSServerSideEncryption serverSideEncryption;

/**
 ID for the initiated multipart upload.
 */
@property (nonatomic, strong) NSString * _Nullable uploadId;

@end

/**
 
 */
@interface OOSCreateMultipartUploadRequest : OOSRequest


/**
 The canned ACL to apply to the object.
 */
@property (nonatomic, assign) OOSObjectCannedACL ACL;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 Specifies caching behavior along the request/reply chain.
 */
@property (nonatomic, strong) NSString * _Nullable cacheControl;

/**
 Specifies presentational information for the object.
 */
@property (nonatomic, strong) NSString * _Nullable contentDisposition;

/**
 Specifies what content encodings have been applied to the object and thus what decoding mechanisms must be applied to obtain the media-type referenced by the Content-Type header field.
 */
@property (nonatomic, strong) NSString * _Nullable contentEncoding;

/**
 The language the content is in.
 */
@property (nonatomic, strong) NSString * _Nullable contentLanguage;

/**
 A standard MIME type describing the format of the object data.
 */
@property (nonatomic, strong) NSString * _Nullable contentType;

/**
 The date and time at which the object is no longer cacheable.
 */
@property (nonatomic, strong) NSDate * _Nullable expires;

/**
 Gives the grantee READ, READ_ACP, and WRITE_ACP permissions on the object.
 */
@property (nonatomic, strong) NSString * _Nullable grantFullControl;

/**
 Allows grantee to read the object data and its metadata.
 */
@property (nonatomic, strong) NSString * _Nullable grantRead;

/**
 Allows grantee to read the object ACL.
 */
@property (nonatomic, strong) NSString * _Nullable grantReadACP;

/**
 Allows grantee to write the ACL for the applicable object.
 */
@property (nonatomic, strong) NSString * _Nullable grantWriteACP;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 A map of metadata to store with the object in .
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> * _Nullable metadata;

/**
 Confirms that the requester knows that she or he will be charged for the request. Bucket owners need not specify this parameter in their requests. Documentation on downloading objects from requester pays buckets can be found at http://docs.OOS.amazon.com/Amazon/latest/dev/ObjectsinRequesterPaysBuckets.html
 */
@property (nonatomic, assign) OOSRequestPayer requestPayer;

/**
 Specifies the algorithm to use to when encrypting the object (e.g., AES256).
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerAlgorithm;

/**
 Specifies the customer-provided encryption key for Amazon  to use in encrypting data. This value is used to store the object and then it is discarded; Amazon does not store the encryption key. The key must be appropriate for use with the algorithm specified in the x-amz-server-side​-encryption​-customer-algorithm header.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerKey;

/**
 Specifies the 128-bit MD5 digest of the encryption key according to RFC 1321. Amazon  uses this header for a message integrity check to ensure the encryption key was transmitted without error.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerKeyMD5;

/**
 Specifies the OOS KMS key ID to use for object encryption. All GET and PUT requests for an object protected by OOS KMS will fail if not made via SSL or using SigV4. Documentation on configuring any of the officially supported OOS SDKs and CLI can be found at http://docs.OOS.amazon.com/Amazon/latest/dev/UsingOOSSDK.html#specify-signature-version
 */
@property (nonatomic, strong) NSString * _Nullable SSEKMSKeyId;

/**
 The Server-side encryption algorithm used when storing this object in  (e.g., AES256, OOS:kms).
 */
@property (nonatomic, assign) OOSServerSideEncryption serverSideEncryption;

/**
 The type of storage to use for the object. Defaults to 'STANDARD'.
 */
@property (nonatomic, assign) OOSStorageClass storageClass;

/**
 The tag-set for the object. The tag-set must be encoded as URL Query parameters
 */
@property (nonatomic, strong) NSString * _Nullable tagging;

/**
 If the bucket is configured as a website, redirects requests for this object to another object in the same bucket or to an external URL. Amazon  stores the value of this header in the object metadata.
 */
@property (nonatomic, strong) NSString * _Nullable websiteRedirectLocation;

/**
 设置bucket的数据位置。
 类型：key-value形式
 有效值：
 type=[ Local|Specified],location=[ ChengDu|ShenYa
 ng|...],scheduleStrategy=[ Allowed|NotAllowed]
 type=local表示就近写入本地。type= Specified表示指定
 位置。location表示指定的数据位置，可以填写多个，以
 逗号分隔。scheduleStrategy表示调度策略，是否允许
 OOS自动调度数据存储位置。
 */
@property (nonatomic, strong) NSString * _Nullable dataLocation;

@end

/**
 
 */
@interface OOSRemove : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<OOSObjectIdentifier *> * _Nullable objects;

/**
 Element to enable quiet mode for the request. When you add this element, you must set its value to true.
 */
@property (nonatomic, strong) NSNumber * _Nullable quiet;

@end

/**
 
 */
@interface OOSDeleteBucketAnalyticsConfigurationRequest : OOSRequest


/**
 The name of the bucket from which an analytics configuration is deleted.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 The identifier used to represent an analytics configuration.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

@end

/**
 
 */
@interface OOSDeleteBucketCorsRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSDeleteBucketEncryptionRequest : OOSRequest


/**
 The name of the bucket containing the server-side encryption configuration to delete.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSDeleteBucketInventoryConfigurationRequest : OOSRequest


/**
 The name of the bucket containing the inventory configuration to delete.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 The ID used to identify the inventory configuration.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

@end

/**
 
 */
@interface OOSDeleteBucketLifecycleRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSDeleteBucketMetricsConfigurationRequest : OOSRequest


/**
 The name of the bucket containing the metrics configuration to delete.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 The ID used to identify the metrics configuration.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

@end

/**
 
 */
@interface OOSDeleteBucketPolicyRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSDeleteBucketReplicationRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSDeleteBucketRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSDeleteBucketTaggingRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSDeleteBucketWebsiteRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSDeleteMarkerEntry : CoreModel


/**
 Specifies whether the object is (true) or is not (false) the latest version of an object.
 */
@property (nonatomic, strong) NSNumber * _Nullable isLatest;

/**
 The object key.
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 Date and time the object was last modified.
 */
@property (nonatomic, strong) NSDate * _Nullable lastModified;

/**
 
 */
@property (nonatomic, strong) OOSOwner * _Nullable owner;

/**
 Version ID of an object.
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 
 */
@interface OOSDeleteObjectOutput : CoreModel


/**
 Specifies whether the versioned object that was permanently deleted was (true) or was not (false) a delete marker.
 */
@property (nonatomic, strong) NSNumber * _Nullable deleteMarker;

/**
 If present, indicates that the requester was successfully charged for the request.
 */
@property (nonatomic, assign) OOSRequestCharged requestCharged;

/**
 Returns the version ID of the delete marker created as a result of the DELETE operation.
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 
 */
@interface OOSDeleteObjectRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 The concatenation of the authentication device's serial number, a space, and the value that is displayed on your authentication device.
 */
@property (nonatomic, strong) NSString * _Nullable MFA;

/**
 Confirms that the requester knows that she or he will be charged for the request. Bucket owners need not specify this parameter in their requests. Documentation on downloading objects from requester pays buckets can be found at http://docs.OOS.amazon.com/Amazon/latest/dev/ObjectsinRequesterPaysBuckets.html
 */
@property (nonatomic, assign) OOSRequestPayer requestPayer;

/**
 VersionId used to reference a specific version of the object.
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 
 */
@interface OOSDeleteObjectTaggingOutput : CoreModel


/**
 The versionId of the object the tag-set was removed from.
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 
 */
@interface OOSDeleteObjectTaggingRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 The versionId of the object that the tag-set will be removed from.
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 
 */
@interface OOSDeleteObjectsOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<OOSDeletedObject *> * _Nullable deleted;

/**
 
 */
@property (nonatomic, strong) NSArray<OOSError *> * _Nullable errors;

/**
 If present, indicates that the requester was successfully charged for the request.
 */
@property (nonatomic, assign) OOSRequestCharged requestCharged;

@end

/**
 
 */
@interface OOSDeleteObjectsRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
  默认值为：application/xml，不需要设置
 */
@property (nonatomic, strong) NSString * _Nullable contentType;

/**
 
 */
@property (nonatomic, strong) OOSRemove * _Nullable remove;

/**
 The concatenation of the authentication device's serial number, a space, and the value that is displayed on your authentication device.
 */
@property (nonatomic, strong) NSString * _Nullable MFA;

/**
 Confirms that the requester knows that she or he will be charged for the request. Bucket owners need not specify this parameter in their requests. Documentation on downloading objects from requester pays buckets can be found at http://docs.OOS.amazon.com/Amazon/latest/dev/ObjectsinRequesterPaysBuckets.html
 */
@property (nonatomic, assign) OOSRequestPayer requestPayer;

@end

/**
 
 */
@interface OOSDeletedObject : CoreModel


/**
 
 */
@property (nonatomic, strong) NSNumber * _Nullable deleteMarker;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable deleteMarkerVersionId;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 Container for replication destination information.
 Required parameters: [Bucket]
 */
@interface OOSDestination : CoreModel


/**
 Container for information regarding the access control for replicas.
 */
@property (nonatomic, strong) OOSAccessControlTranslation * _Nullable accessControlTranslation;

/**
 Account ID of the destination bucket. Currently this is only being verified if Access Control Translation is enabled
 */
@property (nonatomic, strong) NSString * _Nullable account;

/**
 Amazon resource name (ARN) of the bucket where you want Amazon  to store replicas of the object identified by the rule.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 Container for information regarding encryption based configuration for replicas.
 */
@property (nonatomic, strong) OOSEncryptionConfiguration * _Nullable encryptionConfiguration;

/**
 The class of storage used to store the object.
 */
@property (nonatomic, assign) OOSStorageClass storageClass;

@end

/**
 Describes the server-side encryption that will be applied to the restore results.
 Required parameters: [EncryptionType]
 */
@interface OOSEncryption : CoreModel


/**
 The server-side encryption algorithm used when storing job results in Amazon  (e.g., AES256, OOS:kms).
 */
@property (nonatomic, assign) OOSServerSideEncryption encryptionType;

/**
 If the encryption type is OOS:kms, this optional value can be used to specify the encryption context for the restore results.
 */
@property (nonatomic, strong) NSString * _Nullable KMSContext;

/**
 If the encryption type is OOS:kms, this optional value specifies the OOS KMS key ID to use for encryption of job results.
 */
@property (nonatomic, strong) NSString * _Nullable KMSKeyId;

@end

/**
 Container for information regarding encryption based configuration for replicas.
 */
@interface OOSEncryptionConfiguration : CoreModel


/**
 The id of the KMS key used to encrypt the replica object.
 */
@property (nonatomic, strong) NSString * _Nullable replicaKmsKeyID;

@end

/**
 
 */
@interface OOSEndEvent : CoreModel


@end

/**
 
 */
@interface OOSError : CoreModel


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable code;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable message;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 
 */
@interface OOSErrorDocument : CoreModel


/**
 The object key name to use when a 4XX class error occurs.
 */
@property (nonatomic, strong) NSString * _Nullable key;

@end

/**
 Container for key value pair that defines the criteria for the filter rule.
 */
@interface OOSFilterRule : CoreModel


/**
 Object key name prefix or suffix identifying one or more objects to which the filtering rule applies. Maximum prefix length can be up to 1,024 characters. Overlapping prefixes and suffixes are not supported. For more information, go to <a href="http://docs.OOS.amazon.com/Amazon/latest/dev/NotificationHowTo.html">Configuring Event Notifications</a> in the Amazon Simple Storage Service Developer Guide.
 */
@property (nonatomic, assign) OOSFilterRuleName name;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable value;

@end

/**
 
 */
@interface OOSGetBucketAccelerateConfigurationOutput : CoreModel


/**
 The accelerate configuration of the bucket.
 */
@property (nonatomic, assign) OOSBucketAccelerateStatus status;

/**
 A list of ips.
 */
@property (nonatomic, strong) OOSIPWhiteLists * _Nullable ipWhiteLists;

@end

/**
 
 */
@interface OOSGetBucketAccelerateConfigurationRequest : OOSRequest


/**
 Name of the bucket for which the accelerate configuration is retrieved.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSGetBucketAclOutput : CoreModel


/**
 A list of grants.
 */
@property (nonatomic, strong) NSArray<OOSGrant *> * _Nullable grants;

/**
 
 */
@property (nonatomic, strong) OOSOwner * _Nullable owner;

@end

/**
 
 */
@interface OOSGetBucketAclRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSGetBucketAnalyticsConfigurationOutput : CoreModel


/**
 The configuration and any analyses for the analytics filter.
 */
@property (nonatomic, strong) OOSAnalyticsConfiguration * _Nullable analyticsConfiguration;

@end

/**
 
 */
@interface OOSGetBucketAnalyticsConfigurationRequest : OOSRequest


/**
 The name of the bucket from which an analytics configuration is retrieved.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 The identifier used to represent an analytics configuration.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

@end

/**
 
 */
@interface OOSGetBucketCorsOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<OOSCORSRule *> * _Nullable CORSRules;

@end

/**
 
 */
@interface OOSGetBucketCorsRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSGetBucketEncryptionOutput : CoreModel


/**
 Container for server-side encryption configuration rules. Currently  supports one rule only.
 */
@property (nonatomic, strong) OOSServerSideEncryptionConfiguration * _Nullable serverSideEncryptionConfiguration;

@end

/**
 
 */
@interface OOSGetBucketEncryptionRequest : OOSRequest


/**
 The name of the bucket from which the server-side encryption configuration is retrieved.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSGetBucketInventoryConfigurationOutput : CoreModel


/**
 Specifies the inventory configuration.
 */
@property (nonatomic, strong) OOSInventoryConfiguration * _Nullable inventoryConfiguration;

@end

/**
 
 */
@interface OOSGetBucketInventoryConfigurationRequest : OOSRequest


/**
 The name of the bucket containing the inventory configuration to retrieve.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 The ID used to identify the inventory configuration.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

@end

/**
 
 */
@interface OOSGetBucketLifecycleConfigurationOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<OOSLifecycleRule *> * _Nullable rules;

@end

/**
 
 */
@interface OOSGetBucketLifecycleConfigurationRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSGetBucketLifecycleOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<OOSRule *> * _Nullable rules;

@end

/**
 
 */
@interface OOSGetBucketLifecycleRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 A standard MIME type describing the format of the object data.
 */
@property (nonatomic, strong) NSString * _Nullable contentType;

@end

/**
 
 */
@interface OOSGetBucketLoggingOutput : CoreModel


/**
 Container for logging information. Presence of this element indicates that logging is enabled. Parameters TargetBucket and TargetPrefix are required in this case.
 */
@property (nonatomic, strong) OOSLoggingEnabled * _Nullable loggingEnabled;

@end

/**
 
 */
@interface OOSGetBucketLoggingRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 A standard MIME type describing the format of the object data.
 */
@property (nonatomic, strong) NSString * _Nullable contentType;

@end

/**
 
 */
@interface OOSGetBucketMetricsConfigurationOutput : CoreModel


/**
 Specifies the metrics configuration.
 */
@property (nonatomic, strong) OOSMetricsConfiguration * _Nullable metricsConfiguration;

@end

/**
 
 */
@interface OOSGetBucketMetricsConfigurationRequest : OOSRequest


/**
 The name of the bucket containing the metrics configuration to retrieve.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 The ID used to identify the metrics configuration.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

@end

/**
 
 */
@interface OOSGetBucketNotificationConfigurationRequest : OOSRequest


/**
 Name of the bucket to get the notification configuration for.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSGetBucketPolicyOutput : CoreModel


/**
 The bucket policy as a JSON document.
 */
@property (nonatomic, strong) NSString * _Nullable policy;

@end

/**
 
 */
@interface OOSGetBucketPolicyRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSGetBucketReplicationOutput : CoreModel


/**
 Container for replication rules. You can add as many as 1,000 rules. Total replication configuration size can be up to 2 MB.
 */
@property (nonatomic, strong) OOSReplicationConfiguration * _Nullable replicationConfiguration;

@end

/**
 
 */
@interface OOSGetBucketReplicationRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSGetBucketRequestPaymentOutput : CoreModel


/**
 Specifies who pays for the download and request fees.
 */
@property (nonatomic, assign) OOSPayer payer;

@end

/**
 
 */
@interface OOSGetBucketRequestPaymentRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSGetBucketTaggingOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<OOSTag *> * _Nullable tagSet;

@end

/**
 
 */
@interface OOSGetBucketTaggingRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSGetBucketVersioningOutput : CoreModel


/**
 Specifies whether MFA delete is enabled in the bucket versioning configuration. This element is only returned if the bucket has been configured with MFA delete. If the bucket has never been so configured, this element is not returned.
 */
@property (nonatomic, assign) OOSMFADeleteStatus MFADelete;

/**
 The versioning state of the bucket.
 */
@property (nonatomic, assign) OOSBucketVersioningStatus status;

@end

/**
 
 */
@interface OOSGetBucketVersioningRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSGetBucketWebsiteOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) OOSErrorDocument * _Nullable errorDocument;

/**
 
 */
@property (nonatomic, strong) OOSIndexDocument * _Nullable indexDocument;

@end

/**
 
 */
@interface OOSGetBucketWebsiteRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 A standard MIME type describing the format of the object data.
 */
@property (nonatomic, strong) NSString * _Nullable contentType;

@end

/**
 
 */
@interface OOSGetObjectAclOutput : CoreModel


/**
 A list of grants.
 */
@property (nonatomic, strong) NSArray<OOSGrant *> * _Nullable grants;

/**
 
 */
@property (nonatomic, strong) OOSOwner * _Nullable owner;

/**
 If present, indicates that the requester was successfully charged for the request.
 */
@property (nonatomic, assign) OOSRequestCharged requestCharged;

@end

/**
 
 */
@interface OOSGetObjectAclRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 Confirms that the requester knows that she or he will be charged for the request. Bucket owners need not specify this parameter in their requests. Documentation on downloading objects from requester pays buckets can be found at http://docs.OOS.amazon.com/Amazon/latest/dev/ObjectsinRequesterPaysBuckets.html
 */
@property (nonatomic, assign) OOSRequestPayer requestPayer;

/**
 VersionId used to reference a specific version of the object.
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 
 */
@interface OOSGetObjectOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable acceptRanges;

/**
 Object data.
 */
@property (nonatomic, strong) id _Nullable body;

/**
 Specifies caching behavior along the request/reply chain.
 */
@property (nonatomic, strong) NSString * _Nullable cacheControl;

/**
 Specifies presentational information for the object.
 */
@property (nonatomic, strong) NSString * _Nullable contentDisposition;

/**
 Specifies what content encodings have been applied to the object and thus what decoding mechanisms must be applied to obtain the media-type referenced by the Content-Type header field.
 */
@property (nonatomic, strong) NSString * _Nullable contentEncoding;

/**
 The language the content is in.
 */
@property (nonatomic, strong) NSString * _Nullable contentLanguage;

/**
 Size of the body in bytes.
 */
@property (nonatomic, strong) NSNumber * _Nullable contentLength;

/**
 The portion of the object returned in the response.
 */
@property (nonatomic, strong) NSString * _Nullable contentRange;

/**
 A standard MIME type describing the format of the object data.
 */
@property (nonatomic, strong) NSString * _Nullable contentType;

/**
 Specifies whether the object retrieved was (true) or was not (false) a Delete Marker. If false, this response header does not appear in the response.
 */
@property (nonatomic, strong) NSNumber * _Nullable deleteMarker;

/**
 An ETag is an opaque identifier assigned by a web server to a specific version of a resource found at a URL
 */
@property (nonatomic, strong) NSString * _Nullable ETag;

/**
 If the object expiration is configured (see PUT Bucket lifecycle), the response includes this header. It includes the expiry-date and rule-id key value pairs providing object expiration information. The value of the rule-id is URL encoded.
 */
@property (nonatomic, strong) NSString * _Nullable expiration;

/**
 The date and time at which the object is no longer cacheable.
 */
@property (nonatomic, strong) NSDate * _Nullable expires;

/**
 Last modified date of the object
 */
@property (nonatomic, strong) NSDate * _Nullable lastModified;

/**
 A map of metadata to store with the object in .
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> * _Nullable metadata;

/**
 This is set to the number of metadata entries not returned in x-amz-meta headers. This can happen if you create metadata using an API like SOAP that supports more flexible metadata than the REST API. For example, using SOAP, you can create metadata whose values are not legal HTTP headers.
 */
@property (nonatomic, strong) NSNumber * _Nullable missingMeta;

/**
 The count of parts this object has.
 */
@property (nonatomic, strong) NSNumber * _Nullable partsCount;

/**
 
 */
@property (nonatomic, assign) OOSReplicationStatus replicationStatus;

/**
 If present, indicates that the requester was successfully charged for the request.
 */
@property (nonatomic, assign) OOSRequestCharged requestCharged;

/**
 Provides information about object restoration operation and expiration time of the restored object copy.
 */
@property (nonatomic, strong) NSString * _Nullable restore;

/**
 If server-side encryption with a customer-provided encryption key was requested, the response will include this header confirming the encryption algorithm used.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerAlgorithm;

/**
 If server-side encryption with a customer-provided encryption key was requested, the response will include this header to provide round trip message integrity verification of the customer-provided encryption key.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerKeyMD5;

/**
 If present, specifies the ID of the OOS Key Management Service (KMS) master encryption key that was used for the object.
 */
@property (nonatomic, strong) NSString * _Nullable SSEKMSKeyId;

/**
 The Server-side encryption algorithm used when storing this object in  (e.g., AES256, OOS:kms).
 */
@property (nonatomic, assign) OOSServerSideEncryption serverSideEncryption;

/**
 
 */
@property (nonatomic, assign) OOSStorageClass storageClass;

/**
 The number of tags, if any, on the object.
 */
@property (nonatomic, strong) NSNumber * _Nullable tagCount;

/**
 Version of the object.
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

/**
 If the bucket is configured as a website, redirects requests for this object to another object in the same bucket or to an external URL. Amazon  stores the value of this header in the object metadata.
 */
@property (nonatomic, strong) NSString * _Nullable websiteRedirectLocation;

/**
 设置bucket的数据位置。
 类型：key-value形式
 有效值：
 type=[ Local|Specified],location=[ ChengDu|ShenYa
 ng|...],scheduleStrategy=[ Allowed|NotAllowed]
 type=local表示就近写入本地。type= Specified表示指定
 位置。location表示指定的数据位置，可以填写多个，以
 逗号分隔。scheduleStrategy表示调度策略，是否允许
 OOS自动调度数据存储位置。
 */
@property (nonatomic, strong) NSString * _Nullable dataLocation;

/**
 获取对象的索引位置。
 类型：枚举
 有效值： ChengDu|ShenYang|...
 */
@property (nonatomic, strong) NSString * _Nullable metaDataLocation;

@end

/**
 
 */
@interface OOSGetObjectRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 Return the object only if its entity tag (ETag) is the same as the one specified, otherwise return a 412 (precondition failed).
 */
@property (nonatomic, strong) NSString * _Nullable ifMatch;

/**
 Return the object only if it has been modified since the specified time, otherwise return a 304 (not modified).
 */
@property (nonatomic, strong) NSDate * _Nullable ifModifiedSince;

/**
 Return the object only if its entity tag (ETag) is different from the one specified, otherwise return a 304 (not modified).
 */
@property (nonatomic, strong) NSString * _Nullable ifNoneMatch;

/**
 Return the object only if it has not been modified since the specified time, otherwise return a 412 (precondition failed).
 */
@property (nonatomic, strong) NSDate * _Nullable ifUnmodifiedSince;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 Part number of the object being read. This is a positive integer between 1 and 10,000. Effectively performs a 'ranged' GET request for the part specified. Useful for downloading just a part of an object.
 */
@property (nonatomic, strong) NSNumber * _Nullable partNumber;

/**
 Downloads the specified range bytes of an object. For more information about the HTTP Range header, go to http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.35.
 */
@property (nonatomic, strong) NSString * _Nullable range;

/**
 Confirms that the requester knows that she or he will be charged for the request. Bucket owners need not specify this parameter in their requests. Documentation on downloading objects from requester pays buckets can be found at http://docs.OOS.amazon.com/Amazon/latest/dev/ObjectsinRequesterPaysBuckets.html
 */
@property (nonatomic, assign) OOSRequestPayer requestPayer;

/**
 Sets the Cache-Control header of the response.
 */
@property (nonatomic, strong) NSString * _Nullable responseCacheControl;

/**
 Sets the Content-Disposition header of the response
 */
@property (nonatomic, strong) NSString * _Nullable responseContentDisposition;

/**
 Sets the Content-Encoding header of the response.
 */
@property (nonatomic, strong) NSString * _Nullable responseContentEncoding;

/**
 Sets the Content-Language header of the response.
 */
@property (nonatomic, strong) NSString * _Nullable responseContentLanguage;

/**
 Sets the Content-Type header of the response.
 */
@property (nonatomic, strong) NSString * _Nullable responseContentType;

/**
 Sets the Expires header of the response.
 */
@property (nonatomic, strong) NSDate * _Nullable responseExpires;

/**
 Specifies the algorithm to use to when encrypting the object (e.g., AES256).
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerAlgorithm;

/**
 Specifies the customer-provided encryption key for Amazon  to use in encrypting data. This value is used to store the object and then it is discarded; Amazon does not store the encryption key. The key must be appropriate for use with the algorithm specified in the x-amz-server-side​-encryption​-customer-algorithm header.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerKey;

/**
 Specifies the 128-bit MD5 digest of the encryption key according to RFC 1321. Amazon  uses this header for a message integrity check to ensure the encryption key was transmitted without error.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerKeyMD5;

/**
 VersionId used to reference a specific version of the object.
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 
 */
@interface OOSGetObjectTaggingOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<OOSTag *> * _Nullable tagSet;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 
 */
@interface OOSGetObjectTaggingRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 
 */
@interface OOSGetObjectTorrentOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) id _Nullable body;

/**
 If present, indicates that the requester was successfully charged for the request.
 */
@property (nonatomic, assign) OOSRequestCharged requestCharged;

@end

/**
 
 */
@interface OOSGetObjectTorrentRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 Confirms that the requester knows that she or he will be charged for the request. Bucket owners need not specify this parameter in their requests. Documentation on downloading objects from requester pays buckets can be found at http://docs.OOS.amazon.com/Amazon/latest/dev/ObjectsinRequesterPaysBuckets.html
 */
@property (nonatomic, assign) OOSRequestPayer requestPayer;

@end

/**
 
 */
@interface OOSGlacierJobParameters : CoreModel


/**
 Glacier retrieval tier at which the restore will be processed.
 */
@property (nonatomic, assign) OOSTier tier;

@end

/**
 
 */
@interface OOSGrant : CoreModel


/**
 
 */
@property (nonatomic, strong) OOSGrantee * _Nullable grantee;

/**
 Specifies the permission given to the grantee.
 */
@property (nonatomic, assign) OOSPermission permission;

@end

/**
 
 */
@interface OOSGrantee : CoreModel


/**
 Screen name of the grantee.
 */
@property (nonatomic, strong) NSString * _Nullable displayName;

/**
 Email address of the grantee.
 */
@property (nonatomic, strong) NSString * _Nullable emailAddress;

/**
 The canonical user ID of the grantee.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

/**
 Type of grantee
 */
@property (nonatomic, assign) OOSTypes types;

/**
 URI of the grantee group.
 */
@property (nonatomic, strong) NSString * _Nullable URI;

@end

/**
 
 */
@interface OOSHeadBucketRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSHeadObjectOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable acceptRanges;

/**
 Specifies caching behavior along the request/reply chain.
 */
@property (nonatomic, strong) NSString * _Nullable cacheControl;

/**
 Specifies presentational information for the object.
 */
@property (nonatomic, strong) NSString * _Nullable contentDisposition;

/**
 Specifies what content encodings have been applied to the object and thus what decoding mechanisms must be applied to obtain the media-type referenced by the Content-Type header field.
 */
@property (nonatomic, strong) NSString * _Nullable contentEncoding;

/**
 The language the content is in.
 */
@property (nonatomic, strong) NSString * _Nullable contentLanguage;

/**
 Size of the body in bytes.
 */
@property (nonatomic, strong) NSNumber * _Nullable contentLength;

/**
 A standard MIME type describing the format of the object data.
 */
@property (nonatomic, strong) NSString * _Nullable contentType;

/**
 Specifies whether the object retrieved was (true) or was not (false) a Delete Marker. If false, this response header does not appear in the response.
 */
@property (nonatomic, strong) NSNumber * _Nullable deleteMarker;

/**
 An ETag is an opaque identifier assigned by a web server to a specific version of a resource found at a URL
 */
@property (nonatomic, strong) NSString * _Nullable ETag;

/**
 If the object expiration is configured (see PUT Bucket lifecycle), the response includes this header. It includes the expiry-date and rule-id key value pairs providing object expiration information. The value of the rule-id is URL encoded.
 */
@property (nonatomic, strong) NSString * _Nullable expiration;

/**
 The date and time at which the object is no longer cacheable.
 */
@property (nonatomic, strong) NSDate * _Nullable expires;

/**
 Last modified date of the object
 */
@property (nonatomic, strong) NSDate * _Nullable lastModified;

/**
 A map of metadata to store with the object in .
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> * _Nullable metadata;

/**
 This is set to the number of metadata entries not returned in x-amz-meta headers. This can happen if you create metadata using an API like SOAP that supports more flexible metadata than the REST API. For example, using SOAP, you can create metadata whose values are not legal HTTP headers.
 */
@property (nonatomic, strong) NSNumber * _Nullable missingMeta;

/**
 The count of parts this object has.
 */
@property (nonatomic, strong) NSNumber * _Nullable partsCount;

/**
 
 */
@property (nonatomic, assign) OOSReplicationStatus replicationStatus;

/**
 If present, indicates that the requester was successfully charged for the request.
 */
@property (nonatomic, assign) OOSRequestCharged requestCharged;

/**
 Provides information about object restoration operation and expiration time of the restored object copy.
 */
@property (nonatomic, strong) NSString * _Nullable restore;

/**
 If server-side encryption with a customer-provided encryption key was requested, the response will include this header confirming the encryption algorithm used.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerAlgorithm;

/**
 If server-side encryption with a customer-provided encryption key was requested, the response will include this header to provide round trip message integrity verification of the customer-provided encryption key.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerKeyMD5;

/**
 If present, specifies the ID of the OOS Key Management Service (KMS) master encryption key that was used for the object.
 */
@property (nonatomic, strong) NSString * _Nullable SSEKMSKeyId;

/**
 The Server-side encryption algorithm used when storing this object in  (e.g., AES256, OOS:kms).
 */
@property (nonatomic, assign) OOSServerSideEncryption serverSideEncryption;

/**
 
 */
@property (nonatomic, assign) OOSStorageClass storageClass;

/**
 Version of the object.
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

/**
 If the bucket is configured as a website, redirects requests for this object to another object in the same bucket or to an external URL. Amazon  stores the value of this header in the object metadata.
 */
@property (nonatomic, strong) NSString * _Nullable websiteRedirectLocation;

@property (nonatomic, strong) NSString * _Nullable dataLocation;

@property (nonatomic, strong) NSString * _Nullable metadataLocation;


@end

/**
 
 */
@interface OOSHeadObjectRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 Return the object only if its entity tag (ETag) is the same as the one specified, otherwise return a 412 (precondition failed).
 */
@property (nonatomic, strong) NSString * _Nullable ifMatch;

/**
 Return the object only if it has been modified since the specified time, otherwise return a 304 (not modified).
 */
@property (nonatomic, strong) NSDate * _Nullable ifModifiedSince;

/**
 Return the object only if its entity tag (ETag) is different from the one specified, otherwise return a 304 (not modified).
 */
@property (nonatomic, strong) NSString * _Nullable ifNoneMatch;

/**
 Return the object only if it has not been modified since the specified time, otherwise return a 412 (precondition failed).
 */
@property (nonatomic, strong) NSDate * _Nullable ifUnmodifiedSince;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 Part number of the object being read. This is a positive integer between 1 and 10,000. Effectively performs a 'ranged' HEAD request for the part specified. Useful querying about the size of the part and the number of parts in this object.
 */
@property (nonatomic, strong) NSNumber * _Nullable partNumber;

/**
 Downloads the specified range bytes of an object. For more information about the HTTP Range header, go to http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.35.
 */
@property (nonatomic, strong) NSString * _Nullable range;

/**
 Confirms that the requester knows that she or he will be charged for the request. Bucket owners need not specify this parameter in their requests. Documentation on downloading objects from requester pays buckets can be found at http://docs.OOS.amazon.com/Amazon/latest/dev/ObjectsinRequesterPaysBuckets.html
 */
@property (nonatomic, assign) OOSRequestPayer requestPayer;

/**
 Specifies the algorithm to use to when encrypting the object (e.g., AES256).
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerAlgorithm;

/**
 Specifies the customer-provided encryption key for Amazon  to use in encrypting data. This value is used to store the object and then it is discarded; Amazon does not store the encryption key. The key must be appropriate for use with the algorithm specified in the x-amz-server-side​-encryption​-customer-algorithm header.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerKey;

/**
 Specifies the 128-bit MD5 digest of the encryption key according to RFC 1321. Amazon  uses this header for a message integrity check to ensure the encryption key was transmitted without error.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerKeyMD5;

/**
 VersionId used to reference a specific version of the object.
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 
 */
@interface OOSIndexDocument : CoreModel


/**
 A suffix that is appended to a request that is for a directory on the website endpoint (e.g. if the suffix is index.html and you make a request to samplebucket/images/ the data that is returned will be for the object with the key name images/index.html) The suffix must not be empty and must not include a slash character.
 */
@property (nonatomic, strong) NSString * _Nullable suffix;

@end

/**
 
 */
@interface OOSInitiator : CoreModel


/**
 Name of the Principal.
 */
@property (nonatomic, strong) NSString * _Nullable displayName;

/**
 If the principal is an OOS account, it provides the Canonical User ID. If the principal is an IAM User, it provides a user ARN value.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

@end

/**
 Describes the serialization format of the object.
 */
@interface OOSInputSerialization : CoreModel


/**
 Describes the serialization of a CSV-encoded object.
 */
@property (nonatomic, strong) OOSCSVInput * _Nullable CSV;

/**
 Specifies object's compression format. Valid values: NONE, GZIP. Default Value: NONE.
 */
@property (nonatomic, assign) OOSCompressionType compressionType;

/**
 Specifies JSON as object's input serialization format.
 */
@property (nonatomic, strong) OOSJSONInput * _Nullable JSON;

@end

/**
 
 */
@interface OOSInventoryConfiguration : CoreModel


/**
 Contains information about where to publish the inventory results.
 */
@property (nonatomic, strong) OOSInventoryDestination * _Nullable destination;

/**
 Specifies an inventory filter. The inventory only includes objects that meet the filter's criteria.
 */
@property (nonatomic, strong) OOSInventoryFilter * _Nullable filter;

/**
 The ID used to identify the inventory configuration.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

/**
 Specifies which object version(s) to included in the inventory results.
 */
@property (nonatomic, assign) OOSInventoryIncludedObjectVersions includedObjectVersions;

/**
 Specifies whether the inventory is enabled or disabled.
 */
@property (nonatomic, strong) NSNumber * _Nullable isEnabled;

/**
 Contains the optional fields that are included in the inventory results.
 */
@property (nonatomic, strong) NSArray<NSString *> * _Nullable optionalFields;

/**
 Specifies the schedule for generating inventory results.
 */
@property (nonatomic, strong) OOSInventorySchedule * _Nullable schedule;

@end

/**
 
 */
@interface OOSInventoryDestination : CoreModel


/**
 Contains the bucket name, file format, bucket owner (optional), and prefix (optional) where inventory results are published.
 */
@property (nonatomic, strong) OOSInventoryBucketDestination * _Nullable BucketDestination;

@end

/**
 Contains the type of server-side encryption used to encrypt the inventory results.
 */
@interface OOSInventoryEncryption : CoreModel


/**
 Specifies the use of SSE-KMS to encrypt delievered Inventory reports.
 */
@property (nonatomic, strong) OOSSSEKMS * _Nullable SSEKMS;

/**
 Specifies the use of SSE- to encrypt delievered Inventory reports.
 */
@property (nonatomic, strong) OOSSSE * _Nullable SSE;

@end

/**
 
 */
@interface OOSInventoryFilter : CoreModel


/**
 The prefix that an object must have to be included in the inventory results.
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

@end

/**
 
 */
@interface OOSInventoryBucketDestination : CoreModel


/**
 The ID of the account that owns the destination bucket.
 */
@property (nonatomic, strong) NSString * _Nullable accountId;

/**
 The Amazon resource name (ARN) of the bucket where inventory results will be published.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 Contains the type of server-side encryption used to encrypt the inventory results.
 */
@property (nonatomic, strong) OOSInventoryEncryption * _Nullable encryption;

/**
 Specifies the output format of the inventory results.
 */
@property (nonatomic, assign) OOSInventoryFormat format;

/**
 The prefix that is prepended to all inventory results.
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

@end

/**
 
 */
@interface OOSInventorySchedule : CoreModel


/**
 Specifies how frequently inventory results are produced.
 */
@property (nonatomic, assign) OOSInventoryFrequency frequency;

@end

/**
 
 */
@interface OOSJSONInput : CoreModel


/**
 The type of JSON. Valid values: Document, Lines.
 */
@property (nonatomic, assign) OOSJSONType types;

@end

/**
 
 */
@interface OOSJSONOutput : CoreModel


/**
 The value used to separate individual records in the output.
 */
@property (nonatomic, strong) NSString * _Nullable recordDelimiter;

@end

/**
 Container for specifying the OOS Lambda notification configuration.
 Required parameters: [LambdaFunctionArn, Events]
 */
@interface OOSLambdaFunctionConfiguration : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<NSString *> * _Nullable events;

/**
 Container for object key name filtering rules. For information about key name filtering, go to <a href="http://docs.OOS.amazon.com/Amazon/latest/dev/NotificationHowTo.html">Configuring Event Notifications</a> in the Amazon Simple Storage Service Developer Guide.
 */
@property (nonatomic, strong) OOSNotificationConfigurationFilter * _Nullable filter;

/**
 Optional unique identifier for configurations in a notification configuration. If you don't provide one, Amazon  will assign an ID.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

/**
 Lambda cloud function ARN that Amazon  can invoke when it detects events of the specified type.
 */
@property (nonatomic, strong) NSString * _Nullable lambdaFunctionArn;

@end

/**
 
 */
@interface OOSLifecycleConfiguration : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<OOSRule *> * _Nullable rules;

@end

/**
 
 */
@interface OOSLifecycleExpiration : CoreModel


/**
 Indicates at what date the object is to be moved or deleted. Should be in GMT ISO 8601 Format.
 */
@property (nonatomic, strong) NSDate * _Nullable date;

/**
 Indicates the lifetime, in days, of the objects that are subject to the rule. The value must be a non-zero positive integer.
 */
@property (nonatomic, strong) NSNumber * _Nullable days;

/**
 Indicates whether Amazon  will remove a delete marker with no noncurrent versions. If set to true, the delete marker will be expired; if set to false the policy takes no action. This cannot be specified with Days or Date in a Lifecycle Expiration Policy.
 */
@property (nonatomic, strong) NSNumber * _Nullable expiredObjectDeleteMarker;

@end

/**
 
 */
@interface OOSLifecycleRule : CoreModel


/**
 Specifies the days since the initiation of an Incomplete Multipart Upload that Lifecycle will wait before permanently removing all parts of the upload.
 */
@property (nonatomic, strong) OOSAbortIncompleteMultipartUpload * _Nullable abortIncompleteMultipartUpload;

/**
 
 */
@property (nonatomic, strong) OOSLifecycleExpiration * _Nullable expiration;

/**
 The Filter is used to identify objects that a Lifecycle Rule applies to. A Filter must have exactly one of Prefix, Tag, or And specified.
 */
@property (nonatomic, strong) OOSLifecycleRuleFilter * _Nullable filter;

/**
 Unique identifier for the rule. The value cannot be longer than 255 characters.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

/**
 Specifies when noncurrent object versions expire. Upon expiration, Amazon  permanently deletes the noncurrent object versions. You set this lifecycle configuration action on a bucket that has versioning enabled (or suspended) to request that Amazon  delete noncurrent object versions at a specific period in the object's lifetime.
 */
@property (nonatomic, strong) OOSNoncurrentVersionExpiration * _Nullable noncurrentVersionExpiration;

/**
 
 */
@property (nonatomic, strong) NSArray<OOSNoncurrentVersionTransition *> * _Nullable noncurrentVersionTransitions;

/**
 Prefix identifying one or more objects to which the rule applies. This is deprecated; use Filter instead.
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

/**
 If 'Enabled', the rule is currently being applied. If 'Disabled', the rule is not currently being applied.
 */
@property (nonatomic, assign) OOSExpirationStatus status;

/**
 
 */
@property (nonatomic, strong) NSArray<OOSTransition *> * _Nullable transitions;

@end

/**
 This is used in a Lifecycle Rule Filter to apply a logical AND to two or more predicates. The Lifecycle Rule will apply to any object matching all of the predicates configured inside the And operator.
 */
@interface OOSLifecycleRuleAndOperator : CoreModel


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

/**
 All of these tags must exist in the object's tag set in order for the rule to apply.
 */
@property (nonatomic, strong) NSArray<OOSTag *> * _Nullable tags;

@end

/**
 The Filter is used to identify objects that a Lifecycle Rule applies to. A Filter must have exactly one of Prefix, Tag, or And specified.
 */
@interface OOSLifecycleRuleFilter : CoreModel


/**
 This is used in a Lifecycle Rule Filter to apply a logical AND to two or more predicates. The Lifecycle Rule will apply to any object matching all of the predicates configured inside the And operator.
 */
@property (nonatomic, strong) OOSLifecycleRuleAndOperator * _Nullable AND;

/**
 Prefix identifying one or more objects to which the rule applies.
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

/**
 This tag must exist in the object's tag set in order for the rule to apply.
 */
@property (nonatomic, strong) OOSTag * _Nullable tag;

@end

/**
 
 */
@interface OOSListBucketAnalyticsConfigurationsOutput : CoreModel


/**
 The list of analytics configurations for a bucket.
 */
@property (nonatomic, strong) NSArray<OOSAnalyticsConfiguration *> * _Nullable analyticsConfigurationList;

/**
 The ContinuationToken that represents where this request began.
 */
@property (nonatomic, strong) NSString * _Nullable continuationToken;

/**
 Indicates whether the returned list of analytics configurations is complete. A value of true indicates that the list is not complete and the NextContinuationToken will be provided for a subsequent request.
 */
@property (nonatomic, strong) NSNumber * _Nullable isTruncated;

/**
 NextContinuationToken is sent when isTruncated is true, which indicates that there are more analytics configurations to list. The next request must include this NextContinuationToken. The token is obfuscated and is not a usable value.
 */
@property (nonatomic, strong) NSString * _Nullable nextContinuationToken;

@end

/**
 
 */
@interface OOSListBucketAnalyticsConfigurationsRequest : OOSRequest


/**
 The name of the bucket from which analytics configurations are retrieved.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 The ContinuationToken that represents a placeholder from where this request should begin.
 */
@property (nonatomic, strong) NSString * _Nullable continuationToken;

@end

/**
 
 */
@interface OOSListBucketInventoryConfigurationsOutput : CoreModel


/**
 If sent in the request, the marker that is used as a starting point for this inventory configuration list response.
 */
@property (nonatomic, strong) NSString * _Nullable continuationToken;

/**
 The list of inventory configurations for a bucket.
 */
@property (nonatomic, strong) NSArray<OOSInventoryConfiguration *> * _Nullable inventoryConfigurationList;

/**
 Indicates whether the returned list of inventory configurations is truncated in this response. A value of true indicates that the list is truncated.
 */
@property (nonatomic, strong) NSNumber * _Nullable isTruncated;

/**
 The marker used to continue this inventory configuration listing. Use the NextContinuationToken from this response to continue the listing in a subsequent request. The continuation token is an opaque value that Amazon  understands.
 */
@property (nonatomic, strong) NSString * _Nullable nextContinuationToken;

@end

/**
 
 */
@interface OOSListBucketInventoryConfigurationsRequest : OOSRequest


/**
 The name of the bucket containing the inventory configurations to retrieve.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 The marker used to continue an inventory configuration listing that has been truncated. Use the NextContinuationToken from a previously truncated list response to continue the listing. The continuation token is an opaque value that Amazon  understands.
 */
@property (nonatomic, strong) NSString * _Nullable continuationToken;

@end

/**
 
 */
@interface OOSListBucketMetricsConfigurationsOutput : CoreModel


/**
 The marker that is used as a starting point for this metrics configuration list response. This value is present if it was sent in the request.
 */
@property (nonatomic, strong) NSString * _Nullable continuationToken;

/**
 Indicates whether the returned list of metrics configurations is complete. A value of true indicates that the list is not complete and the NextContinuationToken will be provided for a subsequent request.
 */
@property (nonatomic, strong) NSNumber * _Nullable isTruncated;

/**
 The list of metrics configurations for a bucket.
 */
@property (nonatomic, strong) NSArray<OOSMetricsConfiguration *> * _Nullable metricsConfigurationList;

/**
 The marker used to continue a metrics configuration listing that has been truncated. Use the NextContinuationToken from a previously truncated list response to continue the listing. The continuation token is an opaque value that Amazon  understands.
 */
@property (nonatomic, strong) NSString * _Nullable nextContinuationToken;

@end

/**
 
 */
@interface OOSListBucketMetricsConfigurationsRequest : OOSRequest


/**
 The name of the bucket containing the metrics configurations to retrieve.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 The marker that is used to continue a metrics configuration listing that has been truncated. Use the NextContinuationToken from a previously truncated list response to continue the listing. The continuation token is an opaque value that Amazon  understands.
 */
@property (nonatomic, strong) NSString * _Nullable continuationToken;

@end

/**
 
 */
@interface OOSListBucketsOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<OOSBucket *> * _Nullable buckets;

/**
 
 */
@property (nonatomic, strong) OOSOwner * _Nullable owner;

@end

/**
 
 */
@interface OOSListMultipartUploadsOutput : CoreModel


/**
 Name of the bucket to which the multipart upload was initiated.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSArray<OOSCommonPrefix *> * _Nullable commonPrefixes;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable delimiter;

/**
 Encoding type used by Amazon  to encode object keys in the response.
 */
@property (nonatomic, assign) OOSEncodingType encodingType;

/**
 Indicates whether the returned list of multipart uploads is truncated. A value of true indicates that the list was truncated. The list can be truncated if the number of multipart uploads exceeds the limit allowed or specified by max uploads.
 */
@property (nonatomic, strong) NSNumber * _Nullable isTruncated;

/**
 The key at or after which the listing began.
 */
@property (nonatomic, strong) NSString * _Nullable keyMarker;

/**
 Maximum number of multipart uploads that could have been included in the response.
 */
@property (nonatomic, strong) NSNumber * _Nullable maxUploads;

/**
 When a list is truncated, this element specifies the value that should be used for the key-marker request parameter in a subsequent request.
 */
@property (nonatomic, strong) NSString * _Nullable nextKeyMarker;

/**
 When a list is truncated, this element specifies the value that should be used for the upload-id-marker request parameter in a subsequent request.
 */
@property (nonatomic, strong) NSString * _Nullable nextUploadIdMarker;

/**
 When a prefix is provided in the request, this field contains the specified prefix. The result contains only keys starting with the specified prefix.
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

/**
 Upload ID after which listing began.
 */
@property (nonatomic, strong) NSString * _Nullable uploadIdMarker;

/**
 
 */
@property (nonatomic, strong) NSArray<OOSMultipartUpload *> * _Nullable uploads;

@end

/**
 
 */
@interface OOSListMultipartUploadsRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 Character you use to group keys.
 */
@property (nonatomic, strong) NSString * _Nullable delimiter;

/**
 Requests Amazon  to encode the object keys in the response and specifies the encoding method to use. An object key may contain any Unicode character; however, XML 1.0 parser cannot parse some characters, such as characters with an ASCII value from 0 to 10. For characters that are not supported in XML 1.0, you can add this parameter to request that Amazon  encode the keys in the response.
 */
@property (nonatomic, assign) OOSEncodingType encodingType;

/**
 Together with upload-id-marker, this parameter specifies the multipart upload after which listing should begin.
 */
@property (nonatomic, strong) NSString * _Nullable keyMarker;

/**
 Sets the maximum number of multipart uploads, from 1 to 1,000, to return in the response body. 1,000 is the maximum number of uploads that can be returned in a response.
 */
@property (nonatomic, strong) NSNumber * _Nullable maxUploads;

/**
 Lists in-progress uploads only for those keys that begin with the specified prefix.
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

/**
 Together with key-marker, specifies the multipart upload after which listing should begin. If key-marker is not specified, the upload-id-marker parameter is ignored.
 */
@property (nonatomic, strong) NSString * _Nullable uploadIdMarker;

@end

/**
 
 */
@interface OOSListObjectVersionsOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<OOSCommonPrefix *> * _Nullable commonPrefixes;

/**
 
 */
@property (nonatomic, strong) NSArray<OOSDeleteMarkerEntry *> * _Nullable deleteMarkers;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable delimiter;

/**
 Encoding type used by Amazon  to encode object keys in the response.
 */
@property (nonatomic, assign) OOSEncodingType encodingType;

/**
 A flag that indicates whether or not Amazon  returned all of the results that satisfied the search criteria. If your results were truncated, you can make a follow-up paginated request using the NextKeyMarker and NextVersionIdMarker response parameters as a starting place in another request to return the rest of the results.
 */
@property (nonatomic, strong) NSNumber * _Nullable isTruncated;

/**
 Marks the last Key returned in a truncated response.
 */
@property (nonatomic, strong) NSString * _Nullable keyMarker;

/**
 
 */
@property (nonatomic, strong) NSNumber * _Nullable maxKeys;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable name;

/**
 Use this value for the key marker request parameter in a subsequent request.
 */
@property (nonatomic, strong) NSString * _Nullable nextKeyMarker;

/**
 Use this value for the next version id marker parameter in a subsequent request.
 */
@property (nonatomic, strong) NSString * _Nullable nextVersionIdMarker;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable versionIdMarker;

/**
 
 */
@property (nonatomic, strong) NSArray<OOSObjectVersion *> * _Nullable versions;

@end

/**
 
 */
@interface OOSListObjectVersionsRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 A delimiter is a character you use to group keys.
 */
@property (nonatomic, strong) NSString * _Nullable delimiter;

/**
 Requests Amazon  to encode the object keys in the response and specifies the encoding method to use. An object key may contain any Unicode character; however, XML 1.0 parser cannot parse some characters, such as characters with an ASCII value from 0 to 10. For characters that are not supported in XML 1.0, you can add this parameter to request that Amazon  encode the keys in the response.
 */
@property (nonatomic, assign) OOSEncodingType encodingType;

/**
 Specifies the key to start with when listing objects in a bucket.
 */
@property (nonatomic, strong) NSString * _Nullable keyMarker;

/**
 Sets the maximum number of keys returned in the response. The response might contain fewer keys but will never contain more.
 */
@property (nonatomic, strong) NSNumber * _Nullable maxKeys;

/**
 Limits the response to keys that begin with the specified prefix.
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

/**
 Specifies the object version you want to start listing from.
 */
@property (nonatomic, strong) NSString * _Nullable versionIdMarker;

@end

/**
 
 */
@interface OOSListObjectsOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<OOSCommonPrefix *> * _Nullable commonPrefixes;

/**
 
 */
@property (nonatomic, strong) NSArray<OOSObject *> * _Nullable contents;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable delimiter;

/**
 Encoding type used by Amazon  to encode object keys in the response.
 */
@property (nonatomic, assign) OOSEncodingType encodingType;

/**
 A flag that indicates whether or not Amazon  returned all of the results that satisfied the search criteria.
 */
@property (nonatomic, strong) NSNumber * _Nullable isTruncated;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable marker;

/**
 
 */
@property (nonatomic, strong) NSNumber * _Nullable maxKeys;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable name;

/**
 When response is truncated (the IsTruncated element value in the response is true), you can use the key name in this field as marker in the subsequent request to get next set of objects. Amazon  lists objects in alphabetical order Note: This element is returned only if you have delimiter request parameter specified. If response does not include the NextMaker and it is truncated, you can use the value of the last Key in the response as the marker in the subsequent request to get the next set of object keys.
 */
@property (nonatomic, strong) NSString * _Nullable nextMarker;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

@end

/**
 
 */
@interface OOSListObjectsRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 A delimiter is a character you use to group keys.
 */
@property (nonatomic, strong) NSString * _Nullable delimiter;

/**
 Requests Amazon  to encode the object keys in the response and specifies the encoding method to use. An object key may contain any Unicode character; however, XML 1.0 parser cannot parse some characters, such as characters with an ASCII value from 0 to 10. For characters that are not supported in XML 1.0, you can add this parameter to request that Amazon  encode the keys in the response.
 */
@property (nonatomic, assign) OOSEncodingType encodingType;

/**
 Specifies the key to start with when listing objects in a bucket.
 */
@property (nonatomic, strong) NSString * _Nullable marker;

/**
 Sets the maximum number of keys returned in the response. The response might contain fewer keys but will never contain more.
 */
@property (nonatomic, strong) NSNumber * _Nullable maxKeys;

/**
 Limits the response to keys that begin with the specified prefix.
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

/**
 Confirms that the requester knows that she or he will be charged for the list objects request. Bucket owners need not specify this parameter in their requests.
 */
@property (nonatomic, assign) OOSRequestPayer requestPayer;

@end

/**
 
 */
@interface OOSListObjectsV2Output : CoreModel


/**
 CommonPrefixes contains all (if there are any) keys between Prefix and the next occurrence of the string specified by delimiter
 */
@property (nonatomic, strong) NSArray<OOSCommonPrefix *> * _Nullable commonPrefixes;

/**
 Metadata about each object returned.
 */
@property (nonatomic, strong) NSArray<OOSObject *> * _Nullable contents;

/**
 ContinuationToken indicates Amazon  that the list is being continued on this bucket with a token. ContinuationToken is obfuscated and is not a real key
 */
@property (nonatomic, strong) NSString * _Nullable continuationToken;

/**
 A delimiter is a character you use to group keys.
 */
@property (nonatomic, strong) NSString * _Nullable delimiter;

/**
 Encoding type used by Amazon  to encode object keys in the response.
 */
@property (nonatomic, assign) OOSEncodingType encodingType;

/**
 A flag that indicates whether or not Amazon  returned all of the results that satisfied the search criteria.
 */
@property (nonatomic, strong) NSNumber * _Nullable isTruncated;

/**
 KeyCount is the number of keys returned with this request. KeyCount will always be less than equals to MaxKeys field. Say you ask for 50 keys, your result will include less than equals 50 keys
 */
@property (nonatomic, strong) NSNumber * _Nullable keyCount;

/**
 Sets the maximum number of keys returned in the response. The response might contain fewer keys but will never contain more.
 */
@property (nonatomic, strong) NSNumber * _Nullable maxKeys;

/**
 Name of the bucket to list.
 */
@property (nonatomic, strong) NSString * _Nullable name;

/**
 NextContinuationToken is sent when isTruncated is true which means there are more keys in the bucket that can be listed. The next list requests to Amazon  can be continued with this NextContinuationToken. NextContinuationToken is obfuscated and is not a real key
 */
@property (nonatomic, strong) NSString * _Nullable nextContinuationToken;

/**
 Limits the response to keys that begin with the specified prefix.
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

/**
 StartAfter is where you want Amazon  to start listing from. Amazon  starts listing after this specified key. StartAfter can be any key in the bucket
 */
@property (nonatomic, strong) NSString * _Nullable startAfter;

@end

/**
 
 */
@interface OOSListObjectsV2Request : OOSRequest


/**
 Name of the bucket to list.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 ContinuationToken indicates Amazon  that the list is being continued on this bucket with a token. ContinuationToken is obfuscated and is not a real key
 */
@property (nonatomic, strong) NSString * _Nullable continuationToken;

/**
 A delimiter is a character you use to group keys.
 */
@property (nonatomic, strong) NSString * _Nullable delimiter;

/**
 Encoding type used by Amazon  to encode object keys in the response.
 */
@property (nonatomic, assign) OOSEncodingType encodingType;

/**
 The owner field is not present in listV2 by default, if you want to return owner field with each key in the result then set the fetch owner field to true
 */
@property (nonatomic, strong) NSNumber * _Nullable fetchOwner;

/**
 Sets the maximum number of keys returned in the response. The response might contain fewer keys but will never contain more.
 */
@property (nonatomic, strong) NSNumber * _Nullable maxKeys;

/**
 Limits the response to keys that begin with the specified prefix.
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

/**
 Confirms that the requester knows that she or he will be charged for the list objects request in V2 style. Bucket owners need not specify this parameter in their requests.
 */
@property (nonatomic, assign) OOSRequestPayer requestPayer;

/**
 StartAfter is where you want Amazon  to start listing from. Amazon  starts listing after this specified key. StartAfter can be any key in the bucket
 */
@property (nonatomic, strong) NSString * _Nullable startAfter;

@end

/**
 
 */
@interface OOSListPartsOutput : CoreModel


/**
 Date when multipart upload will become eligible for abort operation by lifecycle.
 */
@property (nonatomic, strong) NSDate * _Nullable abortDate;

/**
 Id of the lifecycle rule that makes a multipart upload eligible for abort operation.
 */
@property (nonatomic, strong) NSString * _Nullable abortRuleId;

/**
 Name of the bucket to which the multipart upload was initiated.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 Identifies who initiated the multipart upload.
 */
@property (nonatomic, strong) OOSInitiator * _Nullable initiator;

/**
 Indicates whether the returned list of parts is truncated.
 */
@property (nonatomic, strong) NSNumber * _Nullable isTruncated;

/**
 Object key for which the multipart upload was initiated.
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 Maximum number of parts that were allowed in the response.
 */
@property (nonatomic, strong) NSNumber * _Nullable maxParts;

/**
 When a list is truncated, this element specifies the last part in the list, as well as the value to use for the part-number-marker request parameter in a subsequent request.
 */
@property (nonatomic, strong) NSNumber * _Nullable nextPartNumberMarker;

/**
 
 */
@property (nonatomic, strong) OOSOwner * _Nullable owner;

/**
 Part number after which listing begins.
 */
@property (nonatomic, strong) NSNumber * _Nullable partNumberMarker;

/**
 
 */
@property (nonatomic, strong) NSArray<OOSPart *> * _Nullable parts;

/**
 If present, indicates that the requester was successfully charged for the request.
 */
@property (nonatomic, assign) OOSRequestCharged requestCharged;

/**
 The class of storage used to store the object.
 */
@property (nonatomic, assign) OOSStorageClass storageClass;

/**
 Upload ID identifying the multipart upload whose parts are being listed.
 */
@property (nonatomic, strong) NSString * _Nullable uploadId;

@end

/**
 
 */
@interface OOSListPartsRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 Sets the maximum number of parts to return.
 */
@property (nonatomic, strong) NSNumber * _Nullable maxParts;

/**
 Specifies the part after which listing should begin. Only parts with higher part numbers will be listed.
 */
@property (nonatomic, strong) NSNumber * _Nullable partNumberMarker;

/**
 Confirms that the requester knows that she or he will be charged for the request. Bucket owners need not specify this parameter in their requests. Documentation on downloading objects from requester pays buckets can be found at http://docs.OOS.amazon.com/Amazon/latest/dev/ObjectsinRequesterPaysBuckets.html
 */
@property (nonatomic, assign) OOSRequestPayer requestPayer;

/**
 Upload ID identifying the multipart upload whose parts are being listed.
 */
@property (nonatomic, strong) NSString * _Nullable uploadId;

@end

/**
 Container for logging information. Presence of this element indicates that logging is enabled. Parameters TargetBucket and TargetPrefix are required in this case.
 Required parameters: [TargetBucket, TargetPrefix]
 */
@interface OOSLoggingEnabled : CoreModel


/**
 Specifies the bucket where you want Amazon  to store server access logs. You can have your logs delivered to any bucket that you own, including the same bucket that is being logged. You can also configure multiple buckets to deliver their logs to the same target bucket. In this case you should choose a different TargetPrefix for each source bucket so that the delivered log files can be distinguished by key.
 */
@property (nonatomic, strong) NSString * _Nullable targetBucket;

/**
 This element lets you specify a prefix for the keys that the log files will be stored under.
 */
@property (nonatomic, strong) NSString * _Nullable targetPrefix;

@end

/**
 A metadata key-value pair to store with an object.
 */
@interface OOSMetadataEntry : CoreModel


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable name;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable value;

@end

/**
 
 */
@interface OOSMetricsAndOperator : CoreModel


/**
 The prefix used when evaluating an AND predicate.
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

/**
 The list of tags used when evaluating an AND predicate.
 */
@property (nonatomic, strong) NSArray<OOSTag *> * _Nullable tags;

@end

/**
 
 */
@interface OOSMetricsConfiguration : CoreModel


/**
 Specifies a metrics configuration filter. The metrics configuration will only include objects that meet the filter's criteria. A filter must be a prefix, a tag, or a conjunction (MetricsAndOperator).
 */
@property (nonatomic, strong) OOSMetricsFilter * _Nullable filter;

/**
 The ID used to identify the metrics configuration.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

@end

/**
 
 */
@interface OOSMetricsFilter : CoreModel


/**
 A conjunction (logical AND) of predicates, which is used in evaluating a metrics filter. The operator must have at least two predicates, and an object must match all of the predicates in order for the filter to apply.
 */
@property (nonatomic, strong) OOSMetricsAndOperator * _Nullable AND;

/**
 The prefix used when evaluating a metrics filter.
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

/**
 The tag used when evaluating a metrics filter.
 */
@property (nonatomic, strong) OOSTag * _Nullable tag;

@end

/**
 
 */
@interface OOSMultipartUpload : CoreModel


/**
 Date and time at which the multipart upload was initiated.
 */
@property (nonatomic, strong) NSDate * _Nullable initiated;

/**
 Identifies who initiated the multipart upload.
 */
@property (nonatomic, strong) OOSInitiator * _Nullable initiator;

/**
 Key of the object for which the multipart upload was initiated.
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 
 */
@property (nonatomic, strong) OOSOwner * _Nullable owner;

/**
 The class of storage used to store the object.
 */
@property (nonatomic, assign) OOSStorageClass storageClass;

/**
 Upload ID that identifies the multipart upload.
 */
@property (nonatomic, strong) NSString * _Nullable uploadId;

@end

/**
 Specifies when noncurrent object versions expire. Upon expiration, Amazon  permanently deletes the noncurrent object versions. You set this lifecycle configuration action on a bucket that has versioning enabled (or suspended) to request that Amazon  delete noncurrent object versions at a specific period in the object's lifetime.
 */
@interface OOSNoncurrentVersionExpiration : CoreModel


/**
 Specifies the number of days an object is noncurrent before Amazon  can perform the associated action. For information about the noncurrent days calculations, see <a href="http://docs.OOS.amazon.com/Amazon/latest/dev/-access-control.html">How Amazon  Calculates When an Object Became Noncurrent</a> in the Amazon Simple Storage Service Developer Guide.
 */
@property (nonatomic, strong) NSNumber * _Nullable noncurrentDays;

@end

/**
 Container for the transition rule that describes when noncurrent objects transition to the STANDARD_IA, ONEZONE_IA or GLACIER storage class. If your bucket is versioning-enabled (or versioning is suspended), you can set this action to request that Amazon  transition noncurrent object versions to the STANDARD_IA, ONEZONE_IA or GLACIER storage class at a specific period in the object's lifetime.
 */
@interface OOSNoncurrentVersionTransition : CoreModel


/**
 Specifies the number of days an object is noncurrent before Amazon  can perform the associated action. For information about the noncurrent days calculations, see <a href="http://docs.OOS.amazon.com/Amazon/latest/dev/-access-control.html">How Amazon  Calculates When an Object Became Noncurrent</a> in the Amazon Simple Storage Service Developer Guide.
 */
@property (nonatomic, strong) NSNumber * _Nullable noncurrentDays;

/**
 The class of storage used to store the object.
 */
@property (nonatomic, assign) OOSTransitionStorageClass storageClass;

@end

/**
 Container for specifying the notification configuration of the bucket. If this element is empty, notifications are turned off on the bucket.
 */
@interface OOSNotificationConfiguration : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<OOSLambdaFunctionConfiguration *> * _Nullable lambdaFunctionConfigurations;

/**
 
 */
@property (nonatomic, strong) NSArray<OOSQueueConfiguration *> * _Nullable queueConfigurations;

/**
 
 */
@property (nonatomic, strong) NSArray<OOSTopicConfiguration *> * _Nullable topicConfigurations;

@end

/**
 
 */
@interface OOSNotificationConfigurationDeprecated : CoreModel


/**
 
 */
@property (nonatomic, strong) OOSCloudFunctionConfiguration * _Nullable cloudFunctionConfiguration;

/**
 
 */
@property (nonatomic, strong) OOSQueueConfigurationDeprecated * _Nullable queueConfiguration;

/**
 
 */
@property (nonatomic, strong) OOSTopicConfigurationDeprecated * _Nullable topicConfiguration;

@end

/**
 Container for object key name filtering rules. For information about key name filtering, go to <a href="http://docs.OOS.amazon.com/Amazon/latest/dev/NotificationHowTo.html">Configuring Event Notifications</a> in the Amazon Simple Storage Service Developer Guide.
 */
@interface OOSNotificationConfigurationFilter : CoreModel


/**
 Container for object key name prefix and suffix filtering rules.
 */
@property (nonatomic, strong) OOSKeyFilter * _Nullable key;

@end

/**
 
 */
@interface OOSObject : CoreModel


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable ETag;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 
 */
@property (nonatomic, strong) NSDate * _Nullable lastModified;

/**
 
 */
@property (nonatomic, strong) OOSOwner * _Nullable owner;

/**
 
 */
@property (nonatomic, strong) NSNumber * _Nullable size;

/**
 The class of storage used to store the object.
 */
@property (nonatomic, assign) OOSObjectStorageClass storageClass;

@end

/**
 
 */
@interface OOSObjectIdentifier : CoreModel


/**
 Key name of the object to delete.
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 VersionId for the specific version of the object to delete.
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 
 */
@interface OOSObjectVersion : CoreModel


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable ETag;

/**
 Specifies whether the object is (true) or is not (false) the latest version of an object.
 */
@property (nonatomic, strong) NSNumber * _Nullable isLatest;

/**
 The object key.
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 Date and time the object was last modified.
 */
@property (nonatomic, strong) NSDate * _Nullable lastModified;

/**
 
 */
@property (nonatomic, strong) OOSOwner * _Nullable owner;

/**
 Size in bytes of the object.
 */
@property (nonatomic, strong) NSNumber * _Nullable size;

/**
 The class of storage used to store the object.
 */
@property (nonatomic, assign) OOSObjectVersionStorageClass storageClass;

/**
 Version ID of an object.
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 Describes how results of the Select job are serialized.
 */
@interface OOSOutputSerialization : CoreModel


/**
 Describes the serialization of CSV-encoded Select results.
 */
@property (nonatomic, strong) OOSCSVOutput * _Nullable CSV;

/**
 Specifies JSON as request's output serialization format.
 */
@property (nonatomic, strong) OOSJSONOutput * _Nullable JSON;

@end

/**
 
 */
@interface OOSOwner : CoreModel


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable displayName;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

@end

/**
 
 */
@interface OOSPart : CoreModel


/**
 Entity tag returned when the part was uploaded.
 */
@property (nonatomic, strong) NSString * _Nullable ETag;

/**
 Date and time at which the part was uploaded.
 */
@property (nonatomic, strong) NSDate * _Nullable lastModified;

/**
 Part number identifying the part. This is a positive integer between 1 and 10,000.
 */
@property (nonatomic, strong) NSNumber * _Nullable partNumber;

/**
 Size of the uploaded part data.
 */
@property (nonatomic, strong) NSNumber * _Nullable size;

@end

/**
 
 */
@interface OOSProgress : CoreModel


/**
 Current number of uncompressed object bytes processed.
 */
@property (nonatomic, strong) NSNumber * _Nullable bytesProcessed;

/**
 Current number of object bytes scanned.
 */
@property (nonatomic, strong) NSNumber * _Nullable bytesScanned;

@end

/**
 
 */
@interface OOSProgressEvent : CoreModel


/**
 The Progress event details.
 */
@property (nonatomic, strong) OOSProgress * _Nullable details;

@end

/**
 
 */
@interface OOSPutBucketAccelerateConfigurationRequest : OOSRequest


/**
 Specifies the Accelerate Configuration you want to set for the bucket.
 */
@property (nonatomic, strong) OOSAccelerateConfiguration * _Nullable accelerateConfiguration;

/**
 Name of the bucket for which the accelerate configuration is set.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

@end

/**
 
 */
@interface OOSPutBucketAclRequest : OOSRequest


/**
 The canned ACL to apply to the bucket.
 */
@property (nonatomic, assign) OOSBucketCannedACL ACL;

/**
 
 */
@property (nonatomic, strong) OOSAccessControlPolicy * _Nullable accessControlPolicy;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable contentMD5;

/**
 Allows grantee the read, write, read ACP, and write ACP permissions on the bucket.
 */
@property (nonatomic, strong) NSString * _Nullable grantFullControl;

/**
 Allows grantee to list the objects in the bucket.
 */
@property (nonatomic, strong) NSString * _Nullable grantRead;

/**
 Allows grantee to read the bucket ACL.
 */
@property (nonatomic, strong) NSString * _Nullable grantReadACP;

/**
 Allows grantee to create, overwrite, and delete any object in the bucket.
 */
@property (nonatomic, strong) NSString * _Nullable grantWrite;

/**
 Allows grantee to write the ACL for the applicable bucket.
 */
@property (nonatomic, strong) NSString * _Nullable grantWriteACP;

@end

/**
 
 */
@interface OOSPutBucketAnalyticsConfigurationRequest : OOSRequest


/**
 The configuration and any analyses for the analytics filter.
 */
@property (nonatomic, strong) OOSAnalyticsConfiguration * _Nullable analyticsConfiguration;

/**
 The name of the bucket to which an analytics configuration is stored.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 The identifier used to represent an analytics configuration.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

@end

/**
 
 */
@interface OOSPutBucketCorsRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) OOSCORSConfiguration * _Nullable CORSConfiguration;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable contentMD5;

@end

/**
 
 */
@interface OOSPutBucketEncryptionRequest : OOSRequest


/**
 The name of the bucket for which the server-side encryption configuration is set.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 The base64-encoded 128-bit MD5 digest of the server-side encryption configuration.
 */
@property (nonatomic, strong) NSString * _Nullable contentMD5;

/**
 Container for server-side encryption configuration rules. Currently  supports one rule only.
 */
@property (nonatomic, strong) OOSServerSideEncryptionConfiguration * _Nullable serverSideEncryptionConfiguration;

@end

/**
 
 */
@interface OOSPutBucketInventoryConfigurationRequest : OOSRequest


/**
 The name of the bucket where the inventory configuration will be stored.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 The ID used to identify the inventory configuration.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

/**
 Specifies the inventory configuration.
 */
@property (nonatomic, strong) OOSInventoryConfiguration * _Nullable inventoryConfiguration;

@end

/**
 
 */
@interface OOSPutBucketLifecycleConfigurationRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) OOSBucketLifecycleConfiguration * _Nullable lifecycleConfiguration;

@end

/**
 
 */
@interface OOSPutBucketLifecycleRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable contentMD5;

/**
 
 */
@property (nonatomic, strong) OOSLifecycleConfiguration * _Nullable lifecycleConfiguration;

@end

/**
 
 */
@interface OOSPutBucketLoggingRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 不能为空
 */
@property (nonatomic, strong) OOSBucketLoggingStatus * bucketLoggingStatus;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable contentMD5;

@end

/**
 
 */
@interface OOSPutBucketMetricsConfigurationRequest : OOSRequest


/**
 The name of the bucket for which the metrics configuration is set.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 The ID used to identify the metrics configuration.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

/**
 Specifies the metrics configuration.
 */
@property (nonatomic, strong) OOSMetricsConfiguration * _Nullable metricsConfiguration;

@end

/**
 
 */
@interface OOSPutBucketNotificationConfigurationRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 Container for specifying the notification configuration of the bucket. If this element is empty, notifications are turned off on the bucket.
 */
@property (nonatomic, strong) OOSNotificationConfiguration * _Nullable notificationConfiguration;

@end

/**
 
 */
@interface OOSPutBucketNotificationRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable contentMD5;

/**
 
 */
@property (nonatomic, strong) OOSNotificationConfigurationDeprecated * _Nullable notificationConfiguration;

@end

/**
 
 */
@interface OOSPutBucketPolicyRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable contentMD5;

/**
 The bucket policy as a JSON document.
 */
@property (nonatomic, strong) NSDictionary * _Nullable policy;

@end

/**
 
 */
@interface OOSPutBucketReplicationRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable contentMD5;

/**
 Container for replication rules. You can add as many as 1,000 rules. Total replication configuration size can be up to 2 MB.
 */
@property (nonatomic, strong) OOSReplicationConfiguration * _Nullable replicationConfiguration;

@end

/**
 
 */
@interface OOSPutBucketRequestPaymentRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable contentMD5;

/**
 
 */
@property (nonatomic, strong) OOSRequestPaymentConfiguration * _Nullable requestPaymentConfiguration;

@end

/**
 
 */
@interface OOSPutBucketTaggingRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable contentMD5;

/**
 
 */
@property (nonatomic, strong) OOSTagging * _Nullable tagging;

@end

/**
 
 */
@interface OOSPutBucketVersioningRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable contentMD5;

/**
 The concatenation of the authentication device's serial number, a space, and the value that is displayed on your authentication device.
 */
@property (nonatomic, strong) NSString * _Nullable MFA;

/**
 
 */
@property (nonatomic, strong) OOSVersioningConfiguration * _Nullable versioningConfiguration;

@end

/**
 
 */
@interface OOSPutBucketWebsiteRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable contentMD5;

/**
 
 */
@property (nonatomic, strong) OOSWebsiteConfiguration * _Nullable websiteConfiguration;

@end

/**
 
 */
@interface OOSPutObjectAclOutput : CoreModel


/**
 If present, indicates that the requester was successfully charged for the request.
 */
@property (nonatomic, assign) OOSRequestCharged requestCharged;

@end

/**
 
 */
@interface OOSPutObjectAclRequest : OOSRequest


/**
 The canned ACL to apply to the object.
 */
@property (nonatomic, assign) OOSObjectCannedACL ACL;

/**
 
 */
@property (nonatomic, strong) OOSAccessControlPolicy * _Nullable accessControlPolicy;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable contentMD5;

/**
 Allows grantee the read, write, read ACP, and write ACP permissions on the bucket.
 */
@property (nonatomic, strong) NSString * _Nullable grantFullControl;

/**
 Allows grantee to list the objects in the bucket.
 */
@property (nonatomic, strong) NSString * _Nullable grantRead;

/**
 Allows grantee to read the bucket ACL.
 */
@property (nonatomic, strong) NSString * _Nullable grantReadACP;

/**
 Allows grantee to create, overwrite, and delete any object in the bucket.
 */
@property (nonatomic, strong) NSString * _Nullable grantWrite;

/**
 Allows grantee to write the ACL for the applicable bucket.
 */
@property (nonatomic, strong) NSString * _Nullable grantWriteACP;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 Confirms that the requester knows that she or he will be charged for the request. Bucket owners need not specify this parameter in their requests. Documentation on downloading objects from requester pays buckets can be found at http://docs.OOS.amazon.com/Amazon/latest/dev/ObjectsinRequesterPaysBuckets.html
 */
@property (nonatomic, assign) OOSRequestPayer requestPayer;

/**
 VersionId used to reference a specific version of the object.
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 
 */
@interface OOSPutObjectOutput : CoreModel


/**
 Entity tag for the uploaded object.
 */
@property (nonatomic, strong) NSString * _Nullable ETag;

/**
 If the object expiration is configured, this will contain the expiration date (expiry-date) and rule ID (rule-id). The value of rule-id is URL encoded.
 */
@property (nonatomic, strong) NSString * _Nullable expiration;

/**
 If present, indicates that the requester was successfully charged for the request.
 */
@property (nonatomic, assign) OOSRequestCharged requestCharged;

/**
 If server-side encryption with a customer-provided encryption key was requested, the response will include this header confirming the encryption algorithm used.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerAlgorithm;

/**
 If server-side encryption with a customer-provided encryption key was requested, the response will include this header to provide round trip message integrity verification of the customer-provided encryption key.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerKeyMD5;

/**
 If present, specifies the ID of the OOS Key Management Service (KMS) master encryption key that was used for the object.
 */
@property (nonatomic, strong) NSString * _Nullable SSEKMSKeyId;

/**
 The Server-side encryption algorithm used when storing this object in  (e.g., AES256, OOS:kms).
 */
@property (nonatomic, assign) OOSServerSideEncryption serverSideEncryption;

/**
 Version of the object.
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 
 */
@interface OOSPutObjectRequest : OOSRequest


/**
 The canned ACL to apply to the object.
 */
@property (nonatomic, assign) OOSObjectCannedACL ACL;

/**
 Object data.
 */
@property (nonatomic, strong) id _Nullable body;

/**
 Name of the bucket to which the PUT operation was initiated.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 Specifies caching behavior along the request/reply chain.
 */
@property (nonatomic, strong) NSString * _Nullable cacheControl;

/**
 Specifies presentational information for the object.
 */
@property (nonatomic, strong) NSString * _Nullable contentDisposition;

/**
 Specifies what content encodings have been applied to the object and thus what decoding mechanisms must be applied to obtain the media-type referenced by the Content-Type header field.
 */
@property (nonatomic, strong) NSString * _Nullable contentEncoding;

/**
 The language the content is in.
 */
@property (nonatomic, strong) NSString * _Nullable contentLanguage;

/**
 Size of the body in bytes. This parameter is useful when the size of the body cannot be determined automatically.
 */
@property (nonatomic, strong) NSNumber * _Nullable contentLength;

/**
 The base64-encoded 128-bit MD5 digest of the part data.
 */
@property (nonatomic, strong) NSString * _Nullable contentMD5;

/**
 A standard MIME type describing the format of the object data.
 */
@property (nonatomic, strong) NSString * _Nullable contentType;

/**
 The date and time at which the object is no longer cacheable.
 */
@property (nonatomic, strong) NSDate * _Nullable expires;

/**
 Gives the grantee READ, READ_ACP, and WRITE_ACP permissions on the object.
 */
@property (nonatomic, strong) NSString * _Nullable grantFullControl;

/**
 Allows grantee to read the object data and its metadata.
 */
@property (nonatomic, strong) NSString * _Nullable grantRead;

/**
 Allows grantee to read the object ACL.
 */
@property (nonatomic, strong) NSString * _Nullable grantReadACP;

/**
 Allows grantee to write the ACL for the applicable object.
 */
@property (nonatomic, strong) NSString * _Nullable grantWriteACP;

/**
 Object key for which the PUT operation was initiated.
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 A map of metadata to store with the object in .
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> * _Nullable metadata;

/**
 The Server-side encryption algorithm used when storing this object in  (e.g., AES256, OOS:kms).
 */
@property (nonatomic, assign) OOSServerSideEncryption serverSideEncryption;

/**
 The type of storage to use for the object. Defaults to 'STANDARD'.
 */
@property (nonatomic, assign) OOSStorageClass storageClass;

/**
 设置bucket的数据位置。
 类型：key-value形式
 有效值：
 type=[ Local|Specified],location=[ ChengDu|ShenYa
 ng|...],scheduleStrategy=[ Allowed|NotAllowed]
 type=local表示就近写入本地。type= Specified表示指定
 位置。location表示指定的数据位置，可以填写多个，以
 逗号分隔。scheduleStrategy表示调度策略，是否允许
 OOS自动调度数据存储位置。
 */
@property (nonatomic, strong) NSString * _Nullable dataLocation;

@end

/**
 
 */
@interface OOSPutObjectTaggingOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 
 */
@interface OOSPutObjectTaggingRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable contentMD5;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 
 */
@property (nonatomic, strong) OOSTagging * _Nullable tagging;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 Container for specifying an configuration when you want Amazon  to publish events to an Amazon Simple Queue Service (Amazon SQS) queue.
 Required parameters: [QueueArn, Events]
 */
@interface OOSQueueConfiguration : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<NSString *> * _Nullable events;

/**
 Container for object key name filtering rules. For information about key name filtering, go to <a href="http://docs.OOS.amazon.com/Amazon/latest/dev/NotificationHowTo.html">Configuring Event Notifications</a> in the Amazon Simple Storage Service Developer Guide.
 */
@property (nonatomic, strong) OOSNotificationConfigurationFilter * _Nullable filter;

/**
 Optional unique identifier for configurations in a notification configuration. If you don't provide one, Amazon  will assign an ID.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

/**
 Amazon SQS queue ARN to which Amazon  will publish a message when it detects events of specified type.
 */
@property (nonatomic, strong) NSString * _Nullable queueArn;

@end

/**
 
 */
@interface OOSQueueConfigurationDeprecated : CoreModel


/**
 Bucket event for which to send notifications.
 */
@property (nonatomic, assign) OOSEvent event;

/**
 
 */
@property (nonatomic, strong) NSArray<NSString *> * _Nullable events;

/**
 Optional unique identifier for configurations in a notification configuration. If you don't provide one, Amazon  will assign an ID.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable queue;

@end

/**
 
 */
@interface OOSRecordsEvent : CoreModel


/**
 The byte array of partial, one or more result records.
 */
@property (nonatomic, strong) id _Nullable payload;

@end

/**
 
 */
@interface OOSRedirect : CoreModel


/**
 The host name to use in the redirect request.
 */
@property (nonatomic, strong) NSString * _Nullable hostName;

/**
 The HTTP redirect code to use on the response. Not required if one of the siblings is present.
 */
@property (nonatomic, strong) NSString * _Nullable httpRedirectCode;

/**
 Protocol to use (http, https) when redirecting requests. The default is the protocol that is used in the original request.
 */
@property (nonatomic, assign) OOSProtocols protocols;

/**
 The object key prefix to use in the redirect request. For example, to redirect requests for all pages with prefix docs/ (objects in the docs/ folder) to documents/, you can set a condition block with KeyPrefixEquals set to docs/ and in the Redirect set ReplaceKeyPrefixWith to /documents. Not required if one of the siblings is present. Can be present only if ReplaceKeyWith is not provided.
 */
@property (nonatomic, strong) NSString * _Nullable replaceKeyPrefixWith;

/**
 The specific object key to use in the redirect request. For example, redirect request to error.html. Not required if one of the sibling is present. Can be present only if ReplaceKeyPrefixWith is not provided.
 */
@property (nonatomic, strong) NSString * _Nullable replaceKeyWith;

@end

/**
 
 */
@interface OOSRedirectAllRequestsTo : CoreModel


/**
 Name of the host where requests will be redirected.
 */
@property (nonatomic, strong) NSString * _Nullable hostName;

/**
 Protocol to use (http, https) when redirecting requests. The default is the protocol that is used in the original request.
 */
@property (nonatomic, assign) OOSProtocols protocols;

@end

/**
 Container for replication rules. You can add as many as 1,000 rules. Total replication configuration size can be up to 2 MB.
 Required parameters: [Role, Rules]
 */
@interface OOSReplicationConfiguration : CoreModel


/**
 Amazon Resource Name (ARN) of an IAM role for Amazon  to assume when replicating the objects.
 */
@property (nonatomic, strong) NSString * _Nullable role;

/**
 Container for information about a particular replication rule. Replication configuration must have at least one rule and can contain up to 1,000 rules.
 */
@property (nonatomic, strong) NSArray<OOSReplicationRule *> * _Nullable rules;

@end

/**
 Container for information about a particular replication rule.
 Required parameters: [Prefix, Status, Destination]
 */
@interface OOSReplicationRule : CoreModel


/**
 Container for replication destination information.
 */
@property (nonatomic, strong) OOSDestination * _Nullable destination;

/**
 Unique identifier for the rule. The value cannot be longer than 255 characters.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

/**
 Object keyname prefix identifying one or more objects to which the rule applies. Maximum prefix length can be up to 1,024 characters. Overlapping prefixes are not supported.
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

/**
 Container for filters that define which source objects should be replicated.
 */
@property (nonatomic, strong) OOSSourceSelectionCriteria * _Nullable sourceSelectionCriteria;

/**
 The rule is ignored if status is not Enabled.
 */
@property (nonatomic, assign) OOSReplicationRuleStatus status;

@end

/**
 
 */
@interface OOSRequestPaymentConfiguration : CoreModel


/**
 Specifies who pays for the download and request fees.
 */
@property (nonatomic, assign) OOSPayer payer;

@end

/**
 
 */
@interface OOSRequestProgress : CoreModel


/**
 Specifies whether periodic QueryProgress frames should be sent. Valid values: TRUE, FALSE. Default value: FALSE.
 */
@property (nonatomic, strong) NSNumber * _Nullable enabled;

@end

/**
 
 */
@interface OOSRestoreObjectOutput : CoreModel


/**
 If present, indicates that the requester was successfully charged for the request.
 */
@property (nonatomic, assign) OOSRequestCharged requestCharged;

/**
 Indicates the path in the provided  output location where Select results will be restored to.
 */
@property (nonatomic, strong) NSString * _Nullable restoreOutputPath;

@end

/**
 
 */
@interface OOSRestoreObjectRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 Confirms that the requester knows that she or he will be charged for the request. Bucket owners need not specify this parameter in their requests. Documentation on downloading objects from requester pays buckets can be found at http://docs.OOS.amazon.com/Amazon/latest/dev/ObjectsinRequesterPaysBuckets.html
 */
@property (nonatomic, assign) OOSRequestPayer requestPayer;

/**
 Container for restore job parameters.
 */
@property (nonatomic, strong) OOSRestoreRequest * _Nullable restoreRequest;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable versionId;

@end

/**
 Container for restore job parameters.
 */
@interface OOSRestoreRequest : CoreModel


/**
 Lifetime of the active copy in days. Do not use with restores that specify OutputLocation.
 */
@property (nonatomic, strong) NSNumber * _Nullable days;

/**
 The optional description for the job.
 */
@property (nonatomic, strong) NSString * _Nullable detail;

/**
 Glacier related parameters pertaining to this job. Do not use with restores that specify OutputLocation.
 */
@property (nonatomic, strong) OOSGlacierJobParameters * _Nullable glacierJobParameters;

/**
 Describes the parameters for Select job types.
 */
@property (nonatomic, strong) OOSSelectParameters * _Nullable selectParameters;

/**
 Glacier retrieval tier at which the restore will be processed.
 */
@property (nonatomic, assign) OOSTier tier;

/**
 Type of restore request.
 */
@property (nonatomic, assign) OOSRestoreRequestType types;

@end

/**
 
 */
@interface OOSRoutingRule : CoreModel


/**
 A container for describing a condition that must be met for the specified redirect to apply. For example, 1. If request is for pages in the /docs folder, redirect to the /documents folder. 2. If request results in HTTP error 4xx, redirect request to another host where you might process the error.
 */
@property (nonatomic, strong) OOSCondition * _Nullable condition;

/**
 Container for redirect information. You can redirect requests to another host, to another page, or with another protocol. In the event of an error, you can can specify a different error code to return.
 */
@property (nonatomic, strong) OOSRedirect * _Nullable redirect;

@end

/**
 
 */
@interface OOSRule : CoreModel


/**
 Specifies the days since the initiation of an Incomplete Multipart Upload that Lifecycle will wait before permanently removing all parts of the upload.
 */
@property (nonatomic, strong) OOSAbortIncompleteMultipartUpload * _Nullable abortIncompleteMultipartUpload;

/**
 
 */
@property (nonatomic, strong) OOSLifecycleExpiration * _Nullable expiration;

/**
 Unique identifier for the rule. The value cannot be longer than 255 characters.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

/**
 Specifies when noncurrent object versions expire. Upon expiration, Amazon  permanently deletes the noncurrent object versions. You set this lifecycle configuration action on a bucket that has versioning enabled (or suspended) to request that Amazon  delete noncurrent object versions at a specific period in the object's lifetime.
 */
@property (nonatomic, strong) OOSNoncurrentVersionExpiration * _Nullable noncurrentVersionExpiration;

/**
 Container for the transition rule that describes when noncurrent objects transition to the STANDARD_IA, ONEZONE_IA or GLACIER storage class. If your bucket is versioning-enabled (or versioning is suspended), you can set this action to request that Amazon  transition noncurrent object versions to the STANDARD_IA, ONEZONE_IA or GLACIER storage class at a specific period in the object's lifetime.
 */
@property (nonatomic, strong) OOSNoncurrentVersionTransition * _Nullable noncurrentVersionTransition;

/**
 Prefix identifying one or more objects to which the rule applies.
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

/**
 If 'Enabled', the rule is currently being applied. If 'Disabled', the rule is not currently being applied.
 */
@property (nonatomic, assign) OOSExpirationStatus status;

/**
 
 */
@property (nonatomic, strong) OOSTransition * _Nullable transition;

@end

/**
 Container for object key name prefix and suffix filtering rules.
 */
@interface OOSKeyFilter : CoreModel


/**
 A list of containers for key value pair that defines the criteria for the filter rule.
 */
@property (nonatomic, strong) NSArray<OOSFilterRule *> * _Nullable filterRules;

@end

/**
 Describes an  location that will receive the results of the restore request.
 Required parameters: [BucketName, Prefix]
 */
@interface OOSLocation : CoreModel


/**
 A list of grants that control access to the staged results.
 */
@property (nonatomic, strong) NSArray<OOSGrant *> * _Nullable accessControlList;

/**
 The name of the bucket where the restore results will be placed.
 */
@property (nonatomic, strong) NSString * _Nullable bucketName;

/**
 The canned ACL to apply to the restore results.
 */
@property (nonatomic, assign) OOSObjectCannedACL cannedACL;

/**
 Describes the server-side encryption that will be applied to the restore results.
 */
@property (nonatomic, strong) OOSEncryption * _Nullable encryption;

/**
 The prefix that is prepended to the restore results for this request.
 */
@property (nonatomic, strong) NSString * _Nullable prefix;

/**
 The class of storage used to store the restore results.
 */
@property (nonatomic, assign) OOSStorageClass storageClass;

/**
 The tag-set that is applied to the restore results.
 */
@property (nonatomic, strong) OOSTagging * _Nullable tagging;

/**
 A list of metadata to store with the restore results in .
 */
@property (nonatomic, strong) NSArray<OOSMetadataEntry *> * _Nullable userMetadata;

@end

/**
 Specifies the use of SSE-KMS to encrypt delievered Inventory reports.
 Required parameters: [KeyId]
 */
@interface OOSSSEKMS : CoreModel


/**
 Specifies the ID of the OOS Key Management Service (KMS) master encryption key to use for encrypting Inventory reports.
 */
@property (nonatomic, strong) NSString * _Nullable keyId;

@end

/**
 Specifies the use of SSE- to encrypt delievered Inventory reports.
 */
@interface OOSSSE : CoreModel


@end

/**
 
 */
@interface OOSSelectObjectContentEventStream : CoreModel


/**
 The Continuation Event.
 */
@property (nonatomic, strong) OOSContinuationEvent * _Nullable cont;

/**
 The End Event.
 */
@property (nonatomic, strong) OOSEndEvent * _Nullable end;

/**
 The Progress Event.
 */
@property (nonatomic, strong) OOSProgressEvent * _Nullable progress;

/**
 The Records Event.
 */
@property (nonatomic, strong) OOSRecordsEvent * _Nullable records;

/**
 The Stats Event.
 */
@property (nonatomic, strong) OOSStatsEvent * _Nullable stats;

@end

/**
 
 */
@interface OOSSelectObjectContentOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) OOSSelectObjectContentEventStream * _Nullable payload;

@end

/**
 Request to filter the contents of an Amazon  object based on a simple Structured Query Language (SQL) statement. In the request, along with the SQL expression, you must also specify a data serialization format (JSON or CSV) of the object. Amazon  uses this to parse object data into records, and returns only records that match the specified SQL expression. You must also specify the data serialization format for the response. For more information, go to <a href="https://docs.OOS.amazon.com/Amazon/latest/API/RESTObjectSELECTContent.html">Select API Documentation</a>.
 Required parameters: [Bucket, Key, Expression, ExpressionType, InputSerialization, OutputSerialization]
 */
@interface OOSSelectObjectContentRequest : OOSRequest


/**
 The  Bucket.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 The expression that is used to query the object.
 */
@property (nonatomic, strong) NSString * _Nullable expression;

/**
 The type of the provided expression (e.g., SQL).
 */
@property (nonatomic, assign) OOSExpressionType expressionType;

/**
 Describes the format of the data in the object that is being queried.
 */
@property (nonatomic, strong) OOSInputSerialization * _Nullable inputSerialization;

/**
 The Object Key.
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 Describes the format of the data that you want Amazon  to return in response.
 */
@property (nonatomic, strong) OOSOutputSerialization * _Nullable outputSerialization;

/**
 Specifies if periodic request progress information should be enabled.
 */
@property (nonatomic, strong) OOSRequestProgress * _Nullable requestProgress;

/**
 The SSE Algorithm used to encrypt the object. For more information, go to <a href="https://docs.OOS.amazon.com/Amazon/latest/dev/ServerSideEncryptionCustomerKeys.html"> Server-Side Encryption (Using Customer-Provided Encryption Keys</a>.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerAlgorithm;

/**
 The SSE Customer Key. For more information, go to <a href="https://docs.OOS.amazon.com/Amazon/latest/dev/ServerSideEncryptionCustomerKeys.html"> Server-Side Encryption (Using Customer-Provided Encryption Keys</a>.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerKey;

/**
 The SSE Customer Key MD5. For more information, go to <a href="https://docs.OOS.amazon.com/Amazon/latest/dev/ServerSideEncryptionCustomerKeys.html"> Server-Side Encryption (Using Customer-Provided Encryption Keys</a>.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerKeyMD5;

@end

/**
 Describes the parameters for Select job types.
 Required parameters: [InputSerialization, ExpressionType, Expression, OutputSerialization]
 */
@interface OOSSelectParameters : CoreModel


/**
 The expression that is used to query the object.
 */
@property (nonatomic, strong) NSString * _Nullable expression;

/**
 The type of the provided expression (e.g., SQL).
 */
@property (nonatomic, assign) OOSExpressionType expressionType;

/**
 Describes the serialization format of the object.
 */
@property (nonatomic, strong) OOSInputSerialization * _Nullable inputSerialization;

/**
 Describes how the results of the Select job are serialized.
 */
@property (nonatomic, strong) OOSOutputSerialization * _Nullable outputSerialization;

@end

/**
 Describes the default server-side encryption to apply to new objects in the bucket. If Put Object request does not specify any server-side encryption, this default encryption will be applied.
 Required parameters: [SSEAlgorithm]
 */
@interface OOSServerSideEncryptionByDefault : CoreModel


/**
 KMS master key ID to use for the default encryption. This parameter is allowed if SSEAlgorithm is OOS:kms.
 */
@property (nonatomic, strong) NSString * _Nullable KMSMasterKeyID;

/**
 Server-side encryption algorithm to use for the default encryption.
 */
@property (nonatomic, assign) OOSServerSideEncryption SSEAlgorithm;

@end

/**
 Container for server-side encryption configuration rules. Currently  supports one rule only.
 Required parameters: [Rules]
 */
@interface OOSServerSideEncryptionConfiguration : CoreModel


/**
 Container for information about a particular server-side encryption configuration rule.
 */
@property (nonatomic, strong) NSArray<OOSServerSideEncryptionRule *> * _Nullable rules;

@end

/**
 Container for information about a particular server-side encryption configuration rule.
 */
@interface OOSServerSideEncryptionRule : CoreModel


/**
 Describes the default server-side encryption to apply to new objects in the bucket. If Put Object request does not specify any server-side encryption, this default encryption will be applied.
 */
@property (nonatomic, strong) OOSServerSideEncryptionByDefault * _Nullable applyServerSideEncryptionByDefault;

@end

/**
 Container for filters that define which source objects should be replicated.
 */
@interface OOSSourceSelectionCriteria : CoreModel


/**
 Container for filter information of selection of KMS Encrypted  objects.
 */
@property (nonatomic, strong) OOSSseKmsEncryptedObjects * _Nullable sseKmsEncryptedObjects;

@end

/**
 Container for filter information of selection of KMS Encrypted  objects.
 Required parameters: [Status]
 */
@interface OOSSseKmsEncryptedObjects : CoreModel


/**
 The replication for KMS encrypted  objects is disabled if status is not Enabled.
 */
@property (nonatomic, assign) OOSSseKmsEncryptedObjectsStatus status;

@end

/**
 
 */
@interface OOSStats : CoreModel


/**
 Total number of uncompressed object bytes processed.
 */
@property (nonatomic, strong) NSNumber * _Nullable bytesProcessed;

/**
 Total number of object bytes scanned.
 */
@property (nonatomic, strong) NSNumber * _Nullable bytesScanned;

@end

/**
 
 */
@interface OOSStatsEvent : CoreModel


/**
 The Stats event details.
 */
@property (nonatomic, strong) OOSStats * _Nullable details;

@end

/**
 
 */
@interface OOSStorageClassAnalysis : CoreModel


/**
 A container used to describe how data related to the storage class analysis should be exported.
 */
@property (nonatomic, strong) OOSStorageClassAnalysisDataExport * _Nullable dataExport;

@end

/**
 
 */
@interface OOSStorageClassAnalysisDataExport : CoreModel


/**
 The place to store the data for an analysis.
 */
@property (nonatomic, strong) OOSAnalyticsExportDestination * _Nullable destination;

/**
 The version of the output schema to use when exporting data. Must be V_1.
 */
@property (nonatomic, assign) OOSStorageClassAnalysisSchemaVersion outputSchemaVersion;

@end

/**
 
 */
@interface OOSTag : CoreModel


/**
 Name of the tag.
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 Value of the tag.
 */
@property (nonatomic, strong) NSString * _Nullable value;

@end

/**
 
 */
@interface OOSTagging : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<OOSTag *> * _Nullable tagSet;

@end

/**
 
 */
@interface OOSTargetGrant : CoreModel


/**
 
 */
@property (nonatomic, strong) OOSGrantee * _Nullable grantee;

/**
 Logging permissions assigned to the Grantee for the bucket.
 */
@property (nonatomic, assign) OOSBucketLogsPermission permission;

@end

/**
 Container for specifying the configuration when you want Amazon  to publish events to an Amazon Simple Notification Service (Amazon SNS) topic.
 Required parameters: [TopicArn, Events]
 */
@interface OOSTopicConfiguration : CoreModel


/**
 
 */
@property (nonatomic, strong) NSArray<NSString *> * _Nullable events;

/**
 Container for object key name filtering rules. For information about key name filtering, go to <a href="http://docs.OOS.amazon.com/Amazon/latest/dev/NotificationHowTo.html">Configuring Event Notifications</a> in the Amazon Simple Storage Service Developer Guide.
 */
@property (nonatomic, strong) OOSNotificationConfigurationFilter * _Nullable filter;

/**
 Optional unique identifier for configurations in a notification configuration. If you don't provide one, Amazon  will assign an ID.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

/**
 Amazon SNS topic ARN to which Amazon  will publish a message when it detects events of specified type.
 */
@property (nonatomic, strong) NSString * _Nullable topicArn;

@end

/**
 
 */
@interface OOSTopicConfigurationDeprecated : CoreModel


/**
 Bucket event for which to send notifications.
 */
@property (nonatomic, assign) OOSEvent event;

/**
 
 */
@property (nonatomic, strong) NSArray<NSString *> * _Nullable events;

/**
 Optional unique identifier for configurations in a notification configuration. If you don't provide one, Amazon  will assign an ID.
 */
@property (nonatomic, strong) NSString * _Nullable identifier;

/**
 Amazon SNS topic to which Amazon  will publish a message to report the specified events for the bucket.
 */
@property (nonatomic, strong) NSString * _Nullable topic;

@end

/**
 
 */
@interface OOSTransition : CoreModel


/**
 Indicates at what date the object is to be moved or deleted. Should be in GMT ISO 8601 Format.
 */
@property (nonatomic, strong) NSDate * _Nullable date;

/**
 Indicates the lifetime, in days, of the objects that are subject to the rule. The value must be a non-zero positive integer.
 */
@property (nonatomic, strong) NSNumber * _Nullable days;

/**
 The class of storage used to store the object.
 */
@property (nonatomic, assign) OOSTransitionStorageClass storageClass;

@end

/**
 
 */
@interface OOSUploadPartCopyOutput : CoreModel


/**
 
 */
@property (nonatomic, strong) OOSReplicatePartResult * _Nullable replicatePartResult;

/**
 The version of the source object that was copied, if you have enabled versioning on the source bucket.
 */
@property (nonatomic, strong) NSString * _Nullable replicateSourceVersionId;

/**
 If present, indicates that the requester was successfully charged for the request.
 */
@property (nonatomic, assign) OOSRequestCharged requestCharged;

/**
 If server-side encryption with a customer-provided encryption key was requested, the response will include this header confirming the encryption algorithm used.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerAlgorithm;

/**
 If server-side encryption with a customer-provided encryption key was requested, the response will include this header to provide round trip message integrity verification of the customer-provided encryption key.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerKeyMD5;

/**
 If present, specifies the ID of the OOS Key Management Service (KMS) master encryption key that was used for the object.
 */
@property (nonatomic, strong) NSString * _Nullable SSEKMSKeyId;

/**
 The Server-side encryption algorithm used when storing this object in  (e.g., AES256, OOS:kms).
 */
@property (nonatomic, assign) OOSServerSideEncryption serverSideEncryption;

@end

/**
 
 */
@interface OOSUploadPartCopyRequest : OOSRequest


/**
 
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 The name of the source bucket and key name of the source object, separated by a slash (/). Must be URL-encoded.
 */
@property (nonatomic, strong) NSString * _Nullable replicateSource;

/**
 Copies the object if its entity tag (ETag) matches the specified tag.
 */
@property (nonatomic, strong) NSString * _Nullable replicateSourceIfMatch;

/**
 Copies the object if it has been modified since the specified time.
 */
@property (nonatomic, strong) NSDate * _Nullable replicateSourceIfModifiedSince;

/**
 Copies the object if its entity tag (ETag) is different than the specified ETag.
 */
@property (nonatomic, strong) NSString * _Nullable replicateSourceIfNoneMatch;

/**
 Copies the object if it hasn't been modified since the specified time.
 */
@property (nonatomic, strong) NSDate * _Nullable replicateSourceIfUnmodifiedSince;

/**
 The range of bytes to copy from the source object. The range value must use the form bytes=first-last, where the first and last are the zero-based byte offsets to copy. For example, bytes=0-9 indicates that you want to copy the first ten bytes of the source. You can copy a range only if the source object is greater than 5 GB.
 */
@property (nonatomic, strong) NSString * _Nullable replicateSourceRange;

/**
 Specifies the algorithm to use when decrypting the source object (e.g., AES256).
 */
@property (nonatomic, strong) NSString * _Nullable replicateSourceSSECustomerAlgorithm;

/**
 Specifies the customer-provided encryption key for Amazon  to use to decrypt the source object. The encryption key provided in this header must be one that was used when the source object was created.
 */
@property (nonatomic, strong) NSString * _Nullable replicateSourceSSECustomerKey;

/**
 Specifies the 128-bit MD5 digest of the encryption key according to RFC 1321. Amazon  uses this header for a message integrity check to ensure the encryption key was transmitted without error.
 */
@property (nonatomic, strong) NSString * _Nullable replicateSourceSSECustomerKeyMD5;

/**
 
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 Part number of part being copied. This is a positive integer between 1 and 10,000.
 */
@property (nonatomic, strong) NSNumber * _Nullable partNumber;

/**
 Confirms that the requester knows that she or he will be charged for the request. Bucket owners need not specify this parameter in their requests. Documentation on downloading objects from requester pays buckets can be found at http://docs.OOS.amazon.com/Amazon/latest/dev/ObjectsinRequesterPaysBuckets.html
 */
@property (nonatomic, assign) OOSRequestPayer requestPayer;

/**
 Specifies the algorithm to use to when encrypting the object (e.g., AES256).
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerAlgorithm;

/**
 Specifies the customer-provided encryption key for Amazon  to use in encrypting data. This value is used to store the object and then it is discarded; Amazon does not store the encryption key. The key must be appropriate for use with the algorithm specified in the x-amz-server-side​-encryption​-customer-algorithm header. This must be the same encryption key specified in the initiate multipart upload request.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerKey;

/**
 Specifies the 128-bit MD5 digest of the encryption key according to RFC 1321. Amazon  uses this header for a message integrity check to ensure the encryption key was transmitted without error.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerKeyMD5;

/**
 Upload ID identifying the multipart upload whose part is being copied.
 */
@property (nonatomic, strong) NSString * _Nullable uploadId;

@end

/**
 
 */
@interface OOSUploadPartOutput : CoreModel


/**
 Entity tag for the uploaded object.
 */
@property (nonatomic, strong) NSString * _Nullable ETag;

/**
 If present, indicates that the requester was successfully charged for the request.
 */
@property (nonatomic, assign) OOSRequestCharged requestCharged;

/**
 If server-side encryption with a customer-provided encryption key was requested, the response will include this header confirming the encryption algorithm used.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerAlgorithm;

/**
 If server-side encryption with a customer-provided encryption key was requested, the response will include this header to provide round trip message integrity verification of the customer-provided encryption key.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerKeyMD5;

/**
 If present, specifies the ID of the OOS Key Management Service (KMS) master encryption key that was used for the object.
 */
@property (nonatomic, strong) NSString * _Nullable SSEKMSKeyId;

/**
 The Server-side encryption algorithm used when storing this object in  (e.g., AES256, OOS:kms).
 */
@property (nonatomic, assign) OOSServerSideEncryption serverSideEncryption;

@end

/**
 
 */
@interface OOSUploadPartRequest : OOSRequest


/**
 Object data.
 */
@property (nonatomic, strong) id _Nullable body;

/**
 Name of the bucket to which the multipart upload was initiated.
 */
@property (nonatomic, strong) NSString * _Nullable bucket;

/**
 Size of the body in bytes. This parameter is useful when the size of the body cannot be determined automatically.
 */
@property (nonatomic, strong) NSNumber * _Nullable contentLength;

/**
 The base64-encoded 128-bit MD5 digest of the part data.
 */
@property (nonatomic, strong) NSString * _Nullable contentMD5;

/**
 Object key for which the multipart upload was initiated.
 */
@property (nonatomic, strong) NSString * _Nullable key;

/**
 Part number of part being uploaded. This is a positive integer between 1 and 10,000.
 */
@property (nonatomic, strong) NSNumber * _Nullable partNumber;

/**
 Confirms that the requester knows that she or he will be charged for the request. Bucket owners need not specify this parameter in their requests. Documentation on downloading objects from requester pays buckets can be found at http://docs.OOS.amazon.com/Amazon/latest/dev/ObjectsinRequesterPaysBuckets.html
 */
@property (nonatomic, assign) OOSRequestPayer requestPayer;

/**
 Specifies the algorithm to use to when encrypting the object (e.g., AES256).
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerAlgorithm;

/**
 Specifies the customer-provided encryption key for Amazon  to use in encrypting data. This value is used to store the object and then it is discarded; Amazon does not store the encryption key. The key must be appropriate for use with the algorithm specified in the x-amz-server-side​-encryption​-customer-algorithm header. This must be the same encryption key specified in the initiate multipart upload request.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerKey;

/**
 Specifies the 128-bit MD5 digest of the encryption key according to RFC 1321. Amazon  uses this header for a message integrity check to ensure the encryption key was transmitted without error.
 */
@property (nonatomic, strong) NSString * _Nullable SSECustomerKeyMD5;

/**
 Upload ID identifying the multipart upload whose part is being uploaded.
 */
@property (nonatomic, strong) NSString * _Nullable uploadId;

@end

/**
 
 */
@interface OOSVersioningConfiguration : CoreModel


/**
 Specifies whether MFA delete is enabled in the bucket versioning configuration. This element is only returned if the bucket has been configured with MFA delete. If the bucket has never been so configured, this element is not returned.
 */
@property (nonatomic, assign) OOSMFADelete MFADelete;

/**
 The versioning state of the bucket.
 */
@property (nonatomic, assign) OOSBucketVersioningStatus status;

@end

/**
 
 */
@interface OOSWebsiteConfiguration : CoreModel


/**
 
 */
@property (nonatomic, strong) OOSErrorDocument * _Nullable errorDocument;

/**
 
 */
@property (nonatomic, strong) OOSIndexDocument * _Nullable indexDocument;

@end


@interface OOSRemoteSite : CoreModel

@property (nonatomic, strong) NSString * _Nullable remoteEndPoint;
@property (nonatomic, strong) NSString * _Nullable replicaMode;
@property (nonatomic, strong) NSString * _Nullable remoteBucketName;
@property (nonatomic, strong) NSString * _Nullable remoteAK;
@property (nonatomic, strong) NSString * _Nullable remoteSK;

@end

@interface OOSTrigger : CoreModel

@property (nonatomic, strong) NSString * _Nullable triggerName;
@property (nonatomic, assign) NSString * _Nullable isDefault;	// true or false
@property (nonatomic, strong) OOSRemoteSite * _Nullable remoteSite;

@end

@interface OOSTriggerConfiguration : CoreModel

@property (nonatomic, strong) NSArray<OOSTrigger *> * _Nullable triggers;

@end

@interface OOSPutBucketTriggerRequest : OOSRequest

@property (nonatomic, strong) NSString * _Nullable bucket;

@property (nonatomic, strong) OOSTriggerConfiguration * _Nullable triggerConfiguration;

@end

@interface OOSGetBucketTriggerRequest : OOSRequest

@property (nonatomic, strong) NSString * _Nullable bucket;

@end

@interface OOSDeleteBucketTriggerRequest : OOSRequest

@property (nonatomic, strong) NSString * _Nullable bucket;

@property (nonatomic, strong) NSString * _Nullable triggerName;

@end

@interface OOSGetBucketTriggerOutput : CoreModel

@property (nonatomic, strong) OOSTriggerConfiguration * _Nullable triggerConfiguration;

@end

@interface OOSCreateAccessKeyRequest : OOSRequest

@property (nonatomic, readonly) NSString * _Nullable action;

@end

@interface OOSAccessKey : CoreModel

@property (nonatomic, strong) NSString * _Nullable userName;
@property (nonatomic, strong) NSString * _Nullable accessKeyId;
@property (nonatomic, strong) NSString * _Nullable status;
@property (nonatomic, strong) NSString * _Nullable isPrimary;
@property (nonatomic, strong) NSString * _Nullable secretAccessKey;

@end

@interface OOSCreateAccessKeyResult : CoreModel

@property (nonatomic, strong) OOSAccessKey * _Nullable accessKey;

@end

@interface OOSResponseMetadata : CoreModel

@property (nonatomic, strong) NSString * _Nullable requestId;

@end

@interface OOSCreateAccessKeyResponse : CoreModel

@property (nonatomic, strong) OOSCreateAccessKeyResult * _Nullable createAccessKeyResult;
@property (nonatomic, strong) OOSResponseMetadata * _Nullable responseMetadata;

@end

@interface OOSCreateAccessKeyOutput : CoreModel

@property (nonatomic, strong) OOSCreateAccessKeyResponse * _Nullable createAccessKeyResponse;

@end

@interface OOSDeleteAccessKeyRequest : OOSRequest

@property (nonatomic, readonly) NSString * _Nullable action;
@property (nonatomic, strong) NSString * _Nullable accessKeyId;

@end

@interface OOSDeleteAccessKeyResponse : CoreModel

@property (nonatomic, strong) OOSResponseMetadata * _Nullable responseMetadata;

@end

@interface OOSDeleteAccessKeyOutput : CoreModel

@property (nonatomic, strong) OOSDeleteAccessKeyResponse * _Nullable deleteAccessKeyResponse;

@end

@interface OOSUpdateAccessKeyRequest : OOSRequest

@property (nonatomic, readonly) NSString * _Nullable action;
@property (nonatomic, strong) NSString * _Nullable accessKeyId;
@property (nonatomic, strong) NSString * _Nullable status;
@property (nonatomic, strong) NSString * _Nullable isPrimary;

@end

@interface OOSUpdateAccessKeyResponse : CoreModel

@property (nonatomic, strong) OOSResponseMetadata * _Nullable responseMetadata;

@end

@interface OOSUpdateAccessKeyOutput : CoreModel

@property (nonatomic, strong) OOSUpdateAccessKeyResponse * _Nullable updateAccessKeyResponse;

@end

@interface OOSListAccessKeyRequest : OOSRequest

@property (nonatomic, readonly) NSString * _Nullable action;
@property (nonatomic, strong) NSNumber * _Nullable maxItems;
@property (nonatomic, strong) NSString * _Nullable marker;

@end

@interface OOSAccessKeyMember : CoreModel

@property (nonatomic, strong) NSString * _Nullable userName;
@property (nonatomic, strong) NSString * _Nullable accessKeyId;
@property (nonatomic, strong) NSString * _Nullable status;
@property (nonatomic, strong) NSString * _Nullable isPrimary;

@end

@interface OOSAccessKeyMetadata : CoreModel

@property (nonatomic, strong) NSArray<OOSAccessKeyMember *> * _Nullable members;

@end

@interface OOSListAccessKeysResult : CoreModel

@property (nonatomic, strong) NSString * _Nullable userName;
@property (nonatomic, strong) NSString * _Nullable isTruncated;
@property (nonatomic, strong) NSString * _Nullable marker;
@property (nonatomic, strong) OOSAccessKeyMetadata * _Nullable accessKeyMetadata;

@end

@interface OOSListAccessKeysResponse : CoreModel

@property (nonatomic, strong) OOSListAccessKeysResult * _Nullable listAccessKeysResult;
@property (nonatomic, strong) OOSResponseMetadata * _Nullable responseMetadata;

@end

@interface OOSListAccessKeyOutput : CoreModel

@property (nonatomic, strong) OOSListAccessKeysResponse * _Nullable listAccessKeysResponse;

@end


@interface OOSGetBucketLocationRequest : OOSRequest

@property (nonatomic, strong) NSString * _Nullable bucket;

@end

@interface OOSGetBucketLocationOutput : CoreModel

@property (nonatomic, strong) OOSCreateBucketConfiguration * _Nullable createBucketConfiguration;

@end

@interface OOSGetRegionsRequest : OOSRequest

@end

@interface OOSMetadataRegions : CoreModel

@property (nonatomic, strong) NSArray<NSString *> * _Nullable regions;

@end

@interface OOSDataRegions : CoreModel

@property (nonatomic, strong) NSArray<NSString *> * _Nullable regions;

@end

@interface OOSBucketRegions : CoreModel
@property (nonatomic, strong) OOSMetadataRegions * _Nullable metadataRegions;
@property (nonatomic, strong) OOSDataRegions * _Nullable dataRegions;
@end

@interface OOSGetRegionsOutput : CoreModel
@property (nonatomic, strong) OOSBucketRegions * _Nullable bucketRegions;
@end

NS_ASSUME_NONNULL_END
