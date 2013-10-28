//
//  ClangueRecorderDetailViewController.m
//  Clangue
//
//  Created by guillaume on 09/10/13.
//  Copyright (c) 2013 DoTProjects. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ClangueRecorderDetailViewController.h"

@interface ClangueRecorderDetailViewController ()
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSTimer* _timer;
    UIAlertView* _alert;
    NSURL* recordedFile;

}
@end

@implementation ClangueRecorderDetailViewController

#pragma mark - Managing the detail item

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    //Call Api and Get the Json code
    NSLog(@"ALLO");
    NSLog(@"id: %@",_subjectId);
    NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[@"http://clangue.net/api/IOS/getHomework.php?s=" stringByAppendingString:_subjectId]]];
    //NSLog(@"%@",jsonData);
    NSError* error;
    NSDictionary *dit = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (!error) {
        //Get values from this dict using respective keys
        NSDictionary *msgs = [dit objectForKey:@"data"];
        NSNumber *ident = [msgs objectForKey:@"id"];
        NSString *enonce = [NSString stringWithFormat:@"%@",[msgs objectForKey:@"enonce"]];
        NSLog(@"%@",ident);
        NSLog(@"%@",enonce);
        [_enonce loadHTMLString:enonce baseURL:nil];
    }
    else {
        //Your error message
    }
    
    // Disable Stop/Play button when application launches
    [_stopButton setEnabled:NO];
    [_playButton setEnabled:NO];
    
    // Set the audio file
    recordedFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"]];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:recordedFile settings:recordSetting error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recordPauseTapped:(id)sender {
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:.01f
                                                  target:self
                                                selector:@selector(timerUpdate)
                                                userInfo:nil
                                                 repeats:YES];

        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        [_recordPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        
    } else {
        
        // Pause recording
        [recorder pause];
        [_recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    }
    
    [_stopButton setEnabled:YES];
    [_playButton setEnabled:NO];
}

- (IBAction)stopTapped:(id)sender {
    if (player.playing) {
        [player stop];
        
    }
    else{
        [recorder stop];
        [_timer invalidate];
        _timer = nil;
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        _alert = [[UIAlertView alloc] init];
        [_alert setTitle:@"Waiting.."];
        
        UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activity.frame = CGRectMake(140,
                                    80,
                                    CGRectGetWidth(_alert.frame),
                                    CGRectGetHeight(_alert.frame));
    
    
        [_alert addSubview:activity];
        [activity startAnimating];
    
        [_alert show];
        
        [NSThread detachNewThreadSelector:@selector(toMp3) toTarget:self withObject:nil];
     }
    [_playButton setEnabled:YES];
    [_stopButton setEnabled:NO];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (IBAction)playTapped:(id)sender {
    if (!recorder.recording){
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
        [_playButton setEnabled:NO];
        [_stopButton setEnabled:YES];
    }
}

#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [_recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    [_stopButton setEnabled:NO];
    [_playButton setEnabled:YES];
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
- (void) timerUpdate
{
    if (recorder.recording)
    {
        int m = recorder.currentTime / 60;
        int s = ((int) recorder.currentTime) % 60;
        
        _timeText.text = [NSString stringWithFormat:@"%.2d:%.2d", m, s];
    }
}
- (void) toMp3
{
    NSString *cafFilePath =[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"];
    
    NSString *mp3FileName = @"Mp3File";
    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
    NSString *mp3FilePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:mp3FileName];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        NSLog(@"eee");
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        [self performSelectorOnMainThread:@selector(convertMp3Finish)
                               withObject:nil
                            waitUntilDone:YES];
    }
}

- (void) convertMp3Finish
{
    [_alert dismissWithClickedButtonIndex:0 animated:YES];
    
    _alert = [[UIAlertView alloc] init];
    [_alert setTitle:@"Finish"];
    [_alert addButtonWithTitle:@"OK"];
    [_alert setCancelButtonIndex: 0];
    [_alert show];
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    NSLog(@"tetetetetetetet");

}

@end
