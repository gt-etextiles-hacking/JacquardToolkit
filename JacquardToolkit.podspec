Pod::Spec.new do |s|

  s.name          = "JacquardToolkit"
  s.version       = "1.1.8"
  s.summary       = "This development toolkit for the Levi's Jacquard."
  s.description   = "This is a framework for interacting with the Levi's Jacquard made by Caleb Rudnicki"
  s.homepage      = "https://github.com/gt-etextiles-hacking/JacquardToolkit"
  s.license       = "MIT"
  s.author        = { "Caleb Rudnicki" => "calebrudnicki@gmail.com" }
  s.platform      = :ios, "11.0"
  s.source        = { :git => "https://github.com/gt-etextiles-hacking/JacquardToolkit.git", :tag => s.version }
  s.source_files  = "JacquardToolkit/**/*.{h,m,swift,mlmodel}"
  s.exclude_files = [ 'JacquardToolkit/CustomGestureModels/**']
  
  s.resources = "JacquardToolkit/*,mp4"
  s.resource_bundles = {
      'JacquardToolkit' => ['JacquardToolkit/Pods/**/*.mp4']
  }
  
end
