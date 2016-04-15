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

#import "JSONModeler.h"
#import "ClassBaseObject.h"
#import "ClassPropertiesObject.h"
#import "NSString+Nerdery.h"
#import "OutputLanguageWriterProtocol.h"

#ifndef COMMAND_LINE
    #import "JSONFetcher.h"
#endif

@interface JSONModeler ()

@property (assign, nonatomic) NSInteger numberOfUnnamedClasses;
    
- (void)loadJSONWithData:(NSData *)data outputLanguageWriter:(id<OutputLanguageWriterProtocol>)writer;
- (ClassBaseObject *)parseData:(NSDictionary *)dict intoObjectsWithBaseObjectName:(NSString *)baseObjectName andBaseObjectClass:(NSString *)baseObjectClass outputLanguageWriter:(id<OutputLanguageWriterProtocol>)writer;

@end

@implementation JSONModeler

- (instancetype)init {
    self = [super init];
    
    
    
    if (self) {
        self.numberOfUnnamedClasses = 0;
    }
    
    return self;
}

#ifndef COMMAND_LINE
- (void)loadJSONWithURL:(NSString *)url outputLanguageWriter:(id<OutputLanguageWriterProtocol>)writer {
    JSONFetcher *fetcher = [[JSONFetcher alloc] init];
    [fetcher downloadJSONFromLocation:url withSuccess:^(id object) {
        [self loadJSONWithData:object outputLanguageWriter:writer];
    } 
   andFailure:^(NSHTTPURLResponse *response, NSError *error) {
       NSLog(@"An error occured here, but it's not too much trouble because this method is only used in debugging");
   }];
}

#endif

- (void)loadJSONWithString:(NSString *)string outputLanguageWriter:(id<OutputLanguageWriterProtocol>)writer {
    [self loadJSONWithData:[string dataUsingEncoding:NSUTF8StringEncoding] outputLanguageWriter:writer];
}

- (void)loadJSONWithData:(NSData *)data outputLanguageWriter:(id<OutputLanguageWriterProtocol>)writer {
    NSError *error = nil;    
    self.parsedDictionary = nil;
        
    //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    // Just for testing
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        self.rawJSONObject = object;
        self.parseComplete = NO;
        [self parseData:(NSDictionary *)self.rawJSONObject intoObjectsWithBaseObjectName:@"InternalBaseClass" andBaseObjectClass:@"NSObject" outputLanguageWriter:writer];
        self.parseComplete = YES;
    }
    
    if ([object isKindOfClass:[NSArray class]]) {
        self.parseComplete = NO;
        self.rawJSONObject = object;
        
        
        
        for (NSObject *arrayObject in (NSArray *)object) {
            
            if ([arrayObject isKindOfClass:[NSDictionary class]]) {
                [self parseData:(NSDictionary *)arrayObject intoObjectsWithBaseObjectName:@"InternalBaseClass" andBaseObjectClass:@"NSObject" outputLanguageWriter:writer];
            }
        }
        self.parseComplete = YES;
    }
}

#pragma mark - Create the model objects

- (ClassBaseObject *)parseData:(NSDictionary *)dict intoObjectsWithBaseObjectName:(NSString *)baseObjectName andBaseObjectClass:(NSString *)baseObjectClass outputLanguageWriter:(id<OutputLanguageWriterProtocol>)writer {
    
    if (self.parsedDictionary == nil) {
        self.parsedDictionary = [NSMutableDictionary dictionary];
    }

    ClassBaseObject *tempClass = nil;
    
    
    
    if ((self.parsedDictionary)[baseObjectName]) {
        tempClass = (self.parsedDictionary)[baseObjectName];
    } else {
        tempClass = [ClassBaseObject new];
        tempClass.baseClass = baseObjectClass;
        
        // Set the name of the class
        BOOL isReservedWord;
        NSString *tempClassName = [baseObjectName alphanumericStringIsReservedWord:&isReservedWord fromReservedWordSet:[writer reservedWords]];
        
        NSMutableArray *components = [[tempClassName componentsSeparatedByString:@"_"] mutableCopy];
        
        NSInteger numComponents = components.count;
        
        for (int i = 0; i < numComponents; ++i) {
            components[i] = [(NSString *)components[i] capitalizeFirstCharacter];
        }
        tempClassName = [components componentsJoinedByString:@""];
        
        
        
        
        
        if (isReservedWord) {
            tempClassName = [writer classNameForObject:tempClass fromReservedWord:tempClassName];
        }
        
        if ([tempClassName isEqualToString:@""]) {
            tempClassName = [NSString stringWithFormat:@"InternalBaseClass%lu", ++self.numberOfUnnamedClasses];
        }
        
        tempClass.className = tempClassName;
    }
    
    NSArray *array = dict.allKeys;
    ClassPropertiesObject *tempPropertyObject = nil;
    NSObject *tempObject = nil;
    NSObject *tempArrayObject = nil;
    
    NSUInteger numUnnamedProperties = 0;
    
    for (NSString *currentKey in array) {
        @autoreleasepool {
            tempPropertyObject = [ClassPropertiesObject new];
            tempPropertyObject.jsonName = currentKey;
            // Set the name of the property
            BOOL isReservedWord;
            NSString *tempPropertyName = [[currentKey alphanumericStringIsReservedWord:&isReservedWord fromReservedWordSet:[writer reservedWords]] uncapitalizeFirstCharacter];
            
            
            
            if (isReservedWord) {
                tempPropertyName = [writer propertyNameForObject:tempPropertyObject inClass:tempClass fromReservedWord:tempPropertyName];
            }
            
            if ([tempPropertyName isEqualToString:@""]) {
                tempPropertyName = [NSString stringWithFormat:@"myProperty%lu", ++numUnnamedProperties];
            }
            tempPropertyObject.name = tempPropertyName;
            
            [tempPropertyObject setIsAtomic:NO];
            [tempPropertyObject setIsClass:NO];
            [tempPropertyObject setIsReadWrite:YES];
            tempPropertyObject.semantics = SetterSemanticRetain;
            
            tempObject = dict[currentKey];
            
            BOOL shouldSetObject = YES;
            
            
            
            if (tempClass.properties[currentKey]) {
                shouldSetObject = NO;
            }
            
            
            if ([tempObject isKindOfClass:[NSArray class]]) {
                // NSArray Objects
                if (shouldSetObject == NO) {
                    if ([tempClass.properties[currentKey] isKindOfClass:[NSDictionary class]]) {
                        // Just in case it originally came in as a Dictionary and then later is shown as an array
                        // We should switch this to using an array.
                        shouldSetObject = YES;
                    }
                }
                
                tempPropertyObject.type = PropertyTypeArray;
                
                // We now need to check to see if the first object in the array is a NSDictionary
                // if it is, then we need to create a new class. Also, set the collection type for
                // the array (used by java)
                for (tempArrayObject in (NSArray *)tempObject) {
                    if ([tempArrayObject isKindOfClass:[NSDictionary class]]) {
                        ClassBaseObject *newClass = [self parseData:(NSDictionary *)tempArrayObject intoObjectsWithBaseObjectName:currentKey andBaseObjectClass:@"NSObject" outputLanguageWriter:writer];
                        tempPropertyObject.referenceClass = newClass;
                        tempPropertyObject.collectionType = PropertyTypeClass;
                        tempPropertyObject.collectionTypeString = newClass.className;
                    } else if ([tempArrayObject isKindOfClass:[NSString class]]) {
                        tempPropertyObject.collectionType = PropertyTypeString;
                    } else {
                        // Miscellaneous
                        NSString *classDecription = [[tempArrayObject class] description];
                        
                        
                        
                        if ([classDecription rangeOfString:@"NSCFNumber"].location != NSNotFound) {
                            tempPropertyObject.collectionType = PropertyTypeInt;
                        } else if ([classDecription rangeOfString:@"NSDecimalNumber"].location != NSNotFound) {
                            tempPropertyObject.collectionType = PropertyTypeDouble;
                        } else if ([classDecription rangeOfString:@"NSCFBoolean"].location != NSNotFound) {
                            tempPropertyObject.collectionType = PropertyTypeBool;
                        } else {
                            DLog(@"UNDEFINED TYPE: %@", [tempArrayObject class]);
                        }
                    }
                }
                
            } else if ([tempObject isKindOfClass:[NSString class]]) {
                // NSString Objects
                tempPropertyObject.type = PropertyTypeString;
                
            } else if ([tempObject isKindOfClass:[NSDictionary class]]) {
                // NSDictionary Objects
                [tempPropertyObject setIsClass:YES];
                tempPropertyObject.type = PropertyTypeClass;
                tempPropertyObject.referenceClass = [self parseData:(NSDictionary *)tempObject intoObjectsWithBaseObjectName:currentKey andBaseObjectClass:@"NSObject" outputLanguageWriter:writer];
                
            } else if ([tempObject isKindOfClass:[NSNull class]]) {
                tempPropertyObject.type = PropertyTypeOther;
                tempPropertyObject.semantics = SetterSemanticAssign;
                
            } else {
                // Miscellaneous
                NSNumber *number = (NSNumber *)tempObject;
                NSString *classDecription = [[tempObject class] description];
                BOOL isInteger = NO;
                BOOL isDouble = NO;
                
                if ([number isKindOfClass:[NSNull class]]) {
                    // Huh - that's interesting.
                    isDouble = YES;
                } else {
                    NSNumber *tempIntNumber = @(number.integerValue);
                    NSNumber *tempDoubleNumber = @(number.doubleValue);
                    
                    isDouble = [number.stringValue isEqualToString:tempDoubleNumber.stringValue];
                    isInteger = [number.stringValue isEqualToString:tempIntNumber.stringValue];
                }
                
                if ([classDecription rangeOfString:@"NSCFBoolean"].location != NSNotFound) {
                    tempPropertyObject.type = PropertyTypeBool;
                    tempPropertyObject.semantics = SetterSemanticAssign;
                } else if (isDouble) {
                    tempPropertyObject.type = PropertyTypeDouble;
                    tempPropertyObject.semantics = SetterSemanticAssign;
                } else if (isInteger) {
                    tempPropertyObject.type = PropertyTypeInt;
                    tempPropertyObject.semantics = SetterSemanticAssign;
                } else {
                    DLog(@"UNDEFINED TYPE: %@", [tempObject class]);
                }
                // This is undefined right now - add other if
            }
                        
            if (shouldSetObject) {
                tempClass.properties[currentKey] = tempPropertyObject;
            }
        }
    }
    
    (self.parsedDictionary)[baseObjectName] = tempClass;
    
    return tempClass;
}

- (NSDictionary *)parsedDictionaryByReplacingReservedWords:(NSArray *)reservedWords {
    if (self.parsedDictionary == nil) {
        return nil;
    }
    
    return nil;
}

#pragma mark - NSCoding methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [self init];
    self.rawJSONObject = [aDecoder decodeObjectForKey:@"rawJSONObject"];
    self.parsedDictionary = [aDecoder decodeObjectForKey:@"parsedDictionary"];
    self.parseComplete = [aDecoder decodeBoolForKey:@"parseComplete"];
    self.JSONString = [aDecoder decodeObjectForKey:@"JSONString"];
  
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_rawJSONObject forKey:@"rawJSONObject"];
    [aCoder encodeObject:_parsedDictionary forKey:@"parsedDictionary"];
    [aCoder encodeBool:_parseComplete forKey:@"parseComplete"];
    [aCoder encodeObject:_JSONString forKey:@"JSONString"];
}

@end
