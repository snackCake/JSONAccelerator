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

#import "JSONTextView.h"

@implementation JSONTextView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    
    
    
    if (self) {
        [self registerForDraggedTypes:@[NSFilenamesPboardType, NSPasteboardTypeString]];
    }
    
    return self;
}

#pragma mark - NSDraggingDestination Protocol Methods

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    
    NSPasteboard *pb = [sender draggingPasteboard];
    NSDragOperation dragOperation = [sender draggingSourceOperationMask];
    
    
    
    if ([pb.types containsObject:NSFilenamesPboardType]) {
        if (dragOperation & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    
    if ([pb.types containsObject:NSPasteboardTypeString]) {
        if (dragOperation & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    
    NSPasteboard *pb = [sender draggingPasteboard];
    
    
    
    if ( [pb.types containsObject:NSFilenamesPboardType] ) {
        NSArray *filenames = [pb propertyListForType:NSFilenamesPboardType];
        
        DLog(@"%@", filenames);
        
        
        
        for (NSString *filename in filenames) {
            if ([filename.pathExtension isEqualToString:@"json"]) {
                NSStringEncoding encoding;
                NSError *error;
                NSString *fileContents = [NSString stringWithContentsOfFile:filename usedEncoding:&encoding error:&error];
                DLog(@"%@", fileContents);
                
                
                
                if (error) {
                    DLog(@"Error while reading file contents: %@", [error localizedDescription]);
                } else {
                    self.string = fileContents;
                }
            }
        }
        
    } else if ( [pb.types containsObject:NSPasteboardTypeString] ) {
        NSString *draggedString = [pb stringForType:NSPasteboardTypeString];
        self.string = draggedString;
    }
    
    return YES;
}

@end
