class ResourcesController < ApplicationController
  before_filter :pull_params

  before_filter :define_scope, :only => [:index,:admin]
  #before_filter :require_ozmin_user
  # GET /zones
  # GET /zones.xml
  def index

    unless params[:format]
      @scope = @scope.paginate :page => params[:page] , :order => 'recorddate DESC' if !params[:format]
    else
      @scope = @scope.all
    end

    @resources = @scope
    respond_to do |format|

      format.html # index.html.erb
      format.xml  { render :xml => @resources }
    end
  end

  def show
    resource = Resource
    unless (current_user && current_user.ozmin?)
    resource = resource.public
    end
    @resource = resource.find(params[:id])
  end

  def aimr
    if params[:year].blank?
      params[:year] = Date.today.year - 1
    end
    respond_to do |format|
      format.html # aimr.html.erb
    end
  end

  def state
    if params[:year].blank?
      params[:year] = Date.today.year - 1
    end
    if params[:commodity].blank?
      params[:commodity] = 'Au'
    end
    respond_to do |format|
      format.html # state.html.haml
    end
  end

  def year
    if params[:state].blank?
      params[:state] = 'Australia'
    end
    if params[:commodity].blank?
      params[:commodity] = 'Au'
    end
    respond_to do |format|
      format.html # year.html.haml
    end
  end

  def admin
    @scope = @scope.where(:qa_status_code=>'U').order(:entrydate)
    @resources = @scope.paginate :page => params[:page] , :order => 'recorddate DESC'
    respond_to do |format|
      format.html # qa.html.haml
    end
  end

  def qa
    commit =params[:commit].downcase.to_sym
    case commit
      when :search
        redirect_to :action => :admin, :qaby=>params[:qaby], :entry_date=>@entry_date, :qadate=>params[:qadate], :entered_by=>params[:entered_by], :range => params[:range]
      when :update
    
        unless params[:resource_ids].blank?
          resource_ids = params[:resource_ids]
          resource_ids.each do |id|
          resource=Resource.find(id)
          zone = resource.zone
          deposit = zone.deposit
          resource.qa_status_code="C"
          resource.qaby = params[:qaby]
          resource.qadate = params[:qadate].to_date
          resource.save
          unless zone.qaed?
            zone.qa_record(params[:qadate].to_datetime,params[:qaby])
          end
          unless deposit.qaed?
            deposit.qa_record(params[:qadate].to_datetime,params[:qaby])
          end
        end
    end
    unless resource_ids.blank?
      flash[:notice] = "#{resource_ids.length} Resources have passed QA"
    end
    redirect_to :action => :admin, :qaby=>params[:qaby], :entry_date=>@entry_date, :entered_by=>params[:entered_by], :qadate=>params[:qadate], :range=>params[:range]
  end
end
  # GET /zones/1
  # GET /zones/1.xml
  def identified
    if CommodityType.aliases.keys.include?(params[:commodity])
      commodity = CommodityType.aliases[params[:commodity]]
    else
      commodity = CommodityType.where(:convertedcommod=>params[:commodity]).pluck(:commodid)
    end

    if params[:year]
      year = params[:year].to_i
    else
      year=Date.today.year.to_i
    end

    scope = Resource.mineral(commodity).year(year).nonzero

    if params[:recoverability] == 'recoverable'
    scope=scope.recoverable
    elsif params[:recoverability] == 'insitu'
    scope=scope.insitu
    end

    if !params[:state].blank? || !params[:status].blank?
      scope = scope.includes(:deposit_status)
      scope=scope.merge(DepositStatus.state(@state)) unless @state.blank?
      scope=scope.merge(DepositStatus.status(@status)) unless @status.blank?
    end

    resources = scope.all

    @identified_resources = IdentifiedResourceSet.new(resources)

    respond_to do |format|
      format.json #{ render :json => @grades.to_json }# grade.html.erb
    end
  end

  private

  def define_scope

    scope = Resource
    unless (current_user && current_user.ozmin?)
    scope = scope.public
    end

    unless @qa_status.blank?
      scope = scope.where(:qa_status_code => @qa_status)
    end
    unless @entered_by.blank?
    scope = scope.entered_by(@entered_by)
    end
    unless @entry_date.blank?
    entry_range = (@entry_date-1.send(params[:range]))..(@entry_date+1.send(params[:range]))
    scope = scope.entry_date_range(entry_range)
    end
    @scope = scope
  end

  def pull_params
    #TODO LIMIT TO ONE FOR RESOURCES
    @name =  params[:name]
    @state = params[:state]
    @commodity = params[:commodity].split(",") unless params[:commodity].blank?
    @status = params[:status]
    @province = params[:province]
    @company = params[:company]
    @year = params[:year].to_i
    @qa_status = params[:qa_status]
    @entered_by = params[:entered_by]
    @entry_date = params[:entry_date].to_date rescue Date.today
  end
end
