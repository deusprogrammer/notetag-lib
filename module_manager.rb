load 'notetag.rb'

class Mod
    def initialize(note_tag_block)
        note_tag_block.note_tags.each {|note_tag|
            self.instance_variable_set("@#{note_tag.label}", note_tag.data)
        }
        
        # Test
        self.instance_variables.each {|object| print "\t#{object} = #{self.instance_variable_get(object)}\n"}
    end
end

class MagazineMod < Mod
    def initialize(note_tag_block)
        print "MAGAZINE_MOD\n"
        super note_tag_block
    end
end

class StatsMod < Mod
    def initialize(note_tag_block)
        print "STAT_MOD\n"
        super note_tag_block
    end
end

class ActorEquipMod < Mod
    def initialize(note_tag_block)
        print "ACTOREQUIP_MOD\n"
        super note_tag_block
    end
end

class ModuleManager
    attr_reader :mods

    def initialize(noteTagString)
        @mods = []
        @note_tag_block = NoteTagBlock.new noteTagString
        
        @note_tag_block.modules.each { |mod|
            if (mod.has_children?)
                cls = get_mod_class mod
                mod = cls.new mod.data
                @mods.push mod
            end
        }
    end
    
    def get_mod_class(mod)
        cls = Object.const_get(mod.module_name.sub(/^./) { |m| m.upcase } + "Mod")
    end
end

note_tag_block_string = "<m:stats>" +
                            "<mp>30</mp>" +
                            "<skillSet type='magic'>" +
                                "<skill>Fire 1</skill>" +
                                "<skill>Fire 2</skill>" +
                            "</skillSet>" +
                        "</m:stats>" +
                        "<m:actorEquip>" +
                            "<actorSay actor='Melon' slot='dress'>I like this dress!</actorSay>" +
                            "<actorSay actor='Tess' slot='dress'>This isn't armor!</actorSay>" +
                        "</m:actorEquip>"

ModuleManager.new note_tag_block_string