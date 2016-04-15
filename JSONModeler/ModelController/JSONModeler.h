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

#import <Foundation/Foundation.h>

@protocol OutputLanguageWriterProtocol;

@interface JSONModeler : NSObject <NSCoding>

#ifndef COMMAND_LINE
    - (void)loadJSONWithURL:(NSString *)url outputLanguageWriter:(id<OutputLanguageWriterProtocol>)writer;
#endif
- (void)loadJSONWithString:(NSString *)string outputLanguageWriter:(id<OutputLanguageWriterProtocol>)writer;

@property (assign) BOOL parseComplete;
@property (strong) NSObject *rawJSONObject;
@property (strong) NSMutableDictionary *parsedDictionary;
@property (strong) NSString *JSONString;

- (NSDictionary *)parsedDictionaryByReplacingReservedWords:(NSArray *)reservedWords;

@end
