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

@class GenerateFilesButton, InvalidDataButton;

@interface MainWindowController : NSWindowController

@property (weak) IBOutlet NSButton *getDataButton;
@property (unsafe_unretained) IBOutlet NSTextView *JSONTextView;
@property (weak) IBOutlet NSProgressIndicator *progressView;
@property (weak) IBOutlet NSButton *optionsButton;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (strong) IBOutlet NSWindow *mainWindow;
@property (weak) IBOutlet NSView *fetchDataFromURLView;
@property (weak) IBOutlet NSButton *switchToDataLoadButton;
@property (weak) IBOutlet NSView *getDataView;
@property (weak) IBOutlet NSView *validDataStructureView;
@property (weak) IBOutlet GenerateFilesButton *genFilesView;
@property (weak) IBOutlet InvalidDataButton *invalidDataView;
@property (weak) IBOutlet NSView *errorMessageView;
@property (weak) IBOutlet NSTextField *errorMessageTitle;
@property (weak) IBOutlet NSTextField *errorMessageDescription;
@property (weak) IBOutlet NSButton *errorCloseButton;
@property (weak) IBOutlet NSTextFieldCell *instuctionsTextField;
@property (weak) IBOutlet NSTextFieldCell *validDataStructureField;


@property (NS_NONATOMIC_IOSONLY, readonly) BOOL verifyJSONString;
- (IBAction)optionsButtonPressed:(id)sender;
- (IBAction)generateFilesPressed:(id)sender;
- (IBAction)switchToDataLoadView:(id)sender;
- (IBAction)cancelDataLoad:(id)sender;
- (IBAction)closeAlertPressed:(id)sender;



@end
