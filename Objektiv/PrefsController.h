//
//  PrefsController.h
//  Objektiv
//
//  Created by Ankit Solanki on 22/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MASShortcut/Shortcut.h>


@interface PrefsController : NSWindowController

-(void) showPreferences;

@property (assign) IBOutlet NSButton *startAtLogin;
@property (assign) IBOutlet NSButton *autoHideIcon;
@property (assign) IBOutlet NSButton *showNotifications;
@property (assign) IBOutlet MASShortcutView *hotkeyRecorder;
@property NSArray *browsers;

- (IBAction)toggleLoginItem: (id)sender;
- (IBAction)toggleHideItem: (id)sender;
- (IBAction)toggleShowNotifications: (id)sender;

@end
