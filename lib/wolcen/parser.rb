class Wolcen::Parser
  class << self
    # EIM = Entity Internal Modifiers 
    def parse_eim!
      tools = Wolcen::Tools.new
      eims = []

      rows = tools.i18n.fetch(:eims).where(text: 'ui_eim')
      rows.each do |row|
        nameNode, descriptionNode = row.search("Cell/Data")
        if nameNode 
          name = nameNode.text().gsub(/^ui_eim_/, '')
          eims.push << {
            id: name,
            description: descriptionNode ? descriptionNode.text() : name.humanize(),
          }
        end
      end

      eims
    end

    # PST = Passive Skill Trees
    def parse_pst!
      tools = Wolcen::Tools.new
      i18n = tools.i18n.fetch(:pst)
      pst = []

      # = Parses global tree information =
      root = tools.raws.fetch(trees: :metadata)
      # Swapping names so it has coherence vs client app
      trees = { wheels: root[:tree][:ring] }

      # = Parse each tree and extract data = 
      trees[:wheels].each do |wheel|
        if wheel[:section] 
          wheel[:section].each do |section|
            section[:id]   = section[:name]
            section[:name] = i18n.t("ui_Section_#{section[:id]}")
            
            section_eims   = tools.raws.fetch(trees: { eims: section[:id] })
            section_skills = tools.raws.fetch(trees: { skills: section[:id] })
            
            section[:category] = section_skills[:meta_data][:tree][:category]
            section[:skills] = section_skills[:meta_data][:tree][:skill].map do |skill|
              # Bit of renaming
              skill[:id] = skill.delete(:name)
              skill[:position] = skill.delete(:pos)

              # Extract translation data
              skill[:name] = i18n.t("ui_#{skill[:id]}_name")
              skill[:description] = i18n.t("ui_#{skill[:id]}_desc")
              skill[:lore] = i18n.t("ui_#{skill[:id]}_lore")

              # Extract skill eims (modifiers)
              eims_utils = Wolcen::Utils::Eims.new
              skill_eims = eims_utils.find_skill_eims(section_eims, skill[:id])

              skill[:eims] = skill_eims.map do |eim_data|
                description = eims_utils.inject_semantics(eim_data[:name], eim_data[:semantics])

                {
                  id: eim_data[:name],
                  description: description,
                  permanent: eim_data[:permanent],
                  semantics: eim_data[:semantics],
                }
              end
              skill
            end
            # pp section
          end
        end
        wheel
      end
    end
  end
end

