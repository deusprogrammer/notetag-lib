class OpenTag
    attr_reader :label
    def initialize(tagString)
        @label = ""
        @attributes = Hash.new
        openTagRegex = /<m:([a-zA-Z]+)(.*)>/
        
        openTagElements = openTagRegex.match(tagString)
        if(!openTagElements.nil?)
            @label = openTagElements[1]
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

class NoteTag
    attr_reader :operation
    attr_reader :data
    attr_reader :attributes
    
    def initialize(noteTagString)
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
            print "BYTE: #{byte}\n"
            # While in start state, look for start of first tag
            case state
            when :START
                if (byte == '<')
                    print "TRANSITION READING_OPEN_TAG\n"
                    open_tag_data += byte
                    state = :READING_OPEN_TAG
                end
            when :READING_OPEN_TAG
                open_tag_data += byte
                if (byte == '>')
                    print "TRANSITION SEARCH_CLOSE_TAG\n"
                    state = :SEARCH_CLOSE_TAG
                    open_tag = OpenTag.new open_tag_data
                end
            when :SEARCH_CLOSE_TAG
                print "Searching for #{open_tag.label}\n"
                if (byte == '<')
                    print "TRANSITION VERIFY_CLOSE_TAG\n"
                    close_tag_data += byte
                    state = :VERIFY_CLOSE_TAG
                else
                    data += byte    
                end
            when :VERIFY_CLOSE_TAG
                close_tag_data += byte
                if (byte != '/')
                    print "TRANSITION SEARCH_CLOSE_TAG\n"
                    state = :SEARCH_CLOSE_TAG
                    print "ADDING #{close_tag_data} TO DATA\n"
                    data += close_tag_data
                    close_tag_data = ""
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
                        print "TRANSITION SEARCH_CLOSE_TAG\n"
                        print "ADDING #{close_tag_data} TO DATA\n"
                        data += close_tag_data
                        close_tag_data = ""
                        state = :SEARCH_CLOSE_TAG
                    else
                        print "TRANSITION DONE\n"
                        state = :DONE
                    end
                end
            when :DONE
                # Feed data down into a new NoteTag object
                print "DATA: #{data}\n"
                if (!data.nil? && data != "")
                    children = NoteTag.new data
                end
                print "TRANSITION START\n"
                state = :START
            else
            end
        }
        print "DATA: #{data}\n"
        if (!data.nil? && data != "")
            children = NoteTag.new data
        end
    end
end

noteTag = NoteTag.new "<m:actorEquip action='say'><m:actorDo action='changeClass'></m:actorDo></m:actorEquip>"