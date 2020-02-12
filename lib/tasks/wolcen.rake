
namespace :wolcen do
  desc ""
  # EIMs = Entity Internal Modifiers ;)
  task :parse_eims => :environment do
    puts "Parsing eims..."
    tools = Wolcen::Tools.new
    data  = Wolcen::Parser::parse_eim!
    tools.write_as_json('eims', data)
    puts "Done!"
  end

  desc "Parses XML tree data from Wolcen"
  # PST === Passive Skill Tree ;)
  task :parse_trees => :environment do
    puts "Parsing passive skill trees..."
    tools = Wolcen::Tools.new
    data = Wolcen::Parser::parse_pst!
    tools.write_as_json('pst', data)
    puts "Done!"
  end
end

=begin
   <Row ss:AutoFitHeight="0" ss:Height="15">
    <Cell ss:StyleID="s78"><Data ss:Type="String">ui_eim_ailment_stacks_multiplier</Data></Cell>
    <Cell ss:StyleID="s79"><Data ss:Type="String">%1 Chance to multiply the number of Ailment Stacks applied by %2</Data></Cell>
   </Row>
   + 
   <Spell Name="ELEM_24" UIName="@ui_ELEM_24_name" HUDLoreDesc="@ui_ELEM_24_lore" GameplayDesc="@ui_ELEM_24_desc">
    <MagicEffects>
      <EIM Name="ailment_stacks_multiplier" HUDDesc="@ui_eim_ailment_stacks_multiplier" Permanent="1">
        <Semantics ChancePercentInt="50" MultiplierFloat="2" />
      </EIM>
    </MagicEffects>
  </Spell>

=end