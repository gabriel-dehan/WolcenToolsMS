require 'json'

class WolcenToolbox
  attr_reader :base_raw_path, :base_parsed_path, :trees_path, :global_tree_path, :i18n

  def initialize()
    @base_raw_path = Rails.root.join("lib", "wolcen_raw_data")
    @base_parsed_path = Rails.root.join("lib", "wolcen_parsed_data")
    @trees_path = File.join(base_raw_path, "trees")
    @global_tree_path = File.join(trees_path, "PSTConfig", "Global_tree.xml")

    i18n_passives_path = File.join(base_raw_path, "i18n", "text_ui_passiveskills.xml")
    i18n_modifiers_path = File.join(base_raw_path, "i18n", "text_ui_EIM.xml")

    # Open i18n file
    @i18n = {
      passives: Nokogiri::XML(File.open(i18n_passives_path)),
      modifiers: Nokogiri::XML(File.open(i18n_modifiers_path)),
    }
    
    @i18n.map { |k, d| d.remove_namespaces!  }
  end

  def t(namespace, key)
    has_translation = i18n[namespace].xpath("//Row[.//*[contains(text(), '#{key}')]]//Cell[Data]").length >= 2
    if has_translation
      return i18n[namespace].xpath("//Row[.//*[contains(text(), '#{key}')]]//Cell[Data][last()]").text()
    else 
      return ""
    end
  end
  
  def convert_hash_keys(value)
    case value
      when Array
        value.map { |v| convert_hash_keys(v) }
        # or `value.map(&method(:convert_hash_keys))`
      when Hash
        Hash[value.map { |k, v| [k.underscore, convert_hash_keys(v)] }]
      else
        value
    end
  end

  def write_to_file(name, data)
    File.open("#{base_parsed_path}/#{name}.json", "w") do |f|
      f.write(data.to_json)
    end
  end

  def open_and_parse(path)
    xml_to_hash(File.open(path))
  end

  def xml_to_hash(xml)
    convert_hash_keys(Hash.from_xml(xml)).with_indifferent_access
  end
end