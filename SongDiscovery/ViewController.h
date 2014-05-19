//
//  ViewController.h
//  SongDiscovery
//
//  Created by Davis Gossage on 9/27/13.
//  Copyright (c) 2013 Davis Gossage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController<AVAudioPlayerDelegate>{
    IBOutlet UILabel *title1;
    IBOutlet UILabel *title2;
    IBOutlet UIImageView *albumArt1;
    IBOutlet UIImageView *albumArt2;
    IBOutlet UILabel *artist1;
    IBOutlet UILabel *artist2;
    IBOutlet UIView *bar11;
    IBOutlet UIView *bar12;
    IBOutlet UIView *bar13;
    IBOutlet UIView *bar21;
    IBOutlet UIView *bar22;
    IBOutlet UIView *bar23;
    IBOutlet UIView *outer1;
    IBOutlet UIView *outer2;
    IBOutlet UIView *progress1;
    IBOutlet UIView *progress2;
    IBOutlet UIView *progress3;
    IBOutlet UIView *progress4;
    IBOutlet UIView *progress5;
    IBOutlet UIView *progress6;
    IBOutlet UIView *progress7;
    IBOutlet UIView *progress8;
    IBOutlet UIView *progress9;
    IBOutlet UIView *progress10;
    IBOutlet UILabel *progress;
    IBOutlet UIView *hipsterView;
    IBOutlet UILabel *hipsterRank;
}

- (IBAction)selectSong1:(id)sender;
- (IBAction)selectSong2:(id)sender;
- (IBAction)changeto1:(id)sender;
- (IBAction)changeto2:(id)sender;
- (IBAction)goBack:(id)sender;

@end
