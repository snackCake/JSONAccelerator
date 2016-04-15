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

@interface CoreDataModelGenerator : NSObject

/**
 * Creates an xml document that can be saved in as a Core Data Model (.xcdatamodel) for use in Xcode.
 *
 * @param dictionary Dictionary of class objects to be included in the data model. Key is the name of an entity to create, value is the `ClassBaseObject` that represents the entity.
 * @return An NSXMLDocument to be wrapped in a .xcdatamodel bundle.
 */
- (NSXMLDocument *)coreDataModelXMLDocumentFromClassObjects:(NSArray *)classObjects;

@end
