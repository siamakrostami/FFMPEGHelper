# FFMPEGHelper

Convert audio and video files using ffmpeg in swift

## Example

To see the example project, clone the repo and run `pod install`.

## Usage

Instance viewModel and set delegation:

```ruby
var converterViewModel : ConverterViewModel!

```

```ruby

 fileprivate func initData(){
        self.convertViewModel = ConverterViewModel()
        self.convertViewModel.delegate = self
  }
    
```

Start converting local files:

```ruby

 func ConvertLocalFile(){
        let url = Bundle.main.url(forResource: "Your_Media_File_Name", withExtension: "Your_Media_File_Extension")
        guard let inputUrl = url else{return}
        
        // For audio content
        self.convertViewModel.convertAudioFrom(url: inputUrl, quality: .low)
        
        // For video content
        self.convertViewModel.convertVideoFrom(url: inputUrl)
    }
    
```

Work with delegation methods:

```ruby

extension YourViewController : ConvertProgressProtocols{
    // Converting Progress
    func ConvertProgress(progress: Int32) {
    
    // calculate progress 
        calculateProgressPercentage(current: progress)
    }
    
    // Converting Status
    func ConvertStatus(status: Int32) {
        debugPrint("status : \(status)")
        if status == RETURN_CODE_SUCCESS{
            // Do something like playing converted media
        }
    }
    
    // Converting Log
    func ExecutionStatus(executionId: Int, level: Int32, message: String!) {
        debugPrint("message : \(String(describing: message))")
    }
    
}

```

## License

FFMPEGHelper is available under the MIT license. See the LICENSE file for more info.
    
