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

#import "ClassBaseObject.h"
#import "ClassPropertiesObject.h"
#import "NSString+Nerdery.h"
#import "OutputLanguageWriterObjectiveC.h"
#import "OutputLanguageWriterJava.h"

@interface ClassBaseObject ()

@end

@implementation ClassBaseObject

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.properties = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (NSDictionary *)outputStringsWithType:(OutputLanguage)type  {
    id<OutputLanguageWriterProtocol> writer = nil;
    
    
    
    if (type == OutputLanguageObjectiveC) {
        writer = [OutputLanguageWriterObjectiveC new];
    } else if (type == OutputLanguageJava) {
        writer = [OutputLanguageWriterJava new];
    }
    
    return [writer getOutputFilesForClassObject:self];
}

#pragma mark - NSCoding methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    self.className = [aDecoder decodeObjectForKey:@"className"];
    self.baseClass = [aDecoder decodeObjectForKey:@"baseClass"];
    self.properties = [aDecoder decodeObjectForKey:@"properties"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_className forKey:@"className"];
    [aCoder encodeObject:_baseClass forKey:@"baseClass"];
    [aCoder encodeObject:_properties forKey:@"properties"];    
}

@end
