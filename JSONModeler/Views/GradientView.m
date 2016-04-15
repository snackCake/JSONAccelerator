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
#import "GradientView.h"

@interface GradientView () {
    // Appearance Attributes
    NSGradient *backgroundGradient;
}

@end

@implementation GradientView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    CGFloat tC = 72.0 / 255.0;
    NSColor *top = [NSColor colorWithCalibratedRed:tC green:tC blue:tC alpha:1.0f];
    NSColor *bottom = [NSColor colorWithCalibratedRed:39.0 / 255.0 green:39.0 / 255.0 blue:39.0 / 255.0 alpha:1.0];

    // Drawing code here.
//    [[NSColor darkGrayColor] setFill];
//    NSRectFill(dirtyRect);
    
    if (backgroundGradient == nil) {
        backgroundGradient = [[NSGradient alloc] initWithStartingColor:bottom endingColor:top];
    }
    
    NSRect tempBounds = self.bounds;
//    tempBounds.size.height--;
    [backgroundGradient drawInRect:tempBounds angle:90.0];
}

@end
