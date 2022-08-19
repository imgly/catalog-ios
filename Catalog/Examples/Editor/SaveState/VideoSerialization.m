#import "VideoSerialization.h"
@import VideoEditorSDK;

@interface VideoSerializationObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoSerializationObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  // highlight-setup
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Create a default `PESDKConfiguration`.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] init];

  // Create and present the video editor. Make this class the delegate of it to handle export and cancelation.
  PESDKVideoEditViewController *videoEditViewController = [[PESDKVideoEditViewController alloc] initWithVideoAsset:video configuration:configuration];
  videoEditViewController.delegate = self;
  videoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
  [self.presentingViewController presentViewController:videoEditViewController animated:YES completion:nil];
  // highlight-setup
}

#pragma mark - PESDKVideoEditViewControllerDelegate

- (BOOL)videoEditViewControllerShouldStart:(PESDKVideoEditViewController * _Nonnull)videoEditViewController task:(PESDKVideoEditorTask * _Nonnull)task {
  // Implementing this method is optional. You can perform additional validation and interrupt the process by returning `NO`.
  return YES;
}

- (void)videoEditViewControllerDidFinish:(PESDKVideoEditViewController * _Nonnull)videoEditViewController result:(PESDKVideoEditorResult * _Nonnull)result {
  // The user exported a new video successfully and the newly generated video is located at `result.output.url`.

  // To get an `NSData` object of all edits which have been applied to a video, you can use the following method.
  // highlight-serialization
  NSData *serializedSettings = videoEditViewController.serializedSettings;

  // Optionally, you can convert the serialized settings to a JSON string if needed.
  NSString *jsonString = [[NSString alloc] initWithData:serializedSettings encoding:NSUTF8StringEncoding];
  NSLog(@"%@", jsonString);

  // Or to an `NSDictionary`.
  NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:serializedSettings options:0 error:nil];
  NSLog(@"%@", jsonDict);
  // highlight-serialization

  // You can use either `serializedSettings`, `jsonString`, or `jsonDict` for further processing, such as
  // uploading it to a remote URL or saving it to the filesystem. See `SaveVideoToRemoteURLObjC` or
  // `SaveVideoToFilesystemObjC` to get an idea about the approach to take for this.

  // For loading serialized settings into the editor, please take a look at `VideoDeserializationObjC`.

  // The above serialization just stores the edit model and not the edited asset which could be either a
  // single video or a video composition of multiple video segments. In order to be able to fully restore and
  // continue a previous video editing session including the complete video composition state the original
  // video size and the individual video segments need to be saved. `OpenVideoFromMultipleVideoClipsObjC`
  // shows how to initialize the editor with these video segments. The video size can be provided as an optional
  // parameter when initializing a `PESDKVideo`.
  // highlight-composition
  NSLog(@"Video size: (%.f, %.f)", result.task.video.size.width, result.task.video.size.height);
  NSLog(@"Video segments:");
  for (PESDKVideoSegment *segment in result.task.video.segments) {
    NSLog(@"URL: %@ startTime: %@ endTime: %@", segment.url, segment.startTime, segment.endTime);
  }
  // highlight-composition

  // Dismiss the editor.
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)videoEditViewControllerDidFail:(PESDKVideoEditViewController * _Nonnull)videoEditViewController error:(PESDKVideoEditorError * _Nonnull)error {
  // There was an error generating the video.
  NSLog(@"%@", error.localizedDescription);
  // Dismissing the editor.
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)videoEditViewControllerDidCancel:(PESDKVideoEditViewController * _Nonnull)videoEditViewController {
  // The user tapped on the cancel button within the editor. Dismissing the editor.
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
