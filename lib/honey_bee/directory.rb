module HoneyBee
  class Directory < Entry
  
    def initialize(path)
      super
      raise 'Must pass path of a directory as argument.' if exist? && !::File.directory?(@path)
    end
    
    def children
      children_enum.to_a
    end
    
    def children_enum
      return enum_for(:children_enum) unless block_given?
      raise NoEntryError unless exist?
      Dir.foreach(@path) do |entry|
        next if entry == '.' || entry == '..'
        temp_path = (Pathname.new(@path) + Pathname.new(entry)).to_path
        HoneyBee.entry(temp_path)
      end
    end
    
    def descendants
      descendants_enum.to_a
    end
    
    def descendants_enum
      return enum_for(:descendants_enum) unless block_given?
      raise NoEntryError unless exist?
      children.each do |child|
        yield child
        if child.is_a?(Directory)
          child.descendants { |descendant| yield descendant }
        end
      end
    end
    
  end
end
