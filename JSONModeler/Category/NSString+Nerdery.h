// Copyright 2016 The Nerdery, LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <Foundation/Foundation.h>

@interface NSString (Nerdery)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *capitalizeFirstCharacter;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *uncapitalizeFirstCharacter;

/**
 * Returns a string by removing all characters except those in the set [A-Za-z0-9_]. Also returns by reference a BOOL that indicates whether the returned string is one of the words in the set `reservedWords`. Note: this method will return the empty string if the receiver consists entirely of characters outside the alphanumeric set.
 *
 * @param reserved Pointer to a boolean that indicates whether the returned string is an Objective-C reserved word
 * @param reservedWords Set of `NSString`s that are reserved words in a given language. The `reserved` flag will be set if the returned string matches any string in this set
 * @return NSString * String created by taking the value of the receiver and removing all characters except those in the set [A-Za-z0-9_]. Can be the empty string.
 */
- (NSString *)alphanumericStringIsReservedWord:(BOOL *)reserved fromReservedWordSet:(NSSet *)reservedWords;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *underscoreDelimitedString;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *uppercaseCamelcaseString;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *lowercaseCamelcaseString;

@end
