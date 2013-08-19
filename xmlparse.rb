class NoteTag
    attr_reader   :label
    attr_reader   :attributes
    attr_accessor :children
    def initialize(tagString)
        @label = ""
        @attributes = Hash.new
        @children = []
        openTagRegex = /<m:([a-zA-Z]+)(.*)>/
        elementRegex = /(\w+)\s*=\s*['"](.+)['"]/
        
        openTagElements = openTagRegex.match(tagString)
        if(!openTagElements.nil?)
            @label = openTagElements[1]
            openTagElements[2].split(/\s+/).each { |attribute|
                if (attribute != "")
                    values = elementRegex.match(attribute)
                    @attributes[values[1]] = values[2]
                end
            }
        end
    end
end

class CloseTag
    attr_reader :label
    def initialize(tagString)
        @label = ""
        closeTagRegex = /<\/m:([a-zA-Z]+)>/
        
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
    attr_reader :tag
    attr_reader :data
    attr_reader :attributes
    attr_reader :note_tags
    
    def initialize(noteTagString)
        @note_tags = []
        parseXml noteTagString
    end
    
    def parseXml(noteTagString)
        # Read until a tag is read
        data = ""
        open_tag_data = ""
        open_tag = nil
        close_tag_data = ""
        state = :START
        noteTagString.each_char { |byte|
            # While in start state, look for start of first tag
            case state
            when :START
                if (byte == '<')
                    open_tag_data += byte
                    
                    print "TRANSITION READING_OPEN_TAG\n"
                    state = :READING_OPEN_TAG
                end
            when :READING_OPEN_TAG
                open_tag_data += byte
                if (byte == '>')
                    open_tag = NoteTag.new open_tag_data
                    print "Searching for #{open_tag.label}\n"
                    print "Attributes #{open_tag.attributes}\n"
                    
                    print "TRANSITION SEARCH_CLOSE_TAG\n"
                    state = :SEARCH_CLOSE_TAG
                end
            when :SEARCH_CLOSE_TAG
                if (byte == '<')
                    close_tag_data += byte
                    
                    print "TRANSITION VERIFY_CLOSE_TAG\n"
                    state = :VERIFY_CLOSE_TAG
                else
                    data += byte    
                end
            when :VERIFY_CLOSE_TAG
                close_tag_data += byte
                if (byte != '/')
                    print "ADDING #{close_tag_data} TO DATA\n"
                    data += close_tag_data
                    close_tag_data = ""
                    
                    print "TRANSITION SEARCH_CLOSE_TAG\n"
                    state = :SEARCH_CLOSE_TAG
                else
                    print "TRANSITION READING_CLOSE_TAG\n"
                    state = :READING_CLOSE_TAG
                end
            when :READING_CLOSE_TAG
                close_tag_data += byte
                if (byte == '>')
                    close_tag = CloseTag.new close_tag_data
                    print "**#{close_tag.label}** vs **#{open_tag.label}**\n"
                    if (close_tag.label != open_tag.label)
                        print "ADDING #{close_tag_data} TO DATA\n"
                        data += close_tag_data
                        close_tag_data = ""
                        
                        print "TRANSITION SEARCH_CLOSE_TAG\n"
                        state = :SEARCH_CLOSE_TAG
                    else
                        # Add this child to note_tag and then parse remaining tags
                        print "**********************************\n"
                        print "DATA:      #{data}\n"
                        print "Tag        #{open_tag.label}\n"
                        print "Attributes #{open_tag.attributes}\n"
                        print "Note Tags  #{note_tags}\n"
                        print "**********************************\n"
                        if (!data.nil? && data != "")
                            open_tag.children.push NoteTagBlock.new data
                        end
                        
                        note_tags.push open_tag
                        
                        print "TRANSITION START\n"
                        state = :START
                    end
                end
            else
            end
        }
        #print "**********************************\n"
        #print "DATA:      #{data}\n"
        #print "Tag        #{open_tag.label}\n"
        #print "Attributes #{open_tag.attributes}\n"
        #print "Note Tags  #{note_tags}\n"
        #print "**********************************\n"
        
        # Add last children to note_tag
        #if (!data.nil? && data != "")
        #    open_tag.children += NoteTagBlock.new data
        #end
        #note_tags += open_tag
    end
end

def print_note_tag_block(noteTagBlock, depth = 0)
    noteTagBlock.note_tags.each {|note_tag|
        depth.times {print "\t"}
        print "TAG: #{note_tag.label}\n"
        depth.times {print "\t"}
        print "ATTRIBUTES:\n"
        note_tag.attributes.each {|key, value|
            depth.times {print "\t"}
            print "\t#{key} => #{value}\n"
        }
        depth.times {print "\t"}
        if (note_tag.children.size > 0)
            print "CHILDREN:\n"
            note_tag.children.each {|child|
                print_note_tag_block child, depth + 1
            }
        end
    }
end

note_tag_block = NoteTagBlock.new "<m:actorEquip action='say'><m:actorDo action='changeClass'></m:actorDo></m:actorEquip>"
print_note_tag_block note_tag_block