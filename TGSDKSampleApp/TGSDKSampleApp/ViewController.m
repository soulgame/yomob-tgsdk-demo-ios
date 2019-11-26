//
//  ViewController.m
//  TGSDKSampleApp
//
//  Created by SunHan on 9/7/15.
//  Copyright (c) 2015 SoulGame. All rights reserved.
//

#import "ViewController.h"
#import "TGSDK/TGSDK.h"

@interface ViewController () <UIPickerViewDelegate, UIPickerViewDataSource,
    TGPreloadADDelegate, TGADDelegate>

@property (weak, nonatomic) IBOutlet UIButton *adScene;
@property (weak, nonatomic) IBOutlet UIButton *showTestViewButton;
@property (weak, nonatomic) IBOutlet UIPickerView *scenePicker;
@property (weak, nonatomic) IBOutlet UIButton *closeBannerButton;
@property (weak, nonatomic) IBOutlet UITextView *callbackView;

@property (nonatomic, strong) NSArray * sceneArray;
@property (nonatomic, strong) NSString * sceneID;
@property (strong, nonatomic) NSMutableDictionary *sceneMap;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scenePicker.delegate = self;
    _scenePicker.dataSource = self;
    
    [TGSDK setDebugModel:YES];
    [TGSDK initialize:@"hP7287256x5z1572E5n7" callback:^(BOOL success, id tag, NSDictionary* result){
        dispatch_async(dispatch_get_main_queue(), ^{
            [TGSDK tagPayingUser:TGSmallPaymentUser WithCurrency:@"CNY" AndCurrentAmount:0 AndTotalAmount:0];
            [self showLog:NSLocalizedString(@"TGSDK init finished", @"") message:NSLocalizedString(@"TGSDK init finished", @"")];
        });
    }];
    
    [TGSDK setBanner:@"banner0" Config:TGBannerLarge
                   x:0 y:self.view.frame.size.height-110
               width:self.view.frame.size.width height:90 Interval:30];
    [TGSDK setBanner:@"banner1" Config:TGBannerLarge
                   x:0 y:self.view.frame.size.height-220
               width:self.view.frame.size.width height:90 Interval:30];
    [TGSDK setBanner:@"banner2" Config:TGBannerLarge
                   x:0 y:self.view.frame.size.height-330
               width:self.view.frame.size.width height:90 Interval:30];
    
    [TGSDK setADDelegate:self];
    [TGSDK preloadAd:self];
}

- (IBAction)showPicker {
    _scenePicker.hidden = NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _scenePicker.hidden = YES;
}

- (IBAction)onShowAd:(id)sender {
    if (_sceneID != nil) {
        if ([TGSDK couldShowAd:_sceneID]) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Show Ad", @"") message:[NSString stringWithFormat:@"%@%@？", NSLocalizedString(@"Ready to show Ad:", @""), _sceneID] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                _callbackView.text = @"";
                [TGSDK showAd:_sceneID];

            }];
            [alert addAction:yesAction];
            UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [TGSDK reportAdRejected:_sceneID];
                
            }];
            [alert addAction:noAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self presentedViewController] == nil) {
                    [self presentViewController:alert animated:YES completion:nil];
                }
            });
        } else {
            [self showAlert:@"showAd" message:@"[TGSDK couldShowAd return false]"];
        }
    } else {
        [self showAlert:@"Select a Scene ID Please" message:@"Select a Scene ID Please"];
    }
}
- (IBAction)showTestView:(id)sender {
    if (_sceneID != nil) {
        _callbackView.text = @"";
        [TGSDK showTestView:_sceneID];
    } else {
        [self showAlert:@"Select a Scene ID Please" message:@"Select a Scene ID Please"];
    }
}
- (IBAction)closeBanner:(id)sender {
    if (_sceneID != nil) {
        [TGSDK closeBanner:_sceneID];
    } else {
        [self showAlert:@"Select a Scene ID Please" message:@"Select a Scene ID Please"];
    }
}
    
- (void)showAlert:(NSString*)title message:(NSString*)message {
    [self showLog:title message:message];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    dispatch_async(dispatch_get_main_queue(), ^(){
        if ([self presentedViewController] == nil) {
            [self presentViewController:alert animated:YES completion:nil];
        }
    });
}

- (void)showLog:(NSString*)title message:(NSString*)message {
    NSLog(@"[showLog] %@ : %@", title, message);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _sceneArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _sceneArray[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _sceneID = [[self sceneMap] objectForKey:_sceneArray[row]];
    [_adScene setTitle:_sceneID forState:UIControlStateNormal];
}


    

// ------------------------ TGPreloadADDelegate ------------------------
- (void) onPreloadSuccess:(NSString*)result
{
    [self showAlert:@"onPreloadSuccess" message:[NSString stringWithFormat:@"%@ preload success", (result?result:@"nil")]];
    if (result && [result length] > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *sceneArray = [result componentsSeparatedByString:@","];
            [self setSceneMap:[NSMutableDictionary dictionaryWithCapacity:[sceneArray count]]];
            for (NSString* sid in sceneArray) {
                [[self sceneMap] setObject:sid
                                    forKey:[NSString stringWithFormat:@"%@(%@)", [TGSDK getSceneNameById:sid], [sid substringToIndex:4]]];
            }
            _sceneArray = [[self sceneMap] allKeys];
            [_adScene setTitle:@"Select a Scene ID" forState:UIControlStateNormal];
            [_scenePicker reloadAllComponents];
        });
    }
}

- (void) onPreloadFailed:(NSString*)result WithError:(NSString*) error {
    [self showAlert:@"onPreloadFailed" message:@"onPreloadFailed"];
}

- (void) onAwardVideoLoaded:(NSString* _Nonnull) result {
    [self showLog:@"onAwardVideoLoaded" message:result];
}

- (void) onInterstitialLoaded:(NSString* _Nonnull) result {
    [self showLog:@"onInterstitialLoaded" message:result];
}

- (void) onInterstitialVideoLoaded:(NSString* _Nonnull) result {
    [self showLog:@"onInterstitialVideoLoaded" message:result];
}

- (void) onShow:(NSString* _Nonnull)scene Success:(NSString* _Nonnull)result {
    [self showLog:[NSString stringWithFormat:@"onShowSuccess : %@", scene] message:result];
    _callbackView.text = [NSString stringWithFormat:@"%@ShowSuccess : %@\n", _callbackView.text, result];
}

- (void) onShow:(NSString* _Nonnull)scene Failed:(NSString* _Nonnull)result Error:(NSError* _Nullable)error {
    [self showLog:[NSString stringWithFormat:@"onShowFailed : %@", scene] message:result];
    _callbackView.text = [NSString stringWithFormat:@"%@ShowFailed : %@\n", _callbackView.text, result];
}

- (void) onAD:(NSString* _Nonnull)scene Click:(NSString* _Nonnull)result {
    [self showLog:[NSString stringWithFormat:@"onADClick : %@", scene] message:result];
    _callbackView.text = [NSString stringWithFormat:@"%@ADClick : %@\n", _callbackView.text, result];
}

- (void) onAD:(NSString* _Nonnull)scene Close:(NSString* _Nonnull)result Award:(BOOL)award {
    [self showAlert:[NSString stringWithFormat:@"onADClose : %@", scene] message:[NSString stringWithFormat:@"%@ - Award : %@", result, award?@"True":@"False"]];
    _callbackView.text = [NSString stringWithFormat:@"%@ADClose : %@\n", _callbackView.text, result];
    _callbackView.text = [NSString stringWithFormat:@"%@ADAward : %@\n", _callbackView.text, award?@"True":@"False"];
}

@end
