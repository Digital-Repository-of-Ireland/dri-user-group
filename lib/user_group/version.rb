module UserGroup
  VERSION = "0.0.#{ENV['BUILD_NUMBER'] || 'dev'}"
  #VERSION = "0.0.5"
  #VERSION = `git describe --tags --abbrev=0`[1..-1].strip
end
