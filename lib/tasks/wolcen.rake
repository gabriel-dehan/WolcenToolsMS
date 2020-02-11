require_relative '../wolcen_toolbox'

namespace :wolcen do
  desc ""
  task :parse_modifiers => :environment do
    tools = WolcenToolbox.new
    # p tools.i18n[:modifiers].
    # ui_eim
    eims = []
    tools.i18n[:modifiers].xpath("//Row[.//*[contains(text(), 'ui_eim')]]").each do |row|
      nameNode, descriptionNode = row.search("Cell/Data")

      name = nameNode.text().gsub(/^ui_eim_/, '')
      if nameNode 
        name = nameNode.text().gsub(/^ui_eim_/, '')
        eims.push << {
          id: name,
          description: descriptionNode ? descriptionNode.text() : name.humanize(),
        }
      end
    end
    tools.write_to_file('modifiers', eims)
    
    puts "Done !"
  end

  desc "Parses XML tree data from Wolcen"
  # PST === Passive Skill Tree ;)
  task :parse_trees => :environment do
    tools = WolcenToolbox.new

    # = Parses global tree information =
    hash = tools.open_and_parse(tools.global_tree_path)
    # Swapping names so it has coherence vs client app
    base = { tree: { wheels: hash[:tree][:ring]} }

    # = Parse each tree and extract data = 
    base[:tree][:wheels].each do |wheel|
      if wheel[:section] 
        wheel[:section].each do |section|
          section[:id] = section[:name]
          section[:name] = tools.t(:passives, "ui_Section_#{section[:id]}")

          section_path = File.join(tools.trees_path, "PassiveSkills", "#{section[:id]}_tree.xml" )
          hash = tools.open_and_parse(section_path)
          
          category = hash[:meta_data][:tree][:category]
          section[:skills] = hash[:meta_data][:tree][:skill].map do |skill|
            # Bit of renaming
            skill[:id] = skill[:name]
            skill.delete(:name)
            
            skill[:position] = skill[:pos]
            skill.delete(:pos)

            skill[:name] = tools.t(:passives, "ui_#{skill[:id]}_name")
            skill[:description] = tools.t(:passives, "ui_#{skill[:id]}_desc")
            skill[:lore] = tools.t(:passives, "ui_#{skill[:id]}_lore")

            skill
          end
          pp section
        end
      end
      # pp wheel
      
    end
    
  end
end