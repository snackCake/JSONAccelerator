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

#import "ClassPropertiesObject.h"
#import "ClassBaseObject.h"
#import "NSString+Nerdery.h"
#import "OutputLanguageWriterObjectiveC.h"

@interface ClassPropertiesObject ()

@end

@implementation ClassPropertiesObject

// Builds the header implementation and is convienient for debugging
- (NSString *)description {
    OutputLanguageWriterObjectiveC *writer = [[OutputLanguageWriterObjectiveC alloc] init];
    
    return [writer propertyForProperty:self];
}

#pragma mark - NSCoding methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.jsonName = [aDecoder decodeObjectForKey:@"jsonName"];
    self.type = [aDecoder decodeIntForKey:@"type"];
    self.otherType = [aDecoder decodeObjectForKey:@"otherType"];
    
    self.collectionType = [aDecoder decodeIntForKey:@"collectionType"];
    self.collectionTypeString = [aDecoder decodeObjectForKey:@"collectionTypeString"];
    
    self.referenceClass = [aDecoder decodeObjectForKey:@"referenceClass"];
    
    self.isClass = [aDecoder decodeBoolForKey:@"isClass"];
    self.isAtomic = [aDecoder decodeBoolForKey:@"isAtomic"];
    self.isReadWrite = [aDecoder decodeBoolForKey:@"isReadWrite"];
    self.semantics = [aDecoder decodeIntForKey:@"semantics"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_jsonName forKey:@"jsonName"];
    [aCoder encodeInt:_type forKey:@"type"];
    [aCoder encodeObject:_otherType forKey:@"otherType"];
    
    [aCoder encodeInt:_collectionType forKey:@"collectionType"];
    [aCoder encodeObject:_collectionTypeString forKey:@"collectionTypeString"];
    
    [aCoder encodeObject:_referenceClass forKey:@"referenceClass"];
    
    [aCoder encodeBool:_isClass forKey:@"isClass"];
    [aCoder encodeBool:_isAtomic forKey:@"isAtomic"];
    [aCoder encodeBool:_isReadWrite forKey:@"isReadWrite"];
    [aCoder encodeInt:_semantics forKey:@"semantics"];
    
}

@end
