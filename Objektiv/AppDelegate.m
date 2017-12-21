//
//  AppDelegate.m
//  Objektiv
//
//  Created by Ankit Solanki on 01/11/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import "AppDelegate.h"
#import "BrowserItem.h"
#import "Browsers.h"
#import "Constants.h"
#import "ImageUtils.h"
#import "BrowsersMenu.h"
#import "OverlayWindow.h"
#import "ZeroKitUtilities.h"
#import <MASShortcut/Shortcut.h>
#import "PFMoveApplication.h"
#import "Objektiv-Swift.h"
#import <CDEvents.h>
#import <Sparkle/Sparkle.h>

@interface AppDelegate()
{
    @private
    NSStatusItem *statusBarIcon;
    BrowsersMenu *browserMenu;
    NSUserDefaults *defaults;
    NSWorkspace *sharedWorkspace;
    OverlayWindow *overlayWindow;
    CDEvents *cdEvents;
    NSString *_defaultBrowser;
    NSArray *browserMaps;
}
@end

@implementation AppDelegate

{} // TODO Figure out why the first pragma mark requires this empty block to show up

#pragma mark - NSApplicationDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    NSAppleEventManager *em = [NSAppleEventManager sharedAppleEventManager];
    [em setEventHandler:self
            andSelector:@selector(getUrl:withReplyEvent:)
          forEventClass:kInternetEventClass
             andEventID:kAEGetURL];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    PFMoveToApplicationsFolderIfNecessary();

    NSLog(@"applicationDidFinishLaunching");

//    [[SUUpdater sharedUpdater] checkForUpdatesInBackground];

    self.prefsController = [[PrefsController alloc] initWithWindowNibName:@"PrefsController"];
    sharedWorkspace = [NSWorkspace sharedWorkspace];

    browserMenu = [[BrowsersMenu alloc] init];

    NSLog(@"Setting defaults");
    [ZeroKitUtilities registerDefaultsForBundle:[NSBundle mainBundle]];
    defaults = [NSUserDefaults standardUserDefaults];
    
    [self displayAreWeDefaultMsg];

    [defaults addObserver:self
               forKeyPath:PrefAutoHideIcon
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    [defaults addObserver:self
               forKeyPath:PrefStartAtLogin
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    [[MASShortcutBinder sharedBinder] bindShortcutWithDefaultsKey:PrefHotkey toAction:^{
        [self hotkeyTriggered];
     }];
    
    [[Browsers sharedInstance] findBrowsers];
    [self showAndHideIcon:nil];

    overlayWindow = [[OverlayWindow alloc] init];

    [ModifierKeyListener shared];

    [self setupBrowserMaps];

    [self watchApplicationsFolder];

    NSLog(@"applicationDidFinishLaunching :: finish");
}

- (void)watchApplicationsFolder
{
    // Watch the /Applications & ~/Applications directories for a change
    NSArray *urls = @[
        [NSURL URLWithString:@"/Applications"],
        [NSURL URLWithString:[NSHomeDirectoryForUser(NSUserName()) stringByAppendingString:@"/Applications"]]
    ];

    cdEvents = [[CDEvents alloc] initWithURLs:urls block:^(CDEvents *watcher, CDEvent *event) {
        [[Browsers sharedInstance] findBrowsersAsync];
    }];
    cdEvents.ignoreEventsFromSubDirectories = YES;
}

- (BOOL)applicationShouldHandleReopen: (NSApplication *)application hasVisibleWindows: (BOOL)visibleWindows
{
    [self showAndHideIcon:nil];
    return YES;
}

#pragma mark - NSKeyValueObserving

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if ([keyPath isEqualToString:PrefAutoHideIcon])
    {
        [self showAndHideIcon:nil];
    }
    if ([keyPath isEqualToString:PrefStartAtLogin])
    {
        [self toggleLoginItem];
    }
}

#pragma mark - "Business" Logic

- (NSArray*) browsers
{
    return [Browsers browsers];
}

- (void) selectABrowser:sender
{
    NSString *newDefaultBrowser = [sender respondsToSelector:@selector(representedObject)]
        ? [sender representedObject]
        :sender;

    NSLog(@"Selecting a browser: %@", newDefaultBrowser);
    [Browsers sharedInstance].defaultBrowserIdentifier = newDefaultBrowser;
    [self performSelector:@selector(updateStatusBarIcon) withObject:nil afterDelay:0.1];
    
    if ([defaults boolForKey:PrefShowNotifications])
    {
        [self showNotification:newDefaultBrowser];
    }
}

- (void) toggleLoginItem
{
    if ([defaults boolForKey:PrefStartAtLogin])
    {
        [ZeroKitUtilities enableLoginItemForBundle:[NSBundle mainBundle]];
    }
    else
    {
        [ZeroKitUtilities disableLoginItemForBundle:[NSBundle mainBundle]];
    }
}

#pragma mark - UI


- (void) hotkeyTriggered
{
    NSLog(@"@Hotkey triggered");
    if (overlayWindow.isVisible) {
        [overlayWindow close];
        return;
    }
    [overlayWindow makeKeyAndOrderFront:NSApp];
    [self showAndHideIcon:nil];
}

- (void) createStatusBarIcon
{
    NSLog(@"createStatusBarIcon");
    if (statusBarIcon != nil) return;
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];

    statusBarIcon = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    statusBarIcon.toolTip = AppDescription;
    [self updateStatusBarIcon];
    statusBarIcon.highlightMode = YES;

    statusBarIcon.menu = browserMenu;
}

- (void) updateStatusBarIcon;
{
    NSString *identifier = [Browsers sharedInstance].defaultBrowserIdentifier;
    statusBarIcon.image = [ImageUtils statusBarIconForAppId:identifier];

    if ([identifier isEqualToString:_defaultBrowser]) return;
    _defaultBrowser = identifier;
    [[Browsers sharedInstance] findBrowsersAsync];
}

- (void) destroyStatusBarIcon
{
    NSLog(@"destroyStatusBarIcon");
    if (![defaults boolForKey:PrefAutoHideIcon])
    {
        return;
    }
    if (browserMenu.menuIsOpen)
    {
        [self performSelector:@selector(destroyStatusBarIcon) withObject:nil afterDelay:10];
    }
    else
    {
        [[statusBarIcon statusBar] removeStatusItem:statusBarIcon];
        statusBarIcon = nil;
    }
}

- (void) showAndHideIcon:(NSEvent*)hotKeyEvent
{
    NSLog(@"showAndHideIcon");
    [self createStatusBarIcon];
    if ([defaults boolForKey:PrefAutoHideIcon])
    {
        [self performSelector:@selector(destroyStatusBarIcon) withObject:nil afterDelay:10];
    }
}

- (void) showAbout
{
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:nil];
}

- (void) doQuit
{
    [NSApp terminate:nil];
}

#pragma mark - Utilities

- (void) showNotification:(NSString *)browserIdentifier
{
    NSString *browserPath = [sharedWorkspace absolutePathForAppBundleWithIdentifier:browserIdentifier];
    NSString *browserName = [[NSFileManager defaultManager] displayNameAtPath:browserPath];
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = [NSString stringWithFormat:NotificationTitle, browserName];
    notification.informativeText = [NSString stringWithFormat:NotificationText, browserName, AppName];
    NSUserNotificationCenter* center = [NSUserNotificationCenter defaultUserNotificationCenter];
    center.delegate = self;
    [center deliverNotification:notification];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

-(void)displayAreWeDefaultMsg
{
    if([defaults boolForKey:PrefAreWeDefault]) return;
    if([[[NSBundle mainBundle] bundleIdentifier] caseInsensitiveCompare:[[Browsers sharedInstance] systemDefaultBrowser]] == NSOrderedSame) {
        return;
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setShowsSuppressionButton:YES];
    [alert setMessageText:NSLocalizedString(@"Non Default Browser", @"Non Default Browser")];
    [alert setInformativeText:NSLocalizedString(@"No Default Browser Information", @"No Default Browser Information")];
    [alert addButtonWithTitle:NSLocalizedString(@"Set As Default", @"Set As Default")];
    NSButton *cancelButton = [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel")];
    [cancelButton setKeyEquivalent:@"\e"];
    
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [[Browsers sharedInstance] setOurselvesAsDefaultBrowser];
    }
    
    if ([[alert suppressionButton] state] == NSOnState) {
        NSLog(@"Suppress");
        [defaults setBool:YES forKey:PrefAreWeDefault];
    }
}

-(void)setupBrowserMaps
{
    browserMaps = [NSArray arrayWithObjects:
                   [ModifierKeyBrowserMap new],
                   [DomainBrowserMap new],
                   [DefaultBrowserMap new],
                   nil
    ];
}

#pragma mark - File Handlers

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    [self openWithBrowser:[NSString stringWithFormat:kLocalFileUri, filename]];
    return YES;
}

- (void)getUrl:(NSAppleEventDescriptor *)event
withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    [self openWithBrowser:[[event paramDescriptorForKeyword:keyDirectObject]
                           stringValue]];
}

- (void)openWithBrowser:(NSString*)location
{
    
    NSArray *urls = [NSArray arrayWithObject:[NSURL URLWithString:location]];
    
    int options = NSWorkspaceLaunchAsync;

    NSDictionary *map = @{@"": urls};

    // TODO map urls to a dictionary of browser identifiers and the urls each browser should open

    for (id <BrowserMappable> browserMap in browserMaps) {
        map = [browserMap updatedBrowserMapWithMap:map];

        // Processing stops when there are no more urls to process.
        if ([map objectForKey:@""] == nil) {
            break;
        }
    }

    if (map) {
        for (NSString* appBundleIdentifier in map) {
            [[NSWorkspace sharedWorkspace] openURLs: [map objectForKey: appBundleIdentifier]
                            withAppBundleIdentifier: appBundleIdentifier
                                            options: options
                     additionalEventParamDescriptor: nil
                                  launchIdentifiers: nil];
        }
    }
}

@end
