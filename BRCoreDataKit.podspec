Pod::Spec.new do |s|
  s.name         = "BRCoreDataKit"
  s.version      = "0.0.2"
  s.summary      = "A minimalist CoreData stack."

  s.description  = <<-DESC
                   Do you find MagicalRecord too complex and weighed down with
                   lots of baggage? Then this is for you. BRCoreDataKit strives
                   to be minimalistic and easy to use while still allowing
                   access to the full CoreData feature set if needed.
                   DESC

  s.homepage     = "http://bjornruud.net"
  s.license      = { :type => "MIT", :file => "LICENSE.txt" }
  s.author       = { "Bjørn Olav Ruud" => "mail@bjornruud.net" }
  s.ios.deployment_target = "6.0"
  s.osx.deployment_target = "10.8"
  s.source       = { :git => "https://bjorn@bitbucket.org/bjorn/brcoredatakit.git", :branch => "master" }
  s.source_files = "BRCoreDataKit/**/*.{h,m}"
  s.requires_arc = true
end
