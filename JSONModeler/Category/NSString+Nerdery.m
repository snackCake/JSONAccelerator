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

#import "NSString+Nerdery.h"

@implementation NSString (Nerdery)

- (NSString *)capitalizeFirstCharacter {
    if (self.length == 0) {
        return @"";
    } else if (self.length == 1) {
        return self.capitalizedString;
    }
    
    NSString *uppercase = self.uppercaseString;
    NSString *firstLetter = [uppercase substringToIndex:1];
    NSString *restOfString = [self substringFromIndex:1];
    return [NSString stringWithFormat:@"%@%@", firstLetter, restOfString];
}

- (NSString *)uncapitalizeFirstCharacter
{    
    if (self.length == 0) {
        return @"";
    } else if (self.length == 1) {
        return self.lowercaseString;
    }
    
    NSString *lowercase = self.lowercaseString;
    NSString *firstLetter = [lowercase substringToIndex:1];
    NSString *restOfString = [self substringFromIndex:1];
    return [NSString stringWithFormat:@"%@%@", firstLetter, restOfString];
}

- (NSString *)alphanumericStringIsReservedWord:(BOOL *)reserved fromReservedWordSet:(NSSet *)reservedWords {
    BOOL isReservedWord = NO;
    
    NSString *alphanumericString = [self uppercaseCamelcaseString];
    
    // Check to see if it's a reserved word
    // We'll match the lowercase version of alphanumericString adgainst all lowercase versions of reserved words.
    // This will prevent property names like `Null` or `yes` (in Obj-C) from slipping through the cracks. 
    NSMutableSet *lowercaseReservedWords = [[NSMutableSet alloc] init];
    [reservedWords enumerateObjectsUsingBlock:^(NSString *word, BOOL *stop) {
        [lowercaseReservedWords addObject:word.lowercaseString];
    }];
    
    if ([lowercaseReservedWords containsObject:alphanumericString.lowercaseString]) {
        isReservedWord = YES;
    }
    
    if (NULL != reserved) {
        *reserved = isReservedWord;
    }
    
    return alphanumericString;
}

- (NSString *)underscoreDelimitedString {
    NSMutableString *mutableSelf = [self mutableCopy];
    while ([mutableSelf rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location != NSNotFound) {
        NSRange uppercaseRange = [mutableSelf rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]];
        NSString *lowercase = [mutableSelf substringWithRange:uppercaseRange].lowercaseString;
        
        if (uppercaseRange.location == 0) {
            [mutableSelf replaceCharactersInRange:uppercaseRange withString:[NSString stringWithFormat:@"%@", lowercase]];
        } else {
            [mutableSelf replaceCharactersInRange:uppercaseRange withString:[NSString stringWithFormat:@"_%@", lowercase]];
        }
    }
    
    return [NSString stringWithString:mutableSelf];
}

- (NSString *)uppercaseCamelcaseString {
    /* Remove any non-alphanumeric characters.
     * This uses a custom (very strict) character set instead of +alphanumericCharacterSet
     * so that characters like é don't appear in class/property names.
     */
    NSCharacterSet *nonAlphanumericCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"].invertedSet;
    NSMutableArray *components = [NSMutableArray arrayWithArray:[self componentsSeparatedByCharactersInSet:nonAlphanumericCharacterSet]];
    NSUInteger componentCount = components.count;
    
    for (NSUInteger i = 0; i < componentCount; ++i) {
        components[i] = [components[i] capitalizeFirstCharacter];
    }
    
    return [components componentsJoinedByString:@""];
}

- (NSString *)lowercaseCamelcaseString {
    return [[self uppercaseCamelcaseString] uncapitalizeFirstCharacter];
}

@end
