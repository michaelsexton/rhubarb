class Zone < Entity
	belongs_to :deposit, :class_name => "Deposit", :foreign_key => :parent
	has_many :resources, :class_name => "Resource",  :foreign_key => :eno

  has_many :resource_grades, :through => :resources

  has_one :deposit_status, :class_name => "DepositStatus", :primary_key=>:parent, :foreign_key => :eno
  has_one :status, :class_name => "DepositStatus", :primary_key=>:eno, :foreign_key => :eno
  
  scope :state, lambda { |s| { :include=>:deposit_status, :conditions=> ["mgd.deposits.state = ?", s] } }


  def self.sti_name
    "MINERALISED ZONE"
  end
  
  def self.public 
    where(access_code:"O")
  end
end
