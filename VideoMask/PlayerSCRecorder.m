//
//  PlayerSCRecorder.m
//  VideoMask
//
//  Created by Ítalo Sangar on 9/24/15.
//  Copyright © 2015 iTSangar. All rights reserved.
//

#import "PlayerSCRecorder.h"
#import "OverlaySCRecorder.h"

@interface PlayerSCRecorder ()
{
    AVURLAsset *_audioAsset;
}

@property (strong, nonatomic) SCPlayer *player;
@property (weak, nonatomic) IBOutlet UIView *cinema;

@end

@implementation PlayerSCRecorder

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupPlayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[_player setItemByAsset:_recordSession.assetRepresentingSegments];
    //[_player play];
    [self mixAudio];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_player pause];
}

- (void)setupPlayer
{
    _player = [SCPlayer player];
    
    SCVideoPlayerView *playerView = [[SCVideoPlayerView alloc] initWithPlayer:_player];
    //playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    playerView.frame = self.cinema.frame;
    [self.cinema.superview insertSubview:playerView aboveSubview:self.cinema];
    [self.cinema removeFromSuperview];
    _player.loopEnabled = YES;
}

- (void)mixAudio
{
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    _audioAsset = [[AVURLAsset alloc]initWithURL:self.audioUrl options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, _recordSession.duration);
    
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[_audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero, _recordSession.duration);
    
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[_recordSession.assetRepresentingSegments tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    [_player setItemByAsset:mixComposition];
    [_player play];
}


- (IBAction)saveToCameraRoll:(id)sender
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    UISaveVideoAtPathToSavedPhotosAlbum(self.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo
{
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    if (error == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Saved to camera roll" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
