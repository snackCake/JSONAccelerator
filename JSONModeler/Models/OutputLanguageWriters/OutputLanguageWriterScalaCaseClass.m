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
#import "OutputLanguageWriterScalaCaseClass.h"
#import "ClassBaseObject.h"

static NSString *const kScalaString = @"String";
static NSString *const kScalaBool = @"Boolean";
static NSString *const kScalaInt = @"Int";
static NSString *const kScalaDouble = @"Double";
static NSString *const kScalaAny = @"Any";

@interface OutputLanguageWriterScalaCaseClass ()

- (NSString *)scalaTypeForProperty:(ClassPropertiesObject *)property;
- (void)updateImportsForTemplate:(NSMutableString *)templateString jsonLibrary:(JsonLibrary)jsonLibrary;
- (void)updateCompanionObjectForTemplate:(NSMutableString *)templateString
                             jsonLibrary:(JsonLibrary)jsonLibrary
                             classObject:(ClassBaseObject *)classObject;
- (void)updateFieldsForTemplate: (NSMutableString *)templateString class:(ClassBaseObject *)classObject;

@end

@implementation OutputLanguageWriterScalaCaseClass

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
                case PropertyTypeString:
                    collectionType = kScalaString;
                    break;
                case PropertyTypeInt:
                    collectionType = kScalaInt;
                    break;
                case PropertyTypeBool:
                    collectionType = kScalaBool;
                    break;
                case PropertyTypeDouble:
                    collectionType = kScalaDouble;
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
            scalaType = kScalaString;
            break;
        case PropertyTypeInt:
            scalaType = kScalaInt;
            break;
        case PropertyTypeBool:
            scalaType = kScalaBool;
            break;
        case PropertyTypeDouble:
            scalaType = kScalaDouble;
            break;
        case PropertyTypeClass:
            scalaType = property.referenceClass.className;
            break;
        case PropertyTypeOther:
            scalaType = property.otherType == nil ? kScalaAny : property.otherType;
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
- (NSString *)buildSourceImplementationFileForClassObject:(ClassBaseObject *)classObject
                                             package:(NSString *)packageName
                                             options:(NSDictionary *)options {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSError *error = nil;
    NSString *interfaceTemplatePath = [mainBundle pathForResource:@"ScalaCaseClassTemplate" ofType:@"txt"];
    NSMutableString *templateString = [[NSMutableString alloc] initWithContentsOfFile:interfaceTemplatePath
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:&error];
    if (error) {
        NSLog(@"Failed to load ScalaCaseClassTemplate.txt. This may imply the application is corrupted. Error: %@", error);
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

    JsonLibrary jsonLibrary = (JsonLibrary)((NSNumber *)options[kWritingOptionJsonLibrary]).unsignedIntegerValue;

    [self updateImportsForTemplate:templateString jsonLibrary:jsonLibrary];
    [self updateCompanionObjectForTemplate:templateString jsonLibrary:jsonLibrary classObject:classObject];
    [self updateFieldsForTemplate:templateString class:classObject];
    
    return [NSString stringWithString:templateString];
}

/**
 * @return filename format string for Scala
 */
- (NSString *)filenameFormat {
    return @"%@.scala";
}

#pragma mark Internal methods

- (void)updateImportsForTemplate:(NSMutableString *)templateString jsonLibrary:(JsonLibrary)jsonLibrary {
    NSString *importBlock = nil;
    
    switch (jsonLibrary) {
        case JsonLibraryScalaPlay:
            importBlock = @"\nimport play.api.libs.json._\n";
            break;
        case JsonLibraryScalaAkkaHttpSpray:
            importBlock = @"\nimport akka.http.scaladsl.marshallers.sprayjson.SprayJsonSupport\nimport spray.json.DefaultJsonProtocol\n";
            break;
        default:
            importBlock = @"";
            break;
    }
    
    [templateString replaceOccurrencesOfString:@"{IMPORTBLOCK}"
                                    withString:importBlock
                                       options:0
                                         range:NSMakeRange(0, templateString.length)];
}

- (void)updateFieldsForTemplate:(NSMutableString *)templateString class:(ClassBaseObject *)classObject {
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
}

- (void)updateCompanionObjectForTemplate:(NSMutableString *)templateString
                             jsonLibrary:(JsonLibrary)jsonLibrary
                             classObject:(ClassBaseObject *)classObject
{
    NSString *companionObjectTemplatePath = [[NSBundle mainBundle] pathForResource:@"ScalaCompanionObjectTemplate" ofType:@"txt"];
    NSString *formatFunction = nil;
    NSMutableString *companionObjectString = nil;
    NSError *error = nil;
    NSString *extends = nil;
    
    switch (jsonLibrary) {
        case JsonLibraryScalaPlay:
            formatFunction = [NSString stringWithFormat:@"Json.format[%@]", classObject.className];
            companionObjectString = [[NSMutableString alloc] initWithContentsOfFile:companionObjectTemplatePath
                                                                           encoding:NSUTF8StringEncoding
                                                                              error:&error];
            extends = @"";
            break;
        case JsonLibraryScalaAkkaHttpSpray:
            formatFunction = [NSString stringWithFormat:@"jsonFormat%lu(%@.apply)", classObject.properties.count, classObject.className];
            companionObjectString = [[NSMutableString alloc] initWithContentsOfFile:companionObjectTemplatePath
                                                                           encoding:NSUTF8StringEncoding
                                                                              error:&error];
            extends = @"extends SprayJsonSupport with DefaultJsonProtocol ";
            break;
        default:
            companionObjectString = [NSMutableString string];
            formatFunction = @"";
            extends = @"";
            break;
    }
    if (error) {
        NSLog(@"Failed to load ScalaCompanionObjectTemplate.txt. This may imply the application is corrupted. Error: %@", error);
        return;
    }
    
    if (companionObjectString) {
        [companionObjectString replaceOccurrencesOfString:@"{FORMATFUNCTION}"
                                               withString:formatFunction
                                                  options:0
                                                    range:NSMakeRange(0, companionObjectString.length)];
        
        [companionObjectString replaceOccurrencesOfString:@"{CLASSNAME}"
                                               withString:classObject.className
                                                  options:0
                                                    range:NSMakeRange(0, companionObjectString.length)];
        
        [companionObjectString replaceOccurrencesOfString:@"{OBJECTEXTENDS}"
                                               withString:extends
                                                  options:0
                                                    range:NSMakeRange(0, companionObjectString.length)];

        [templateString replaceOccurrencesOfString:@"{COMPANIONOBJECT}"
                                        withString:companionObjectString
                                           options:0
                                             range:NSMakeRange(0, templateString.length)];
    }
}

@end
