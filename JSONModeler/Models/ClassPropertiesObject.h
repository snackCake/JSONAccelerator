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

@class ClassBaseObject;

typedef NS_ENUM(unsigned int, SetterSemantics) {
    SetterSemanticStrong = 0,
    SetterSemanticWeak,
    SetterSemanticCopy,
    SetterSemanticAssign,
    SetterSemanticRetain
};

typedef NS_ENUM(unsigned int, PropertyType) {
    PropertyTypeString = 0,
    PropertyTypeArray,
    PropertyTypeDictionary,
    PropertyTypeInt,
    PropertyTypeDouble,
    PropertyTypeBool,
    PropertyTypeClass,
    PropertyTypeOther
};

@interface ClassPropertiesObject : NSObject <NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *jsonName;
@property (nonatomic, assign) PropertyType type;
@property (nonatomic, copy) NSString *otherType;

/* The following 2 properties are used when the instance represents a collection (e.g., ArrayList in java) and needs a secondary class type (e.g. ArrayList<String>) */
@property (nonatomic, assign) PropertyType collectionType;
@property (nonatomic, copy) NSString *collectionTypeString;

@property (weak) ClassBaseObject *referenceClass;

@property (assign) BOOL isClass;
@property (assign) BOOL isAtomic;
@property (assign) BOOL isReadWrite;
@property (assign) SetterSemantics semantics;

@end
