module UserGroup
#  output = `git describe --tags`.strip.split('-')
#
#  version = output.shift
#  version = version.gsub 'v', ''
#  increment = output.shift
#  #hash = output.shift
#
#  VERSION  = "0.0.#{increment}"
  VERSION = "2.3.0"
end
