//
//  XMLDictionary.h
//
//  Version 1.4
//
//  Created by Nick Lockwood on 15/11/2010.
//  Copyright 2010 Charcoal Design. All rights reserved.
//
//  Get the latest version of XMLDictionary from here:
//
//  https://github.com/nicklockwood/XMLDictionary
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <Foundation/Foundation.h>
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"


typedef NS_ENUM(NSInteger, OOSXMLDictionaryAttributesMode)
{
    OOSXMLDictionaryAttributesModePrefixed = 0, //default
    OOSXMLDictionaryAttributesModeDictionary,
    OOSXMLDictionaryAttributesModeUnprefixed,
    OOSXMLDictionaryAttributesModeDiscard
};


typedef NS_ENUM(NSInteger, OOSXMLDictionaryNodeNameMode)
{
    OOSXMLDictionaryNodeNameModeRootOnly = 0, //default
    OOSXMLDictionaryNodeNameModeAlways,
    OOSXMLDictionaryNodeNameModeNever
};


static NSString *const OOSXMLDictionaryAttributesKey   = @"__attributes";
static NSString *const OOSXMLDictionaryCommentsKey     = @"__comments";
static NSString *const OOSXMLDictionaryTextKey         = @"__text";
static NSString *const OOSXMLDictionaryNodeNameKey     = @"__name";
static NSString *const OOSXMLDictionaryAttributePrefix = @"_";


@interface OOSXMLDictionaryParser : NSObject <NSCopying>

+ (OOSXMLDictionaryParser *)sharedInstance;

@property (nonatomic, assign) BOOL collapseTextNodes; // defaults to YES
@property (nonatomic, assign) BOOL stripEmptyNodes;   // defaults to YES
@property (nonatomic, assign) BOOL trimWhiteSpace;    // defaults to YES
@property (nonatomic, assign) BOOL alwaysUseArrays;   // defaults to NO
@property (nonatomic, assign) BOOL preserveComments;  // defaults to NO
@property (nonatomic, assign) BOOL wrapRootNode;      // defaults to NO

@property (nonatomic, assign) OOSXMLDictionaryAttributesMode attributesMode;
@property (nonatomic, assign) OOSXMLDictionaryNodeNameMode nodeNameMode;

- (NSDictionary *)dictionaryWithParser:(NSXMLParser *)parser;
- (NSDictionary *)dictionaryWithData:(NSData *)data;
- (NSDictionary *)dictionaryWithString:(NSString *)string;
- (NSDictionary *)dictionaryWithFile:(NSString *)path;

@end


@interface NSDictionary (OOSXMLDictionary)

+ (NSDictionary *)OOSxml_dictionaryWithXMLParser:(NSXMLParser *)parser;
+ (NSDictionary *)OOSxml_dictionaryWithXMLData:(NSData *)data;
+ (NSDictionary *)OOSxml_dictionaryWithXMLString:(NSString *)string;
+ (NSDictionary *)OOSxml_dictionaryWithXMLFile:(NSString *)path;

- (NSDictionary *)OOSxml_attributes;
- (NSDictionary *)OOSxml_childNodes;
- (NSArray *)OOSxml_comments;
- (NSString *)OOSxml_nodeName;
- (NSString *)OOSxml_innerText;
- (NSString *)OOSxml_innerXML;
- (NSString *)OOSxml_XMLString;

- (NSArray *)OOSxml_arrayValueForKeyPath:(NSString *)keyPath;
- (NSString *)OOSxml_stringValueForKeyPath:(NSString *)keyPath;
- (NSDictionary *)OOSxml_dictionaryValueForKeyPath:(NSString *)keyPath;

@end


@interface NSString (OOSXMLDictionary)

- (NSString *)OOSxml_XMLEncodedString;

@end


#pragma GCC diagnostic pop
