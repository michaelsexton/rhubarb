class User < ActiveRecord::Base
  establish_connection :local

  attr_reader :ldap_user_entry
  acts_as_authentic do |c|
    c.validate_password_field = false
    c.validate_email_field = false
  end

  default_scope :order => 'login_count DESC'


  def owns?(object)
    object.user == self
  end

  def admin?
    self.role == "admin"
  end

  def ozmin?
    self.role == "ozmin"  or self.role == "admin"
  end

  # return true or false depending on the success of the authentication
  def authenticate_against_ga_ldap(plain_text_password)
    ldap = LDAP_CONNECTION
    ldap.auth "#{self.username}@#{LDAP_CONFIG["full_base_dn"]}", "#{plain_text_password}"
    if ldap.bind
      return true
    else
      self.errors.add :base, "Result: #{ldap.get_operation_result.code}"
      self.errors.add :base, "Message: #{ldap.get_operation_result.message}"
      return false
    end
  end

  def ldap_user_exists?
  end

  # populate the ldap_user_entry instance variable
  def ldap_user_entry
    filter = Net::LDAP::Filter.eq("sAMAccountName", self.username)
    count = 0
    unless @ldap_user_entry
      return nil if count >= 2
      count = count+1
      @ldap_user_entry ||= LDAP_CONNECTION.search(:filter => filter, :size => 1)[0] rescue false
    end
    @ldap_user_entry
  end

  def self.find_ldap_username_by_email(email)
    filter = Net::LDAP::Filter.eq("mail", email)
    LDAP_CONNECTION.search(:filter => filter, :size=>1)[0].samaccountname[0] rescue nil
  end

  def email
    ldap_user_entry.mail.first rescue nil
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def first_name
    ldap_user_entry.givenname.first rescue nil
  end

  def last_name
    ldap_user_entry.sn.first rescue nil
  end

  def department
    ldap_user_entry.department.first rescue nil
  end

  def office_phone
    ldap_user_entry.telephonenumber.first rescue nil
  end

  def to_param
    if full_name
      "#{id}-#{full_name.to_s.parameterize.downcase}"
    else
      id.to_s
    end
  end
end
