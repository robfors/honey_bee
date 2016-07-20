module HoneyBee
  class Entry
  
    attr_reader :path
    
    def initialize(path)
      raise 'Must pass path of file system entry as a String.' unless path.is_a?(String)
      pathname = Pathname.new(path)
      if pathname.absolute?
        @path = pathname.cleanpath.to_path
      else
        @path = Pathname.new(File.absolute_path(path)).cleanpath.to_path
      end
    end
    
    def ancestors
      ancestors_enum.to_a
    end
    
    def ancestors_enum
      return enum_for(:ancestors_enum) unless block_given?
      entry = self
      loop do
        entry = entry.parent
        break if entry.nil?
        yield entry
      end
    end
    
    def children
      children_enum.to_a
    end
    
    def children_enum
      raise NoEntryError unless exist?
      raise WrongEntryError unless directory?
      return enum_for(:children_enum) unless block_given?
      Dir.foreach(@path) do |entry|
        next if entry == '.' || entry == '..'
        temp_entry = descendant(entry)
        yield temp_entry
      end
    end
    
    def copy_to(entry, new_name = nil)
      raise NoEntryError unless exist?
      raise WrongEntryError, "Can only copy into an existing directory." unless entry.directory?
      new_entry = new_name ? entry.child(new_name) : entry.child(name)
      binding.pry
      FileUtils.copy(@path, new_entry.path)
      new_entry
    end
    
    def descendant(path)
      raise 'Must pass path of file system entry as a String.' unless path.is_a?(String)
      Entry.new(::File.join(@path, path))
    end
    
    def descendants(glob_path = nil)
      raise 'Path of file system entries must be a String.' unless path == nil || path.is_a?(String)
      descendants_enum(glob_path).to_a
    end
    
    def descendants_enum(glob_path = nil)
      raise 'Path of file system entries must be a String.' unless path == nil || path.is_a?(String)
      raise NoEntryError unless exist?
      raise WrongEntryError unless directory?
      return enum_for(:descendants_enum, glob_path) unless block_given?
      if glob_path
        full_glob_path = ::File.join(@path, glob_path)
        Pathname.glob(full_glob_path).map(&:to_path).each { |path| yield Entry.new(path) }
      else
        children.each do |child|
          yield child
          if child.directory?
            child.descendants.each { |descendant| yield descendant }
          end
        end
      end
    end
    
    def descendant_of?(entry)
      raise 'Must pass an Entry.' unless entry.is_a?(Entry)
      ancestors.include?(entry)
    end
    
    def directory?
      ::File.directory?(@path)
    end
    
    def exist?
      ::File.exist?(@path)
    end
    
    def file?
      ::File.file?(@path)
    end
    
    def move_to(entry)
      raise NoEntryError unless exist?
      raise WrongEntryError, "Can only move into an existing directory." unless entry.directory?
      new_entry = entry.child(name)
      binding.pry
      FileUtils.move(@path, new_entry.path)
      @path = new_entry.path
      nil
    end
    
    def name
      ::File.basename(@path)
    end
    
    def parent
      entry = Entry.new(Pathname.new(@path).parent.to_path)
      if entry == self
        nil
      else
        entry
      end
    end
    
    alias_method :parent=, :move_to
    
    def relative_path_from(base_entry)
      raise 'Must pass a base Entry.' unless base_entry.is_a?(Entry)
      Pathname.new(@path).relative_path_from(Pathname.new(base_entry.path)).to_path
    end
    
    def remove
      raise NoEntryError unless exist?
      binding.pry
      FileUtils.remove_entry(@path)
      nil
    end
    
    def rename(new_name)
      raise NoEntryError unless exist?
      raise "Name must be a string." unless new_name.is_a?(String)
      new_entry = parent.child(new_name)
      binding.pry
      ::File.rename(@path, new_entry.path)
      @path = new_entry.path
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
    
    def to_s
      "#<HoneyBee::Entry '#{@path}'>"
    end
    
    alias_method :inspect, :to_s
    
    def ==(other)
      raise "Can only compare with other Entries." unless other.respond_to?(:path)
      @path == other.path
    end
    
    alias_method :eql?, :==
    
  end
end
