module HoneyBee
  class Entry
  
    attr_reader :path
    
    def initialize(path)
      raise 'Must pass path of file system entry as a String.' unless path.is_a?(String)
      pathname = Pathname.new(path)
      if pathname.absolute?
        @path = pathname.cleanpath.to_path
      else
        raise NoEntryError unless ::File.exist?(path)
        @path = pathname.realpath.to_path
      end
    end
    
    def ancestors
      ancestors_enum.to_a
    end
    
    def ancestors_enum
      return enum_for(:ancestors_enum) unless block_given?
      node = self
      until node.nil?
        node = node.parent
        yield node
      end
    end
    
    def copy_to(directory)
      raise NoEntryError unless ::File.exist?(path)
      raise "Can only copy to a directory." unless directory.is_a?(Directory)
      new_path = (Pathname.new(directory.path) + Pathname.new(name)).to_path
      FileUtils.copy(@path, new_path)
      self.class.new(new_path)
    end
    
    alias_method :eql?, :==
    
    def exist?
      ::File.exist?(@path)
    end
    
    def move_to(directory)
      raise NoEntryError unless ::File.exist?(path)
      raise "Can only move to a directory." unless directory.is_a?(Directory)
      new_path = (Pathname.new(directory.path) + Pathname.new(name)).to_path
      FileUtils.move(@path, new_path)
      @path = new_path
      nil
    end
    
    def name
      ::File.basename(@path)
    end
    
    def parent
      directory = Directory.new(Pathname.new(@path).parent.to_path)
      if directory == self
        nil
      else
        directory
      end
    end
    
    alias_method :parent=, :move_to
    
    def remove
      raise NoEntryError unless exist?
      FileUtils.remove_entry(@path)
      nil
    end
    
    def rename(new_name)
      raise "Name must be a string." unless new_name.is_a?(String)
      new_path = (Pathname.new(parent.path) + Pathname.new(new_name)).to_path
      ::File.rename(@path, new_path) if exist?
      @path = new_path
      nil
    end
    
    alias_method :name=, :rename
    
    def siblings
      siblings_enum.to_a
    end
    
    def siblings_enum
      return enum_for(:siblings_enum) unless block_given?
      return nil unless parent
      parent.children.each do |child|
        yield child unless child == self
      end
    end
    
    def ==(other)
      raise "Can only compare with other Files and Directories." unless other.respond_to?(:path)
      @path == other.path
    end
    
    def relative(path)
      HoneyBee.entry(::File.join(@path, path))
    end
    
    def relatives(path)
      glop_path = ::File.join(@path, path)
      Pathname.glob(glop_path).map(&:to_path).map { |path| HoneyBee.entry(path) }
    end
    
    def relative_path_from(base_directory)
      Pathname.new(@path).relative_path_from(base_directory)
    end
    
    def descendant_of?(directory)
      ancestors.include?(directory)
    end
  
  end
end
