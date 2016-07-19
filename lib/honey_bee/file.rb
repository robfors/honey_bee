module HoneyBee
  class File < Entry
  
    def initialize(path)
      super
      raise 'Must pass path of a file as argument.' if exist? && !::File.file?(@path)
    end
    
  end
end
