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
#import "OutputLanguageWriterScalaPlayCaseClass.h"
#import "ClassBaseObject.h"

@interface OutputLanguageWriterScalaPlayCaseClass ()

- (NSString *)scalaTypeForProperty:(ClassPropertiesObject *)property;

@end

@implementation OutputLanguageWriterScalaPlayCaseClass

#pragma mark OutputLanguageWriterProtocol

/**
 * @return Set of reserved words for Scala
 */
- (NSSet *)reservedWords {
    return [NSSet setWithObjects:@"abstract", @"case", @"catch", @"class", @"def", @"do", @"else", @"extends", @"false", @"final",
            @"finally", @"for", @"forSome", @"if", @"implicit", @"import", @"lazy", @"match", @"new", @"null", @"object", @"override",
            @"package", @"private", @"protected", @"return", @"sealed", @"super", @"this", @"throw", @"trait", @"try", @"true", @"type",
            @"val", @"var", @"while", @"with", @"yield", @"_", @":", @"=", @"=>", @"<-", @"<:", @"<%", @">:", @"#", @"@", nil];
}

#pragma mark Scala internal methods

- (NSString *)scalaTypeForProperty:(ClassPropertiesObject *)property {
    NSString *scalaType = nil;
    switch (property.type) {
        case PropertyTypeArray: {
            
            NSString *collectionType = nil;
            //Special case, switch over the collection type
            switch (property.collectionType) {
                case PropertyTypeClass:
                    collectionType = property.collectionTypeString;
                    break;
                    // TODO: All this duplication is kind of gross and it would be nice to refactor it.
                case PropertyTypeString:
                    collectionType = @"String";
                    break;
                case PropertyTypeInt:
                    collectionType = @"Int";
                    break;
                case PropertyTypeBool:
                    collectionType = @"Boolean";
                    break;
                case PropertyTypeDouble:
                    collectionType = @"Double";
                    break;
                default:
                    NSLog(@"Warning: scalaTypeForType got invalid collection type: %d for property: %@",
                          property.collectionType, property.name);
                    break;
            }
            scalaType = [NSString stringWithFormat:@"Seq[%@]", collectionType];
            break;
        }
        case PropertyTypeDictionary:
            break;
        case PropertyTypeString:
            scalaType = @"String";
            break;
        case PropertyTypeInt:
            scalaType = @"Int";
            break;
        case PropertyTypeBool:
            scalaType = @"Boolean";
            break;
        // TODO: It seems like Double is being triggered when Int should be.
        case PropertyTypeDouble:
            scalaType = @"Double";
            break;
        case PropertyTypeClass:
            scalaType = property.referenceClass.className;
            break;
        case PropertyTypeOther:
            scalaType = property.otherType;
            break;
        default:
            NSLog(@"Warning: scalaTypeForType got invalid type: %d", property.type);
            break;
    }
    return scalaType;
}

#pragma mark DefaultJvmOutputLanguageWriter support

/**
 * @return Scala case class source code.
 */
- (NSString *)sourceImplementationFileForClassObject:(ClassBaseObject *)classObject package:(NSString *)packageName {
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSError *error = nil;
    NSString *interfaceTemplate = [mainBundle pathForResource:@"ScalaPlayCaseClassTemplate" ofType:@"txt"];
    NSMutableString *templateString = [[NSMutableString alloc] initWithContentsOfFile:interfaceTemplate
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:&error];
    if (error) {
        NSLog(@"Failed to load ScalaPlayCaseClassTemplate.txt. This may imply the application is corrupted. Error: %@", error);
        return @"";
    }
    
    [templateString replaceOccurrencesOfString:@"{PACKAGENAME}"
                                    withString:packageName
                                       options:0
                                         range:NSMakeRange(0, templateString.length)];
    
    [templateString replaceOccurrencesOfString:@"{CLASSNAME}"
                                    withString:classObject.className
                                       options:0
                                         range:NSMakeRange(0, templateString.length)];
    
    // TODO: Add options to make this know what to import, based on use of Play or some other JSON library.
    // TODO: Change the class and template names to reflect that Play isn't required.
    NSString *importBlock = @"";
    [templateString replaceOccurrencesOfString:@"{IMPORTBLOCK}"
                                    withString:importBlock
                                       options:0
                                         range:NSMakeRange(0, templateString.length)];
    
    NSMutableString *fieldsString = [NSMutableString string];
    
    for (ClassPropertiesObject *property in (classObject.properties).allValues) {
        [fieldsString appendFormat:@"%@: %@, ", property.name, [self scalaTypeForProperty:property]];
    }
    if (fieldsString.length > 2) {
        // Remove ", " from the end.
        [fieldsString deleteCharactersInRange:NSMakeRange(fieldsString.length - 2, 2)];
    }
    [templateString replaceOccurrencesOfString:@"{FIELDS}"
                                    withString:fieldsString
                                       options:0
                                         range:NSMakeRange(0, templateString.length)];
    
    return [NSString stringWithString:templateString];
}

/**
 * @return filename format string for Scala
 */
- (NSString *)filenameFormat {
    return @"%@.scala";
}

@end
