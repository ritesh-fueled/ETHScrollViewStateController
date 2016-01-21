Pod::Spec.new do |spec|
  spec.name         =  'ETHScrollViewStateController'
  spec.version      =  '0.1'
  spec.summary   =  'It configures and manages states for a scrollView like Normal, Ready, Loading & provide delegate methods to make api calls or handle custom loader animations'
  spec.author = {
    'Ritesh Gupta' => 'ritesh@fueled.com'
  }
  spec.license          =  'MIT' 
  spec.homepage         =  'https://github.com/ritesh-fueled/ETHScrollViewStateController'
  spec.source = {
    :git => 'https://github.com/ritesh-fueled/ETHScrollViewStateController.git',
    :tag => '0.1'
  }
  spec.ios.deployment_target = "8.0"
  spec.source_files =  'Source/*.{swift}'
  spec.requires_arc     =  true
end