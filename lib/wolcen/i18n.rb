class Wolcen::I18n
  attr_reader :base_path
  
  def initialize
    @base_path = Rails.root.join("lib", "wolcen_raw_data")

    @i18n_pst_path = File.join(base_path, "i18n", "text_ui_passiveskills.xml")
    @i18n_eims_path = File.join(base_path, "i18n", "text_ui_EIM.xml")

     @i18n = {
      pst: Namespace.new(@i18n_pst_path),
      eims: Namespace.new(@i18n_eims_path),
    }
  end

  def fetch(namespace)
    @i18n[namespace]
  end
end

class Namespace
  def initialize(path)
    @path = path
    @xml = Nokogiri::XML(File.open(@path))
    @xml.remove_namespaces!
  end
  
  def where(params)
    if params[:text]
      @xml.xpath("//Row[.//*[contains(text(), '#{params[:text]}')]]")
    else
      @xml
    end
  end

  def t(key)
    has_translation = @xml.xpath("//Row[.//*[contains(text(), '#{key}')]]//Cell[Data]").length >= 2
    if has_translation
      return @xml.xpath("//Row[.//*[contains(text(), '#{key}')]]//Cell[Data][last()]").text()
    else 
      return ""
    end
  end
end