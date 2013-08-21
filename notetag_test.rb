load 'notetag.rb'

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
                        "</m:actorEquip>" +
                        "<m:limitedUses uses=1 />"

# Ability to get class name by name
cls = Object.const_get('NoteTagBlock')
note_tag_block = cls.new note_tag_block_string
note_tag_block.debug

# Reflection experimentation
print "CLASS VARIABLES: \n"
NoteTagBlock.class_variables.each {|variable|
    print "\t#{variable}\n"
}

print "INSTANCE VARIABLES: \n"
note_tag_block.instance_variables.each {|object|
    print "\t#{object} = #{note_tag_block.instance_variable_get(object)}\n"
}

# Get methods belonging to a object type
print "METHODS: \n"
NoteTagBlock.methods.each {|method|
    print "\t#{method}\n"
}