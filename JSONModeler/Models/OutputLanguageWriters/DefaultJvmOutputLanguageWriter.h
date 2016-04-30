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

/**
 * DefaultJvmOutputLanguageWriter is an abstract JVM subclass of DefaultOutputLanguageWriter that handles common functionality
 * of JVM output writers (e.g. Java and Scala).
 */
@interface DefaultJvmOutputLanguageWriter : DefaultOutputLanguageWriter

#pragma mark Protected / Abstract

/**
 * A format string that can be used to build a filename for a classname. It should take one NSObject paramater (%@). This method must
 * be implemented by subclasses.
 */
@property (NS_NONATOMIC_IOSONLY, readonly) NSString *filenameFormat;

/**
 * Build source code for a class, in the given package, with the given options. This method must be implemented by subclasses.
 */
- (NSString *)buildSourceImplementationFileForClassObject:(ClassBaseObject *)classObject
                                                  package:(NSString *)packageName
                                                  options:(NSDictionary *)options;

#pragma mark Protected / Implemented

/**
 * Write the given source code to the path at the given URL, with the given filename. This method has a default implementation, but may be
 * overridden to support more complex functionality.
 */
- (void)writeSource:(NSString *)source
              toURL:(NSURL *)url
           filename:(NSString *)filename
              error:(NSError **)error;

@end
