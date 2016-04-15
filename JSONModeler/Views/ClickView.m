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

#import "ClickView.h"

@interface ClickView ()

@end

@implementation ClickView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    
    if (self) {
        // Tracking area
        NSTrackingAreaOptions trackingOptions =
		NSTrackingCursorUpdate | NSTrackingEnabledDuringMouseDrag | NSTrackingMouseEnteredAndExited |
		NSTrackingActiveInActiveApp;
        
        _enabled = YES;
        
        myTrackingArea = [[NSTrackingArea alloc]
                          initWithRect: self.bounds // in our case track the entire view
                          options: trackingOptions
                          owner: self
                          userInfo: nil];
        [self addTrackingArea: myTrackingArea];
        
        // Cap Setup
        self.capLeft = [[NSImageView alloc] init];
        self.capMiddle = [[NSImageView alloc] init];
        self.capRight= [[NSImageView alloc] init];
        self.disabledCapLeft = [[NSImageView alloc] init];
        self.disabledCapMiddle = [[NSImageView alloc] init];
        self.disabledCapRight = [[NSImageView alloc] init];
        
        [self addSubview:self.capLeft];
        [self addSubview:self.capMiddle];
        [self addSubview:self.capRight];
        [self addSubview:self.disabledCapLeft];
        [self addSubview:self.disabledCapMiddle];
        [self addSubview:self.disabledCapRight];
    }
    return self;
}



- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    NSLog ( @"Accepts First Mouse" );
    return YES;
}

- (BOOL)acceptsFirstResponder {
    NSLog ( @"Accepts First Responder" );
    return YES;
}

- (void)mouseDown:(NSEvent*)theEvent {
    if (self.enabled && self.delegate != nil) {
        [self.delegate clickViewPressed:self];
    }
}






@end
