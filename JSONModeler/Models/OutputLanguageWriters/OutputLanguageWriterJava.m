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

#import "OutputLanguageWriterJava.h"
#import "ClassBaseObject.h"
#import "ClassPropertiesObject.h"
#import "NSString+Nerdery.h"

@interface OutputLanguageWriterJava ()

- (NSString *)setterMethodForProperty:(ClassPropertiesObject *) property;

@end

@implementation OutputLanguageWriterJava

//@synthesize classObject = _classObject;

#pragma mark - File Writing Methods

/**
 * @return filename format string for Java
 */
- (NSString *)filenameFormat {
    return @"%@.java";
}

- (void)writeSource:(NSString *)source toURL:(NSURL *)url filename:(NSString *)filename error:(NSError **)error {

#ifndef COMMAND_LINE
    [super writeSource:source toURL:url filename:filename error:error];
#else
    [source writeToFile:[[url URLByAppendingPathComponent:filename] absoluteString]
                   atomically:YES
                     encoding:NSUTF8StringEncoding
                        error:error];
#endif
}

- (NSDictionary *)getOutputFilesForClassObject:(ClassBaseObject *)classObject {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSString *sourceString = [self buildSourceImplementationFileForClassObject:classObject package:kDefaultJvmPackageName options: nil];
    dict[[NSString stringWithFormat:self.filenameFormat, classObject.className]] = sourceString;
    
    return [NSDictionary dictionaryWithDictionary:dict];
    
}

- (NSString *)buildSourceImplementationFileForClassObject:(ClassBaseObject *)classObject
                                             package:(NSString *)packageName
                                             options:(NSDictionary *)options {
#ifndef COMMAND_LINE
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSString *interfaceTemplate = [mainBundle pathForResource:@"JavaTemplate" ofType:@"txt"];
    NSString *templateString = [[NSString alloc] initWithContentsOfFile:interfaceTemplate encoding:NSUTF8StringEncoding error:nil];
#else
    NSString *templateString = @"package {PACKAGENAME};\n\nimport org.json.*;\n{IMPORTBLOCK}\n\npublic class {CLASSNAME} {\n	\n    {PROPERTIES}\n    \n	public {CLASSNAME} () {\n		\n	}	\n        \n    public {CLASSNAME} (JSONObject json) {\n    \n{SETTERS}\n    }\n    \n{GETTER_SETTER_METHODS}\n    \n}\n";
#endif
    // Define the package name in each file.
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{PACKAGENAME}" withString:packageName];

    templateString = [templateString stringByReplacingOccurrencesOfString:@"{CLASSNAME}" withString:classObject.className];
    
    // Flag if class has an ArrayList type property (used for generating the import block)
    BOOL containsArrayList = NO;
    
    // Public Properties
    NSString *propertiesString = @"";
    
    for (ClassPropertiesObject *property in (classObject.properties).allValues) {
        
        propertiesString = [propertiesString stringByAppendingString:[self propertyForProperty:property]];
        
        if (property.type == PropertyTypeArray) {
            containsArrayList = YES;
        }
    }
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{PROPERTIES}" withString:propertiesString];
    
    // Import Block
    if (containsArrayList) {
        templateString = [templateString stringByReplacingOccurrencesOfString:@"{IMPORTBLOCK}" withString:@"import java.util.ArrayList;"];
    } else {
        templateString = [templateString stringByReplacingOccurrencesOfString:@"{IMPORTBLOCK}" withString:@""];
    }
    
    // Constructor arguments
//    NSString *constructorArgs = @"";
//    for (ClassPropertiesObject *property in [classObject.properties allValues]) {
//        //Append a comma if not the first argument added to the string
//        if ( ![constructorArgs isEqualToString:@""] ) {
//            constructorArgs = [constructorArgs stringByAppendingString:@", "];
//        }
//        
//        constructorArgs = [constructorArgs stringByAppendingString:[NSString stringWithFormat:@"%@ %@", [self typeStringForProperty:property], property.name]];
//    }
//    
//    templateString = [templateString stringByReplacingOccurrencesOfString:@"{CONSTRUCTOR_ARGS}" withString:constructorArgs];
    
    
    // Setters strings   
    NSString *settersString = @"";
    
    for (ClassPropertiesObject *property in (classObject.properties).allValues) {
        NSString *setterForProperty = [self setterForProperty:property];
        settersString = [settersString stringByAppendingString:setterForProperty];
    }
    
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{SETTERS}" withString:settersString];    
    
    NSString *rawObject = @"rawObject";
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{OBJECTNAME}" withString:rawObject];
    
    
    // Getter/Setter Methods
    NSString *getterSetterMethodsString = @"";
    
    for (ClassPropertiesObject *property in (classObject.properties).allValues) {
        getterSetterMethodsString = [getterSetterMethodsString stringByAppendingString:[self getterForProperty:property]];
        getterSetterMethodsString = [getterSetterMethodsString stringByAppendingString:[self setterMethodForProperty:property]];
    }
    templateString = [templateString stringByReplacingOccurrencesOfString:@"{GETTER_SETTER_METHODS}" withString:getterSetterMethodsString];
    
    return templateString;
}

#pragma mark - Reserved Words Callbacks

- (NSSet *)reservedWords {
    return [NSSet setWithObjects:@"abstract", @"assert", @"boolean", @"break", @"byte", @"case", @"catch", @"char", @"class", @"const", @"continue", @"default", @"do", @"double", @"else", @"enum", @"extends", @"false", @"final", @"finally", @"float", @"for", @"goto", @"if", @"implements", @"import", @"instanceof", @"int", @"interface", @"long", @"native", @"new", @"null", @"package", @"private", @"protected", @"public", @"return", @"short", @"static", @"strictfp", @"super", @"switch", @"synchronized", @"this", @"throw", @"throws", @"transient", @"true", @"try", @"void", @"volatile", @"while", nil];
}

#pragma mark - Property Writing Methods

- (NSString *)propertyForProperty:(ClassPropertiesObject *)property {
    NSString *returnString = [NSString stringWithFormat:@"private %@ %@;\n    ", [self typeStringForProperty:property], property.name];
    
    return returnString;
}

- (NSString *)setterForProperty:(ClassPropertiesObject *)property {
    NSString *setterString = @"";
    
    if (property.isClass && (property.type == PropertyTypeDictionary || property.type == PropertyTypeClass)) {
        setterString = [setterString stringByAppendingFormat:@"        this.%@ = new %@(json.optJSONObject(\"%@\"));\n", property.name, property.referenceClass.className, property.jsonName];
    } else if (property.type == PropertyTypeArray) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        
        
        
        if (nil != property.referenceClass) {
#ifndef COMMAND_LINE
            NSString *arrayTemplate = [mainBundle pathForResource:@"JavaArrayTemplate" ofType:@"txt"];
            NSString *templateString = [[NSString alloc] initWithContentsOfFile:arrayTemplate encoding:NSUTF8StringEncoding error:nil];
#else
            NSString *templateString = @"\n        this.{PROPERTYNAME} = new ArrayList<{CLASSNAME}>();\n        JSONArray array{CLASSNAME} = json.optJSONArray(\"{JSONNAME}\");\n        if (null != array{CLASSNAME}) {\n            int {PROPERTYNAME}Length = array{CLASSNAME}.length();\n            for (int i = 0; i < {PROPERTYNAME}Length; i++) {\n                {OBJECTTYPE} item = array{CLASSNAME}.opt{OBJECTTYPE}(i);\n                if (null != item) {\n                    this.{PROPERTYNAME}.add(new {CLASSNAME}(item));\n                }\n            }\n        }\n        else {\n            {OBJECTTYPE} item = json.opt{OBJECTTYPE}(\"{JSONNAME}\");\n            if (null != item) {\n                this.{PROPERTYNAME}.add(new {CLASSNAME}(item));\n            }\n        }\n\n";
#endif
            templateString = [templateString stringByReplacingOccurrencesOfString:@"{JSONNAME}" withString:property.jsonName];
            templateString = [templateString stringByReplacingOccurrencesOfString:@"{PROPERTYNAME}" withString:property.name];
            templateString = [templateString stringByReplacingOccurrencesOfString:@"{CLASSNAME}" withString:property.referenceClass.className];
            setterString = [templateString stringByReplacingOccurrencesOfString:@"{OBJECTTYPE}" withString:@"JSONObject"];
        } else {
#ifndef COMMAND_LINE
            NSString *arrayTemplate = [mainBundle pathForResource:@"JavaPrimitiveArrayTemplate" ofType:@"txt"];
            NSString *templateString = [[NSString alloc] initWithContentsOfFile:arrayTemplate encoding:NSUTF8StringEncoding error:nil];
#else
            NSString *templateString = @"\n        this.{PROPERTYNAME} = new ArrayList<{TYPE}>();\n        JSONArray array{CLASSNAME} = json.optJSONArray(\"{JSONNAME}\");\n        if (null != array{CLASSNAME}) {\n            int {PROPERTYNAME}Length = array{CLASSNAME}.length();\n            for (int i = 0; i < {PROPERTYNAME}Length; i++) {\n                {TYPE} item = array{CLASSNAME}.opt{TYPE_UPPERCASE}(i);\n                if (null != item) {\n                    this.{PROPERTYNAME}.add(item);\n                }\n            }\n        }\n        else {\n            {TYPE} item = json.opt{TYPE_UPPERCASE}(\"{JSONNAME}\");\n            if (null != item) {\n                this.{PROPERTYNAME}.add(item);\n            }\n        }\n\n";
#endif
            templateString = [templateString stringByReplacingOccurrencesOfString:@"{JSONNAME}" withString:property.jsonName];
            templateString = [templateString stringByReplacingOccurrencesOfString:@"{PROPERTYNAME}" withString:property.name];
            templateString = [templateString stringByReplacingOccurrencesOfString:@"{CLASSNAME}" withString:[property.name capitalizeFirstCharacter]];
            
            PropertyType type = property.collectionType;
            
            if (type == PropertyTypeString) {
                templateString = [templateString stringByReplacingOccurrencesOfString:@"{TYPE}" withString:@"String"];
                templateString = [templateString stringByReplacingOccurrencesOfString:@"{TYPE_UPPERCASE}" withString:@"String"];
            } else if (type == PropertyTypeInt) {
                templateString = [templateString stringByReplacingOccurrencesOfString:@"{TYPE}" withString:@"int"];
                templateString = [templateString stringByReplacingOccurrencesOfString:@"{TYPE_UPPERCASE}" withString:@"Int"];
            } else if (type == PropertyTypeDouble) {
                templateString = [templateString stringByReplacingOccurrencesOfString:@"{TYPE}" withString:@"double"];
                templateString = [templateString stringByReplacingOccurrencesOfString:@"{TYPE_UPPERCASE}" withString:@"Double"];
            } else if (type == PropertyTypeBool) {
                templateString = [templateString stringByReplacingOccurrencesOfString:@"{TYPE}" withString:@"boolean"];
                templateString = [templateString stringByReplacingOccurrencesOfString:@"{TYPE_UPPERCASE}" withString:@"Boolean"];
            } else {
                templateString = [templateString stringByReplacingOccurrencesOfString:@"{TYPE}" withString:@"JSONObject"];
                templateString = [templateString stringByReplacingOccurrencesOfString:@"{TYPE_UPPERCASE}" withString:@""];
            }
            setterString = [NSString stringWithString:templateString];
        }
        
    } else {
        setterString = [setterString stringByAppendingString:[NSString stringWithFormat:@"        this.%@ = ", property.name]];
        
        if (property.type == PropertyTypeInt) {
            setterString = [setterString stringByAppendingFormat:@"json.optInt(\"%@\");\n", property.jsonName];
        } else if (property.type == PropertyTypeDouble) {
            setterString = [setterString stringByAppendingFormat:@"json.optDouble(\"%@\");\n", property.jsonName]; 
        } else if (property.type == PropertyTypeBool) {
            setterString = [setterString stringByAppendingFormat:@"json.optBoolean(\"%@\");\n", property.jsonName]; 
        } else if (property.type == PropertyTypeString) {
            setterString = [setterString stringByAppendingFormat:@"json.optString(\"%@\");\n", property.jsonName]; 
        } else {
            setterString = [setterString stringByAppendingFormat:@"json.opt(\"%@\");\n", property.jsonName];
        }
    }
    
    if (!setterString) {
        setterString = @"";
    }
    
    return setterString;
}

- (NSString *)getterForProperty:(ClassPropertiesObject *)property {
    NSString *getterMethod = [NSString stringWithFormat:@"    public %@ get%@() {\n        return this.%@;\n    }\n\n", [self typeStringForProperty:property], [property.name capitalizeFirstCharacter], property.name];
    
    return getterMethod;
}

- (NSArray *)setterReferenceClassesForProperty:(ClassPropertiesObject *)property {
    return @[];
}

- (NSString *)typeStringForProperty:(ClassPropertiesObject *)property {
    switch (property.type) {
        case PropertyTypeString:
            return @"String";
            break;
        case PropertyTypeArray: {
            
            //Special case, switch over the collection type
            switch (property.collectionType) {
                case PropertyTypeClass:
                    return [NSString stringWithFormat:@"ArrayList<%@>", property.collectionTypeString];
                    break;
                case PropertyTypeString:
                    return @"ArrayList<String>";
                    break;
                case PropertyTypeInt:
                    return @"ArrayList<int>";
                    break;
                case PropertyTypeBool:
                    return @"ArrayList<boolean>";
                    break;
                case PropertyTypeDouble:
                    return @"ArrayList<double>";
                    break;
                default:
                    break;
            }
            break;
        }
        case PropertyTypeDictionary:
            return @"Dictionary";
            break;
        case PropertyTypeInt:
            return @"int";
            break;
        case PropertyTypeBool:
            return @"boolean";
            break;
        case PropertyTypeDouble:
            return @"double";
            break;
        case PropertyTypeClass:
            return property.referenceClass.className;
            break;
        case PropertyTypeOther:
            return property.otherType;
            break;
            
        default:
            break;
    }
    
    return @"";
}

#pragma mark - Java specific implementation details

- (NSString *)setterMethodForProperty:(ClassPropertiesObject *)property {
    NSString *setterMethod = [NSString stringWithFormat:@"    public void set%@(%@ %@) {\n        this.%@ = %@;\n    }\n\n", [property.name capitalizeFirstCharacter], [self typeStringForProperty:property], property.name, property.name, property.name];
    
    return setterMethod;
}

@end
