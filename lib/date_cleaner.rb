
resources = Resource.where(enteredby:"U32129",qa_status_code:"U")
resources.each do |resource|
  if resource.recorddate >= resource.entrydate
    comments = resource.remark
    date_regex =  /([0-9]{1,2}-?[a-zA-Z]{3}-?[0-9]{2,4}|7 October 2014)/
    dates = date_regex.match(comments)
    if dates.nil? 
      puts "For resource #{resource.resourceno}, the following comment has no date in it:\n"
      puts comments
    else
      date=dates[0]
      resource.recorddate = date.to_date
      resource.save
    end
  end
end