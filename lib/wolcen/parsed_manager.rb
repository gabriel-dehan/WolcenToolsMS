class Wolcen::ParsedManager
  attr_reader :base_path
  
  def initialize
    @base_path = Rails.root.join("lib", "wolcen_parsed_data")
    @eims_path = File.join(base_path, 'eims.json')

    # PARSED PATHS    
    @parsed = {
      trees: {
        eims: ParsedFile.new(:eims, @eims_path, default: [])
      }
    }
  end

  # Not very clear or optimised needs improvement
  def fetch(params)
    params.map do |namespace, content|
      # if content.kind_of? Hash
      #   content.map do |subspace, id|
      #     @parsed[namespace][subspace].openById(id)
      #   end.first
      # else
      @parsed[namespace][content].open
      # end
    end.first
  end
end

class ParsedFile
  attr_reader :path, :name

  def initialize(name, path, attrs)
    @name = name
    @path = path
    @default = attrs.default
  end

  def open
    if File.exist?(path)
      JSON.parse(File.open(path).read, symbolize_names: true)
    else
      @default
    end
  end
end