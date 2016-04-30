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

#import "DefaultOutputLanguageWriter.h"

static NSString *const kJvmWritingOptionBaseClassName = @"kJvmWritingOptionBaseClassName";
static NSString *const kJvmWritingOptionPackageName = @"kJvmWritingOptionPackageName";
static NSString *const kDefaultJvmPackageName = @"com.MYCOMPANY.MYPROJECT.model";

@interface DefaultJvmOutputLanguageWriter : DefaultOutputLanguageWriter

#pragma mark Protected

@property (NS_NONATOMIC_IOSONLY, readonly) NSString *filenameFormat;

- (NSString *)findPackageForOptions:(NSDictionary *)options;
- (void)ensureUniqueClassNameForClass:(ClassBaseObject*)base files:(NSArray *)files options:(NSDictionary *)options;
- (void)writeSource:(NSString *)source toURL:(NSURL *)url filename:(NSString *)filename error:(NSError **)error;
- (NSString *)sourceImplementationFileForClassObject:(ClassBaseObject *)classObject
                                             package:(NSString *)packageName
                                             options:(NSDictionary *)options;

@end
