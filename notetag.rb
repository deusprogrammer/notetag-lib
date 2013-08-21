class NoteTag
    attr_reader   :label
    attr_reader   :attributes
    attr_accessor :data
    
    def initialize(tagString)
        @label = ""
        @attributes = Hash.new
        @data = nil
        openTagRegex = /<(\S+)\s*(.*)>/
        elementRegex = /(\w+)\s*=\s*['"]*([a-zA-Z0-9]+)['"]*/
        
        NoteTagBlock.print_debug "TAG STRING: #{tagString}\n"
        
        openTagElements = openTagRegex.match(tagString)
        if(!openTagElements.nil? && openTagElements.size > 0)
            @label = openTagElements[1]
            if (!openTagElements[2].nil? && openTagElements[2] != "")
                openTagElements[2].split(/\s+/).each { |attribute|
                    if (!attribute.nil?)
                        values = elementRegex.match(attribute)
                        if (!values.nil? && values.size == 3)
                            @attributes[values[1]] = values[2]
                        end
                    end
                }
            end
        end
    end
    
    def has_children?
        return !@data.nil? && @data.is_a?(NoteTagBlock)
    end
    
    def has_data?
        return !@data.nil? && @data.is_a?(String)
    end
    
    def has_attributes?
        return @attributes.size > 0
    end
    
    def is_module?
        moduleRegex = /m:(\S+)/
        modElements = moduleRegex.match(label)
        if (modElements.nil? || modElements.size == 0)
            return false
        end
        return true
    end
    
    def module_name
        moduleRegex = /m:(\S+)/
        modElements = moduleRegex.match(label)
        if (modElements.nil? || modElements.size == 0)
            return nil
        end
        return modElements[1]
    end
end

class CloseTag
    attr_reader :label
    def initialize(tagString)
        @label = ""
        closeTagRegex = /<\/(\S+)>/
        
        closeTagElements = closeTagRegex.match(tagString)
        if(!closeTagElements.nil?)
            @label = closeTagElements[1]
        end
    end
end

:START
:DONE
:READING_OPEN_TAG
:READING_CLOSE_TAG
:VERIFY_CLOSE_TAG
:SEARCH_CLOSE_TAG

class NoteTagBlock
    attr_reader :note_tags
    attr_reader :data

    @@debug_mode = false
    
    def self.debug_mode=value
        @@debug_mode = value
    end
    
    def self.print_debug(str)
        if (@@debug_mode)
            print str
        end
    end
    
    def initialize(noteTagString)
        # Read until a tag is read
        @note_tags = []
        data = ""
        open_tag_data = ""
        open_tag = nil
        close_tag_data = ""
        state = :START
        
        NoteTagBlock.print_debug "-------------------------------------------\n"
        NoteTagBlock.print_debug "#{noteTagString}\n"
        NoteTagBlock.print_debug "-------------------------------------------\n"
        
        noteTagString.each_char { |byte|
            # While in start state, look for start of first tag
            # print "#{byte}\n"
            case state
            when :START
                if (byte == '<')
                    open_tag_data += byte
                    
                    NoteTagBlock.print_debug "TRANSITION READING_OPEN_TAG\n"
                    state = :READING_OPEN_TAG
                end
            when :READING_OPEN_TAG
                open_tag_data += byte
                if (byte == '>')
                    open_tag = NoteTag.new open_tag_data
                    NoteTagBlock.print_debug "Searching for #{open_tag.label}\n"
                    NoteTagBlock.print_debug "Attributes #{open_tag.attributes}\n"
                    
                    NoteTagBlock.print_debug "TRANSITION SEARCH_CLOSE_TAG\n"
                    state = :SEARCH_CLOSE_TAG
                elsif (byte == '/')
                    open_tag = NoteTag.new open_tag_data + ">"
                    # Add this child to note_tag and then parse remaining tags
                    NoteTagBlock.print_debug "**********************************\n"
                    NoteTagBlock.print_debug "Tag        #{open_tag.label}\n"
                    NoteTagBlock.print_debug "Attributes #{open_tag.attributes}\n"
                    NoteTagBlock.print_debug "**********************************\n"
                    
                    @note_tags.push open_tag
                    
                    data = ""
                    close_tag_data = ""
                    open_tag_data = ""
                    
                    NoteTagBlock.print_debug "TRANSITION START\n"
                    state = :START
                end
            when :SEARCH_CLOSE_TAG
                if (byte == '<')
                    close_tag_data += byte
                    
                    NoteTagBlock.print_debug "TRANSITION VERIFY_CLOSE_TAG\n"
                    state = :VERIFY_CLOSE_TAG
                else
                    data += byte    
                end
            when :VERIFY_CLOSE_TAG
                close_tag_data += byte
                if (byte != '/')
                    data += close_tag_data
                    close_tag_data = ""
                    
                    NoteTagBlock.print_debug "TRANSITION SEARCH_CLOSE_TAG\n"
                    state = :SEARCH_CLOSE_TAG
                else
                    NoteTagBlock.print_debug "TRANSITION READING_CLOSE_TAG\n"
                    state = :READING_CLOSE_TAG
                end
            when :READING_CLOSE_TAG
                close_tag_data += byte
                if (byte == '>')
                    close_tag = CloseTag.new close_tag_data
                    NoteTagBlock.print_debug "**#{close_tag.label}** vs **#{open_tag.label}**\n"
                    if (close_tag.label != open_tag.label)
                        data += close_tag_data
                        close_tag_data = ""
                        
                        NoteTagBlock.print_debug "TRANSITION SEARCH_CLOSE_TAG\n"
                        state = :SEARCH_CLOSE_TAG
                    else
                        # Add this child to note_tag and then parse remaining tags
                        NoteTagBlock.print_debug "**********************************\n"
                        NoteTagBlock.print_debug "DATA:      #{data}\n"
                        NoteTagBlock.print_debug "Tag        #{open_tag.label}\n"
                        NoteTagBlock.print_debug "Attributes #{open_tag.attributes}\n"
                        NoteTagBlock.print_debug "**********************************\n"
                        if (!data.nil? && data != "" && (data.include?("<") && data.include?(">")))
                            open_tag.data = NoteTagBlock.new data
                        elsif (!data.nil? && data != "" && !(data.include?("<") || data.include?(">")))
                            open_tag.data = data
                        end
                        
                        @note_tags.push open_tag
                        
                        data = ""
                        close_tag_data = ""
                        open_tag_data = ""
                        
                        NoteTagBlock.print_debug "TRANSITION START\n"
                        state = :START
                    end
                end
            else
            end
        }
    end
    
    def get_note_tag(note_tag_name)
        return @note_tags.select {|note_tag| note_tag.label == note_tag_name}
    end
    
    def get_module(module_name)
        return @note_tags.select {|note_tag| note_tag.is_module? && note_tag.module_name == module_name}
    end
    
    def modules()
        return @note_tags.select {|note_tag| note_tag.is_module?}
    end
    
    def all()
        return @note_tags
    end
    
    def debug(depth = 0)
        @note_tags.each {|note_tag|
            depth.times {print "   "}
            if (note_tag.is_module?)
                print "MODULE: #{note_tag.module_name}\n"
            else
                print "TAG: #{note_tag.label}\n"
            end
            depth.times {print "   "}
            if (note_tag.has_attributes?)
                print "ATTRIBUTES:\n"
                note_tag.attributes.each {|key, value|
                    depth.times {print "   "}
                    print "\t#{key} => #{value}\n"
                }
            end
            depth.times {print "   "}
            if (note_tag.has_children?)
                print "DATA: "
                note_tag.data.debug depth + 1
            elsif (note_tag.has_data?)
                print "DATA:   #{note_tag.data}\n"
            end
            print "\n"
        }
    end
end