class ResourceGrade < ActiveRecord::Base
	self.table_name = "mgd.resource_grades"
	self.primary_key = :rescommno
  set_date_columns :entrydate, :qadate, :confid_until, :lastupdate

  belongs_to :resource, :class_name => "Resource", :foreign_key => :resourceno

	#named_scope :recent, :conditions => "recorddate in (select MAX(recorddate) from mgd.resources r where r.eno = mgd.resources.eno"

  scope :public, :conditions=> "mgd.resource_grades.access_code = 'O'"

  default_scope :order =>'mgd.resource_grades.access_code desc, commodid asc'

	scope :mineral, lambda { |min| { :conditions=> ["mgd.resource_grades.commodid in (?)", min] } }
end
