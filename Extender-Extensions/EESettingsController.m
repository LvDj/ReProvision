//
//  EESettingsController.m
//  Extender Installer
//
//  Created by Matt Clarke on 26/04/2017.
//
//

#import "EESettingsController.h"
#import "EEResources.h"

@interface PSSpecifier (Private)
- (void)setButtonAction:(SEL)arg1;
@end

@implementation EESettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationItem] setTitle:@"More"];
}

-(id)specifiers {
    if (_specifiers == nil) {
        NSMutableArray *testingSpecs = [NSMutableArray array];
        
        // Create specifiers!
        [testingSpecs addObjectsFromArray:[self _appleIDSpecifiers]];
        [testingSpecs addObjectsFromArray:[self _alertSpecifiers]];
        
        _specifiers = testingSpecs;
    }
    
    return _specifiers;
}

- (NSArray*)_appleIDSpecifiers {
    NSMutableArray *loggedIn = [NSMutableArray array];
    NSMutableArray *loggedOut = [NSMutableArray array];
    
    PSSpecifier *group = [PSSpecifier groupSpecifierWithName:@"Apple ID"];
    [group setProperty:@"Your password is only sent to Apple." forKey:@"footerText"];
    [loggedOut addObject:group];
    [loggedIn addObject:group];
    
    // Logged in
    
    NSString *title = [NSString stringWithFormat:@"Apple ID: %@", [EEResources username]];
    PSSpecifier *appleid = [PSSpecifier preferenceSpecifierNamed:title target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
    [appleid setProperty:@"appleid" forKey:@"key"];
    
    [loggedIn addObject:appleid];
    
    PSSpecifier *signout = [PSSpecifier preferenceSpecifierNamed:@"Sign Out" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
    [signout setButtonAction:@selector(didClickSignOut:)];
    
    [loggedIn addObject:signout];
    
    // Logged out.
    
    PSSpecifier *signin = [PSSpecifier preferenceSpecifierNamed:@"Sign In" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
    [signin setButtonAction:@selector(didClickSignIn:)];
    
    [loggedOut addObject:signin];
    
    _loggedInAppleSpecifiers = loggedIn;
    _loggedOutAppleSpecifiers = loggedOut;
    
    BOOL hasCachedUser = [EEResources username] != nil;
    return hasCachedUser ? _loggedInAppleSpecifiers : _loggedOutAppleSpecifiers;
}

- (NSArray*)_alertSpecifiers {
    NSMutableArray *array = [NSMutableArray array];
    
    PSSpecifier *group = [PSSpecifier groupSpecifierWithName:@"Configuration"];
    [group setProperty:@"Set how close to an application's expiration date re-signs will occur." forKey:@"footerText"];
    [array addObject:group];
    
    /*PSSpecifier *showAlerts = [PSSpecifier preferenceSpecifierNamed:@"Show Alerts" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
     [showAlerts setProperty:@"showAlerts" forKey:@"key"];
     
     [array addObject:showAlerts];*/
    
    PSSpecifier *showDebugAlerts = [PSSpecifier preferenceSpecifierNamed:@"Show Debug Alerts" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
    [showDebugAlerts setProperty:@"showDebugAlerts" forKey:@"key"];
    [showDebugAlerts setProperty:@0 forKey:@"default"];
    
    [array addObject:showDebugAlerts];
    
    PSSpecifier *threshold = [PSSpecifier preferenceSpecifierNamed:@"Re-sign Threshold" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"PSListItemsController") cell:PSLinkListCell edit:nil];
    [threshold setProperty:@YES forKey:@"enabled"];
    [threshold setProperty:@2 forKey:@"default"];
    threshold.values = [NSArray arrayWithObjects:@1, @2, @3, @4, @5, @6, nil];
    threshold.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1 Day", @"2 Days", @"3 Days", @"4 Days", @"5 Days", @"6 Days", nil] forKeys:threshold.values];
    threshold.shortTitleDictionary = threshold.titleDictionary;
    [threshold setProperty:@"thresholdForResigning" forKey:@"key"];
    
    [array addObject:threshold];
    
    return array;
}

- (void)updateSpecifiersForAppleID {
    BOOL hasCachedUser = [EEResources username] != nil;
    
    // Update "Apple ID: XXX"
    NSString *title = [NSString stringWithFormat:@"Apple ID: %@", [EEResources username]];
    PSSpecifier *spec;
    for (PSSpecifier *spec1 in _loggedInAppleSpecifiers) {
        if ([[spec propertyForKey:@"key"] isEqualToString:@"appleid"]) {
            spec = spec1;
            break;
        }
    }
    
    [spec setName:title];
    
    if (hasCachedUser) {
        [self removeContiguousSpecifiers:_loggedOutAppleSpecifiers animated:NO];
        [self insertContiguousSpecifiers:_loggedInAppleSpecifiers atIndex:0];
    } else {
        [self removeContiguousSpecifiers:_loggedInAppleSpecifiers animated:NO];
        [self insertContiguousSpecifiers:_loggedOutAppleSpecifiers atIndex:0];
    }
}

- (void)didClickSignOut:(id)sender {
    [EEResources signOut];
    
    [self updateSpecifiersForAppleID];
}

- (void)didClickSignIn:(id)sender {
    [EEResources signInWithCallback:^(BOOL result) {
        [self updateSpecifiersForAppleID];
    }];
}

- (id)readPreferenceValue:(PSSpecifier*)value {
    id val = [[NSUserDefaults standardUserDefaults] objectForKey:[value propertyForKey:@"key"]];
    return val ? val : [val propertyForKey:@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:[specifier propertyForKey:@"key"]];
}

@end
