//
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

#import "DefaultJvmOutputLanguageWriter.h"
#import "ClassBaseObject.h"

@interface DefaultJvmOutputLanguageWriter ()

- (NSString *)findPackageForOptions:(NSDictionary *)options;
- (void)ensureUniqueClassNameForClass:(ClassBaseObject*)base files:(NSArray *)files options:(NSDictionary *)options;

@end

@implementation DefaultJvmOutputLanguageWriter

#pragma mark Protected / Abstract

- (NSString *)buildSourceImplementationFileForClassObject:(ClassBaseObject *)classObject
                                             package:(NSString *)packageName
                                             options:(NSDictionary *) options {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString *)filenameFormat {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark OutputLanguageWriter implementation

/**
 * Generates JVM files and writes to disk.
 */
- (BOOL)writeClassObjects:(NSDictionary *)classObjectsDict toURL:(NSURL *)url options:(NSDictionary *)options generatedError:(BOOL *)generatedErrorFlag {
    BOOL filesHaveHadError = NO;
    BOOL filesHaveBeenWritten = NO;
    
    NSArray *files = classObjectsDict.allValues;
    
    NSString *packageName = [self findPackageForOptions:options];
    
    for (ClassBaseObject *base in files) {
        [self ensureUniqueClassNameForClass:base files:files options:options];
        
        /* Write the source file to disk */
        NSError *error;
        NSString *outputString = [self buildSourceImplementationFileForClassObject:base package:packageName options:options];

        NSString *filename = [NSString stringWithFormat:self.filenameFormat, base.className];
        [self writeSource:outputString toURL:url filename:filename error:&error];

        if (error) {
            DLog(@"%@", [error localizedDescription]);
            filesHaveHadError = YES;
        } else {
            filesHaveBeenWritten = YES;
        }
    }
    
    /* Return the error flag (by reference) */
    *generatedErrorFlag = filesHaveHadError;
    
    return filesHaveBeenWritten;
}

#pragma mark Protected / Implemented

- (void)writeSource:(NSString *)source toURL:(NSURL *)url filename:(NSString *)filename error:(NSError **)error {
    [source writeToURL:[url URLByAppendingPathComponent:filename]
            atomically:YES
              encoding:NSUTF8StringEncoding
                 error:error];
}

#pragma mark Private

- (NSString *)findPackageForOptions:(NSDictionary *)options {
    return (nil == options[kJvmWritingOptionPackageName]) ? kDefaultJvmPackageName : options[kJvmWritingOptionPackageName];
}

// This section is to guard against people going through and renaming the class
// to something that has already been named.
// This will check the class name and keep appending an additional number until something has been found
- (void)ensureUniqueClassNameForClass:(ClassBaseObject*)base files:(NSArray *)files options:(NSDictionary *)options {
    if ([base.className isEqualToString:@"InternalBaseClass"]) {
        NSString *newBaseClassName;
        
        if (nil != options[kJvmWritingOptionBaseClassName]) {
            newBaseClassName = options[kJvmWritingOptionBaseClassName];
        } else {
            newBaseClassName = @"BaseClass";
        }
        BOOL hasUniqueFileNameBeenFound = NO;
        NSUInteger classCheckInteger = 2;
        
        while (hasUniqueFileNameBeenFound == NO) {
            hasUniqueFileNameBeenFound = YES;
            
            for (ClassBaseObject *collisionBaseObject in files) {
                if ([collisionBaseObject.className isEqualToString:newBaseClassName]) {
                    hasUniqueFileNameBeenFound = NO;
                }
            }
            
            if (hasUniqueFileNameBeenFound == NO) {
                newBaseClassName = [NSString stringWithFormat:@"%@%li", newBaseClassName, classCheckInteger];
                classCheckInteger++;
            }
        }
        
        base.className = newBaseClassName;
    }
}

@end
