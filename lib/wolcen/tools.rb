class Wolcen::Tools
  attr_reader :i18n, :raws, :parsed

  def initialize
    @i18n = Wolcen::I18n.new
    @raws = Wolcen::RawsManager.new
    @parsed = Wolcen::ParsedManager.new
  end  

  def write_as_json(name, data)
    File.open("#{parsed.base_path}/#{name}.json", "w") do |f|
      f.write(data.to_json)
    end
  end
end