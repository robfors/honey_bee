require 'pathname'

require_relative 'honey_bee/no_entry_error'
require_relative 'honey_bee/entry'
require_relative 'honey_bee/directory'
require_relative 'honey_bee/file'

module HoneyBee

  def self.entry(path)
    raise 'Must pass path of file system entry as a String.' unless path.is_a?(String)
    raise NoEntryError unless ::File.exist?(path)
    if ::File.directory?(path)
      Directory.new(path)
    elsif ::File.file?(path)
      File.new(path)
    else
      raise 'Unkown entry type.'
    end
  end
  
end
