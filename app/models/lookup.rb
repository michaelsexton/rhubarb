class Lookup < ActiveRecord::Base
	connection.execute("ALTER SESSION set NLS_DATE_FORMAT ='DD-MON-FXYYYY'")
	set_table_name "mgd.lookups"

	set_primary_key :code

  set_inheritance_column :ruby_type
  
	set_date_columns :entrydate, :qadate, :lastupdate
  
  def self.aimr_code
    return {'EDR'=>"economic",'DMP'=>"paramarginal",'DMS'=>"submarginal",'IFR'=>"inferred"}
  end
  
  def self.states
    return {"Australian Capital Territory"=>"ACT","New South Wales"=>"NSW","Northern Territory"=>"NT","Queensland"=>"QLD","South Australia"=>"SA","Tasmania"=>"TAS","Victoria"=>"VIC","Western Australia"=>"WA","Australia" => nil}
  end
  
end