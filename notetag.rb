class NoteTag
    attr_reader :operation
    attr_reader :data
    attr_reader :attributes
    def initialize(noteTagString)
        noteTagRegex = /<m:([a-z]+)(.*)>(.*)<\/m:\1>/
        elementRegex = /(\w+)\s*=\s*['"](.+)['"]/
        @attributes = Hash.new
        
        noteTagElements = noteTagRegex.match(noteTagString)
        
        if (!noteTagElements.nil?)
            @operation = noteTagElements[1]
            @data = noteTagElements[3]
            noteTagElements[2].split(/\s/).each { |attribute|
                if (attribute != "")
                    values = elementRegex.match(attribute)
                    @attributes[values[1]] = values[2]
                end
            }
        else
            raise "Invalid notetag syntax"
        end
    end
end

class NoteTagBlock
    attr_reader :noteTags
    def initialize(noteTagBlockString)
        @noteTags = Array.new
        noteTagBlockString
        noteTagBlockString.split("\n").each { |noteTagString|
            noteTag = NoteTag.new noteTagString
            @noteTags << noteTag
        }
    end
end