class Wolcen::Utils::Eims
  attr_reader :tools, :eims_list
  
  def initialize
    @tools = Wolcen::Tools.new
    @eims_list = tools.parsed.fetch(trees: :eims)
  end

  def find(id)
    @eims_list.find { |eim| eim[:id] == id }
  end

  # Semantinc parsing
  # Rules found:
    # Affixes
      # - `Possibility` -> ?
      # - `Range` -> GOES WITH _Min & _Max
      # - `Radius` -> ?
      # - `Score` -> ?
      # - `Count` -> ?
    # Middle: 
      # - `Flat` -> Flat value
      # - `Percent` -> Percent value
      # - `Null` -> Flat value
    # Suffixes:
      # - `Float` -> parse as float
      # - `Int` -> parse as int
  # Most of those are inconsequential to us because we inject in a string here
  # This is a simplistic implementation for now, will be refined if need be
  def semantic_parser(name)
    affixes = name.underscore.split("_")
    {
      isRange: affixes.include?("range"),
      isRangeMinimum: affixes.include?("range") && affixes.include?("min"),
      isRangeMaximum: affixes.include?("range") && affixes.include?("max"),
      isPercentage: affixes.include?("percent"),
      type: affixes.include?("float") ? 'float' : 'integer'
    }
  end
  
  # A semantic is applied to an EIM, filling its values
  # TODO: 
  # The implementation is basic for ranges, 
  # it should probably check the name and look for the next corresponding one, 
  # remove them from array and continue on the others
  def semantics_to_substitutions(semantics)
    substitutions = []
    treatingRange = false
    
    semantics.each do |name, value| 
      parsed_semantic = semantic_parser(name)
 
      if parsed_semantic[:type] == 'float'
        substitution = value.to_f
      elsif parsed_semantic[:type] == 'integer'
        substitution = value.to_i
      else
        substitution = value
      end

      isNegative = substitution < 0
      substitution = substitution.to_s

      if parsed_semantic[:isPercentage]
        substitution += "%"
      end

      if parsed_semantic[:isRange]
        if parsed_semantic[:isRangeMinimum]
          treatingRange = true
          substitutions << [substitution]
        elsif parsed_semantic[:isRangeMaximum]
          lastRangeArray = substitutions.select { |s| s.is_a? Array }.last          
          lastRangeArray << substitution
          treatingRange = false
        end
      else
        if !isNegative
          substitution = "+#{substitution}"
        end

        substitutions << substitution
      end      
    end
    
    substitutions.map do |s|
      if s.is_a? Array
        s.join(" ~ ")
      else
        s
      end
    end
  end

  def inject_semantics(id, semantics)
    eim = self.find(id)
    
    if eim[:description]
      replacements_to_do_count = eim[:description].scan(/(%\d)/).length

      if replacements_to_do_count > 0
        substitutions = semantics_to_substitutions(semantics)
        # If there are too many things to replace in the string and we don't have enough semantic values, add a ? instead        
        (replacements_to_do_count - substitutions.length).times { substitutions << "?" }

        injectable_eim = eim[:description].gsub(/(%\d)/, '%s')
        description = injectable_eim % substitutions
      else 
        description = eim[:description]
      end
    else
      description = ""
    end

    description
  end
  

  def find_skill_eims(raw_data, key)
    all_skills_eims_data = raw_data[:meta_data][:spell]
    skill_eims = all_skills_eims_data.find { |eim| eim[:name] == key }
    if skill_eims
      eims = skill_eims[:magic_effects][:eim]
      # Ensure eims are a list even if there is only one
      eims = [eims] unless eims.is_a? Array
      eims
    else 
      []
    end 
  end
end