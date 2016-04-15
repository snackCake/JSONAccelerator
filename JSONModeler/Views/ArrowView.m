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

#import "ArrowView.h"

@implementation ArrowView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    //// Color Declarations
    NSColor* newGradientColor = [NSColor colorWithCalibratedRed: 0.2 green: 0.64 blue: 0.68 alpha: 1];
    NSColor* newGradientColor2 = [NSColor colorWithCalibratedRed: 0 green: 0.37 blue: 0.56 alpha: 1];
    
    //// Gradient Declarations
    NSGradient* newGradient = [[NSGradient alloc] initWithStartingColor: newGradientColor endingColor: newGradientColor2];
    
    
    //// Bezier 2 Drawing
    NSBezierPath* bezier2Path = [NSBezierPath bezierPath];
    [bezier2Path moveToPoint: NSMakePoint(53.5, 19.5)];
    [bezier2Path lineToPoint: NSMakePoint(41.4, 7.5)];
    [bezier2Path lineToPoint: NSMakePoint(41.4, 14.56)];
    [bezier2Path lineToPoint: NSMakePoint(11.5, 14.56)];
    [bezier2Path lineToPoint: NSMakePoint(11.5, 24.44)];
    [bezier2Path lineToPoint: NSMakePoint(41.4, 24.44)];
    [bezier2Path lineToPoint: NSMakePoint(41.4, 31.5)];
    [bezier2Path lineToPoint: NSMakePoint(53.5, 19.5)];
    [bezier2Path closePath];
    [newGradient drawInBezierPath: bezier2Path angle: -90];
    
    [newGradientColor2 setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];
    
}

@end
