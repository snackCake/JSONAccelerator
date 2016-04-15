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

#import "GenerateFilesButton.h"
#import <QuartzCore/QuartzCore.h>

@interface GenerateFilesButton ()

@end

@implementation GenerateFilesButton

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    
    if (self) {
        self.textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, -7, frameRect.size.width, frameRect.size.height)];
        (self.textField).alignment = NSCenterTextAlignment;
        [_textField setBezeled:NO];
        [_textField setDrawsBackground:NO];
        [_textField setEditable:NO];
        [_textField setSelectable:NO];
        _textField.cell.backgroundStyle = NSBackgroundStyleRaised;
        [self addSubview:self.textField];
        
        // Setup the images
        NSImage *leftCapImage = [NSImage imageNamed:@"generateDataLeftCap"];
        NSImage *middleCapImage = [NSImage imageNamed:@"generateDataBackground"];
        NSImage *rightCapImage = [NSImage imageNamed:@"generateDataRightCap"];

        self.capLeft.image = leftCapImage;
        self.capLeft.frame = NSMakeRect(0, 0, leftCapImage.size.width, leftCapImage.size.height);
        
        self.capMiddle.imageScaling = NSImageScaleAxesIndependently;
        self.capMiddle.image = middleCapImage;
        self.capMiddle.frame = NSMakeRect(leftCapImage.size.width, 0, frameRect.size.width - leftCapImage.size.width - rightCapImage.size.width, middleCapImage.size.height);
        
        self.capRight.image = rightCapImage;
        self.capRight.frame = NSMakeRect(frameRect.size.width - rightCapImage.size.width, 0, rightCapImage.size.width, rightCapImage.size.height);

        // Setup disabled images
        NSImage *leftCapImageDisabled = [NSImage imageNamed:@"generateDataLeftCapDisabled"];
        NSImage *middleCapImageDisabled = [NSImage imageNamed:@"generateDataBackgroundDisabled"];
        NSImage *rightCapImageDisabled = [NSImage imageNamed:@"generateDataRightCapDisabled"];
        
        self.disabledCapLeft.image = leftCapImageDisabled;
        self.disabledCapLeft.frame = NSMakeRect(0, 0, leftCapImageDisabled.size.width, leftCapImageDisabled.size.height);
        
        self.disabledCapMiddle.imageScaling = NSImageScaleAxesIndependently;
        self.disabledCapMiddle.image = middleCapImageDisabled;
        self.disabledCapMiddle.frame = NSMakeRect(leftCapImageDisabled.size.width, 0, frameRect.size.width - leftCapImageDisabled.size.width - rightCapImageDisabled.size.width, middleCapImageDisabled.size.height);
        
        self.disabledCapRight.image = rightCapImageDisabled;
        self.disabledCapRight.frame = NSMakeRect(frameRect.size.width - rightCapImageDisabled.size.width, 0, rightCapImageDisabled.size.width, rightCapImageDisabled.size.height);
    }
    
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    super.enabled = enabled;
    (self.disabledCapRight).hidden = enabled;
    (self.disabledCapMiddle).hidden = enabled;
    (self.disabledCapLeft).hidden = enabled;
  
    (self.capLeft).hidden = !enabled;
    (self.capMiddle).hidden = !enabled;
    (self.capRight).hidden = !enabled;
    
    (self.textField).textColor = (enabled) ? [NSColor whiteColor] : [NSColor colorWithCalibratedRed:0.25 green:0.25 blue:0.25 alpha:1.0];
    _textField.cell.backgroundStyle = (enabled) ? NSBackgroundStyleDark : NSBackgroundStyleRaised;

}

@end
