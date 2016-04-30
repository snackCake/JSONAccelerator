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

#import "SavePanelLanguageChooserViewController.h"

@interface SavePanelLanguageChooserViewController ()

@property (weak) IBOutlet NSTextFieldCell *classPrefixCell;

@end

@implementation SavePanelLanguageChooserViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Initialization code here.
        self.buildForARC = YES;
    }
    
    return self;
}

- (void)awakeFromNib {
    self.outputLanguageLabel.stringValue = NSLocalizedString(@"Output Language", "In the save portion, the label to choose what language");
    self.packageNameLabel.stringValue = NSLocalizedString(@"Package Name", "In the save portion, the label to choose what the package is");
    self.baseClassLabel.stringValue = NSLocalizedString(@"Base Class", "In the save portion, the prompt to specify what the base class is");
    self.buildForArcButton.title = NSLocalizedString(@"Use Automatic Reference Counting", "In the save portion, for objective C, determine whether or not to use ARC");
    self.classPrefixLabel.stringValue = NSLocalizedString(@"Class Prefix", "The letters to prepend to the file");
    
    self.classPrefixCell.placeholderString = @"NRD";
    
    self.javaPanel.hidden = YES;
    self.jsonLibraryPanel.hidden = YES;
    self.objectiveCPanel.hidden = NO;

    [self.languageDropDown selectItemAtIndex:2];
    [self.languageDropDown selectItemAtIndex:OutputLanguageObjectiveC];
}

- (IBAction)languagePopUpChanged:(id)sender {
    self.languageDropDown.nextKeyView = self.baseClassField;
    [self.baseClassField becomeFirstResponder];
    
    if (_languageDropDownIndex == OutputLanguageJava || _languageDropDownIndex == OutputLanguageScala) {
        self.javaPanel.hidden = NO;
        self.jsonLibraryPanel.hidden = _languageDropDownIndex != OutputLanguageScala;
        self.objectiveCPanel.hidden = YES;

        self.packageNameLabel.hidden = NO;
        self.packageNameField.hidden = NO;
        self.buildForArcButton.hidden = YES;
        self.baseClassField.nextKeyView = self.packageNameField;
    } else if (_languageDropDownIndex == OutputLanguageObjectiveC) {
        self.javaPanel.hidden = YES;
        self.jsonLibraryPanel.hidden = YES;
        self.objectiveCPanel.hidden = NO;
        self.buildForArcButton.hidden = NO;
        
        self.baseClassField.nextKeyView = self.classPrefixField;
    } else {
        self.javaPanel.hidden = YES;
        self.jsonLibraryPanel.hidden = YES;
        self.objectiveCPanel.hidden = YES;
    }
}

- (JsonLibrary)chosenJsonLibrary {
    if ([self chosenLanguage] == OutputLanguageScala) {
        switch (_jsonLibraryDropDownIndex) {
            case 1:
                return JsonLibraryScalaPlay;
                break;
            case 2:
                return JsonLibraryScalaAkkaHttpSpray;
                break;
            default:
                return JsonLibraryNone;
                break;
        }
    } else {
        return -JsonLibraryNone;
    }
}

- (OutputLanguage)chosenLanguage {
    if (_languageDropDownIndex == OutputLanguageObjectiveC) {
        return OutputLanguageObjectiveC;
    } else if (_languageDropDownIndex == 1) {
        return OutputLanguageJava;
    } else if (_languageDropDownIndex == 2) {
        return OutputLanguageCoreDataObjectiveC;
    } else if (_languageDropDownIndex == 3) {
        return OutputLanguageDjangoPython;
    } else if (_languageDropDownIndex == 4) {
        return OutputLanguagePython;
    } else if (_languageDropDownIndex == 5) {
        return OutputLanguageScala;
    } else {
        return -1;
    }
}

@end
