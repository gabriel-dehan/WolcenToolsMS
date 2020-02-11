class Wolcen::RawsManager
  attr_reader :base_path

  def initialize 
    @base_path = Rails.root.join("lib", "wolcen_raw_data")

    @global_tree_path = File.join(base_path, "trees", "PSTConfig", "Global_tree.xml")
    @trees_skills_path = File.join(base_path, "trees", "PassiveSkills" )
    @trees_eims_path = File.join(base_path, "passive", "PST")
    
    @raws = {
      trees: {
        metadata: RawFile.new(:metadata, @global_tree_path),
        eims: RawFolder.new(:trees_eims, @trees_eims_path),
        skills: RawFolder.new(:trees_skills, @trees_skills_path)
      }
    }
  end

  # Not very clear or optimised needs improvement
  def fetch(params)
    params.map do |namespace, content|
      if content.kind_of? Hash
        content.map do |subspace, id|
          @raws[namespace][subspace].openById(id)
        end.first
      else
        @raws[namespace][content].open()
      end
    end.first
  end

  def self.convert_hash_keys(value)
    case value
      when Array
        value.map { |v| convert_hash_keys(v) }
      when Hash
        Hash[value.map { |k, v| [k.underscore, convert_hash_keys(v)] }]
      else
        value
    end
  end

  def self.xml_to_hash(xml)
    convert_hash_keys(Hash.from_xml(xml)).with_indifferent_access
  end

  def self.open_and_parse(path)
    xml_to_hash(File.open(path))
  end
end

# Private classes
class RawFolder
  FILES_PATTERNS = {
    trees_eims: "_PST_%1.xml",
    trees_skills: "%1_tree.xml"
  }

  def initialize(name, path)
    @name = name
    @path = path
  end

  def openById(id)
    file_name = FILES_PATTERNS[@name].gsub(/%1/, id)
    Wolcen::RawsManager.open_and_parse(File.join(@path, file_name))
  end
end

class RawFile
  attr_reader :path, :name

  def initialize(name, path)
    @name = name
    @path = path
  end

  def open
    Wolcen::RawsManager.open_and_parse(@path)
  end
end