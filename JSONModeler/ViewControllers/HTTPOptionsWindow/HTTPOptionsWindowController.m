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

#import "HTTPOptionsWindowController.h"
#import "ModelerDocument.h"

NSString * const headerKey = @"headerKey";
NSString * const headerValue = @"headerValue";

@interface HTTPOptionsWindowController () <NSControlTextEditingDelegate> {
@private
    NSTextView *_headerKeyFieldEditor;
    NSArray *_httpHeaderStrings;
    BOOL _fieldIsCompleting;
    BOOL _handlingCommand;
}

@end

@implementation HTTPOptionsWindowController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Initialization code here.
        _httpHeaderStrings = @[@"Accept", @"Accept-Charset", @"Accept-Encoding", @"Accept-Language", @"Authorization", @"Cache-Control", @"Connection", @"Cookie", @"Content-Length", @"Content-MD5", @"Content-Type", @"Date", @"Expect", @"From", @"Host", @"If-Match", @"If-Modified-Since", @"If-None-Match", @"If-Range", @"If-Unmodified-Since", @"Max-Forwards", @"Pragma", @"Proxy-Authorization", @"Range", @"Referer", @"TE", @"Upgrade", @"User-Agent", @"Via", @"Warning"];
        
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil document:(ModelerDocument *)doc {
    
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Initialization code here.
        self.document = doc;
        
    }
    
    return self;    
}

- (void)awakeFromNib  {
    [super awakeFromNib];
    
    /* Localize UI element strings */
    _methodBox.title = NSLocalizedString(@"Method", @"Title for the Method box in the HTTP Options window");
    _headersBox.title = NSLocalizedString(@"Headers", @"Title for the Headers box in the HTTP Options window");
    _keyLabel.stringValue = NSLocalizedString(@"Key", @"Title for the field to enter a HTTP header key");
    _valueLabel.stringValue = NSLocalizedString(@"Value", @"Title for the field to enter a HTTP header value");
    _addButton.title = NSLocalizedString(@"Add", @"Title for the Add header button in the HTTP Options window");
    [_headerTableKeyColumn.headerCell setStringValue:NSLocalizedString(@"Key", @"Title for the column of HTTP header keys")];
    [_headerTableValueColumn.headerCell setStringValue:NSLocalizedString(@"Value", @"Title for the column of HTTP header values")];
    [self.urlTextFieldCell setPlaceholderString:NSLocalizedString(@"http://www.domain.com/", @"Prompt user gets to enter a URL")];    
    [self.generateDataButton setTitle:NSLocalizedString(@"Get Data", @"In the main screen, this is the button that fetches data from a URL")];
    
    /* Set up http parameters */
    self.httpMethod = self.document.httpMethod;
    
    for (NSDictionary *header in self.document.httpHeaders) {
        [self.headerArrayController addObject:header];
    }
    
    _fieldIsCompleting = NO;
    _handlingCommand = NO;
    
    /* Disable the dummy button */
    [_dummyButton setImageDimsWhenDisabled:NO];
    [_dummyButton setEnabled:NO];

}

- (IBAction)addHeaderClicked:(id)sender {
    if (_headerKeyField.stringValue != nil && ![_headerKeyField.stringValue isEqualToString:@""] && _headerValueField.stringValue != nil && ![_headerValueField.stringValue isEqualToString:@""]) {
        [self.headerArrayController addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:_headerKeyField.stringValue, headerKey, _headerValueField.stringValue, headerValue, nil]];
    }
}

- (void)popoverWillClose:(NSNotification *)notification {
    ModelerDocument *document = self.document;
    document.httpMethod = _httpMethod;
    document.httpHeaders = [_headerArrayController.arrangedObjects copy];
}

- (IBAction)plusClicked:(id)sender {
    [self.headerArrayController addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"", headerKey, @"", headerValue, nil]];
    
    [_headerTableView editColumn:0 row:(_headerTableView.numberOfRows - 1) withEvent:nil select:YES];
}

- (IBAction)minusClicked:(id)sender {
    NSInteger row = _headerTableView.selectedRow;
    
    if (row != -1) {
        [_headerArrayController removeObjectAtArrangedObjectIndex:row];
    }
}

- (IBAction)fetchDataPress:(id)sender {
    ModelerDocument *document = self.document;
    document.httpMethod = _httpMethod;
    document.httpHeaders = [_headerArrayController.arrangedObjects copy];
    [self.popoverOwnerDelegate getDataButtonPressed];
}

#pragma mark - NSControl Delegate Methods (for Header Key Text Field)

- (NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    NSMutableArray *matches = [NSMutableArray array];
    NSString *partialString = [textView.string substringWithRange:charRange];
    
    
    
    for (NSString *headerString in _httpHeaderStrings) {
        if ([headerString rangeOfString:partialString options:NSAnchoredSearch | NSCaseInsensitiveSearch range:NSMakeRange(0, headerString.length)].location != NSNotFound) {
            [matches addObject:headerString];
        }
    }
    
    [matches sortUsingSelector:@selector(compare:)];
    
    return matches;
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    BOOL result = NO;
	
	
	
	if ([textView respondsToSelector:commandSelector]) {
        _handlingCommand = YES;
        [textView performSelector:commandSelector withObject:nil];  // This call with usually issue a warning under ARC, but this has been suppressed with the warning flag -Wno-arc-performSelector-leaks
        _handlingCommand = NO;
		
		result = YES;
    }
	
    return result;

}

#pragma mark - NSResponder methods

- (void)delete:(id)sender {
    NSInteger row = _headerTableView.selectedRow;
    
    
    
    if (row != -1) {
        [_headerArrayController removeObjectAtArrangedObjectIndex:row];
    }
}

@end
