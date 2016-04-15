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

#import <Cocoa/Cocoa.h>

@class ModelerDocument;

@protocol HTTPOptionsWindowControllerDelegate <NSObject>

- (void)getDataButtonPressed;

@end

@interface HTTPOptionsWindowController : NSViewController <NSPopoverDelegate>

@property (strong) id<HTTPOptionsWindowControllerDelegate>popoverOwnerDelegate;
@property (weak) IBOutlet NSMatrix *httpMethodRadioButtons;
@property HTTPMethod httpMethod;
@property (weak) NSPopover *popover;

@property (strong) IBOutlet NSArrayController *headerArrayController;

@property (weak) ModelerDocument *document;

@property (weak) IBOutlet NSTextField *headerKeyField;
@property (weak) IBOutlet NSTextField *headerValueField;
@property (weak) IBOutlet NSTableView *headerTableView;
@property (weak) IBOutlet NSTextField *urlTextField;
@property (weak) IBOutlet NSTextFieldCell *urlTextFieldCell;
@property (weak) IBOutlet NSButton *generateDataButton;

@property (weak) IBOutlet NSTableColumn *headerTableKeyColumn;
@property (weak) IBOutlet NSTableColumn *headerTableValueColumn;

/* This button exists purely as a graphic element. It has no functionality */
@property (weak) IBOutlet NSButtonCell *dummyButton;

/* Other Localizable UI Elements */
@property (weak) IBOutlet NSBox *methodBox;
@property (weak) IBOutlet NSBox *headersBox;
@property (weak) IBOutlet NSTextField *keyLabel;
@property (weak) IBOutlet NSTextField *valueLabel;
@property (weak) IBOutlet NSButton *addButton;


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil document:(ModelerDocument *)doc;

- (IBAction)addHeaderClicked:(id)sender;

- (IBAction)plusClicked:(id)sender;
- (IBAction)minusClicked:(id)sender;
- (IBAction)fetchDataPress:(id)sender;

@end
