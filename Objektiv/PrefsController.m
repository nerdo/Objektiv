//
//  PrefsController.m
//  Objektiv
//
//  Created by Ankit Solanki on 22/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import "PrefsController.h"
#import "Constants.h"
#import "Browsers.h"
#import "Objektiv-Swift.h"
#import <MASShortcut/MASShortcut.h>

@interface PrefsController ()
{
    @private
    NSUserDefaults *defaults;
}
@end

@implementation PrefsController

@synthesize browsers;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        defaults = [NSUserDefaults standardUserDefaults];
        browsers = [Browsers sharedInstance].browsers;
    }

    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self initUI];
}

#pragma mark - UI methods

- (void) showPreferences
{
    //[self initUI];
    [self.window makeKeyAndOrderFront:NSApp];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void) initUI
{
    self.autoHideIcon.state = [defaults boolForKey:PrefAutoHideIcon] ? NSOnState : NSOffState;
    self.startAtLogin.state = [defaults boolForKey:PrefStartAtLogin] ? NSOnState : NSOffState;
    self.showNotifications.state = [defaults boolForKey:PrefShowNotifications] ? NSOnState : NSOffState;
    self.hotkeyRecorder.associatedUserDefaultsKey = PrefHotkey;
}

#pragma mark - IBActions

- (IBAction)toggleLoginItem: (id)sender
{
    NSLog(@"PrefsController :: toggleLoginItem");
    [defaults setBool:(self.startAtLogin.state == NSOnState) forKey:PrefStartAtLogin];
}

- (IBAction)toggleHideItem: (id)sender
{
    NSLog(@"PrefsController :: toggleHideItem");
    [defaults setBool:(self.autoHideIcon.state == NSOnState) forKey:PrefAutoHideIcon];
}

- (IBAction)toggleShowNotifications: (id)sender;
{
    NSLog(@"PrefsController :: showNotifications");
    [defaults setBool:(self.showNotifications.state == NSOnState) forKey:PrefShowNotifications];
}

@end
