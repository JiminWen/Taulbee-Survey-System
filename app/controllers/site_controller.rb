class SiteController < ApplicationController
  require 'csv'
  
  #receives the ajax call to dynamically populate filter value drop downs
  def receiveAjax
    #grabs all uniq values for the given column
    dataToSend = Student.select(params[:c_name].to_sym).map(&params[:c_name].to_sym).uniq.inspect
    
    data = {:value => dataToSend}
    
    respond_to do |format|
      format.json { render :json => data }
    end
  end
  
  
  def index
    @spreadsheet = Spreadsheet.new
    @spreadsheets = Spreadsheet.all
  end
  
  #page that displays the fitler selection
  def studentFilterSelection

    #stores the selected year
    if(params["yearSelected"])
      session["yearSelected"] = params["yearSelected"]
      @year=params["yearSelected"]
    end
    
    #if year wasn't stored, it should be a new selected year, store it
    if (session["yearSelected"] != nil)
      @students = Student.where("year = \'" + session["yearSelected"] + "\'")
    end
    
    @queries = Query.all #gets all the stored queries
    
    #if a query was loaded
    if params["queryLoad"]
      @query = (Query.where("name = " + "\'" + params["queryLoad"] + "\'"))[0]
      @filterCount = @query.filters.count
      @headerCount = @query.headers.count
    elsif params[:repeat]
      #if the user said to repeat the query
      values = {}
      # values.merge!(flash[:prefilters])
      # values.merge!(flash[:pre_comparator])
      # values.merge!(flash[:prefilters_value])
     
      # values.merge!(flash[:collumfilters])
      # values.merge!(flash[:collum_comparator])
      # values.merge!(flash[:collumfilters_value])
      
      # values.merge!(flash[:rowfilters])
      # values.merge!(flash[:row_comparators])
      # values.merge!(flash[:rowfilters_value])
      #@filterCount = flash[:prefilters].count
      
     # values.merge!(flash[:headers])
      @query = unsavedQuery(values)
      
     # @headerCount = flash[:headers].count
    end
    
    #grab the existing filter values
   
    @prefilterValues = []
    if @query
      @query.prefilters.each do |filter|
      #  raise filter.inspect
        @prefilterValues << filter.value
      end
    else
      @query = nil
      @filterCount = 0
      @headerCount = 0
    end
  end
  
  #when the user clicks to save a query, must save all the filter columns, filter values, and attributes selected
  #then send the user back to the filter selection page
  def saveQuery(params)
   # raise params.inspect
    filters = params.select { |key, value| key.to_s.match(/filter\d+/) }
    comparators = params.select { |key, value| key.to_s.match(/comparator\d+/) }
    filterValues = params.select { |key, value| key.to_s.match(/filterValue\d+/) }
    attributes = params.select { |key, value| key.to_s.match(/attribute\d+/) }
    
    @query = Query.create({:name => params["saveName"]})
    
    i = 0
    filters.each do |filter|
      filterRecord = Filter.create(:field => filters["filter" + i.to_s], :comparator => comparators["comparator" + i.to_s], :value => filterValues["filterValue" + i.to_s])
      @query.filters << filterRecord
      i = i + 1
    end
    
    i = 0
    attributes.each do |attribute|
      headerRecord = Header.create(:field => attributes["attribute" + i.to_s])
      @query.headers << headerRecord
      i = i + 1
    end
    
    @query.save
    flash[:query] = @query
    redirect_to site_studentFilterSelection_path
  end
  
  #make a query object, but don't actually save it to the database
  #used for the repeat query functionality
  def unsavedQuery(params)
    
    # filters = params.select { |key, value| key.to_s.match(/filter\d+/) }
    # comparators = params.select { |key, value| key.to_s.match(/comparator\d+/) }
    # filterValues = params.select { |key, value| key.to_s.match(/filterValue\d+/) }
    #attributes = params.select { |key, value| key.to_s.match(/attribute\d+/) }
    prefilters = params.select { |key, value| key.to_s.match(/^filter\d+/) }
    prefilters_value= params.select { |key, value| key.to_s.match(/^filterValue\d+/) }
    pre_comparator=params.select{|key,value| key.to_s.match(/^comparator\d+/)}
    collumfilters = params.select {|key, value| key.to_s.match(/^collumfilter\d+/)}
    collumfilters_value= params.select {|key, value| key.to_s.match(/^collumfilterValue\d+/)}
    collum_comparator= params.select {|key,value| key.to_s.match(/^collumcomparator\d+/)}
    rowfilters = params.select {|key, value| key.to_s.match(/^rowfilter\d+/)}
    rowfilters_value = params.select {|key, value| key.to_s.match(/^rowfilterValue\d+/)}
    row_comparators = params.select { |key, value| key.to_s.match(/rowcomparator\d+/) }
   
    @query = Query.new({:name => "No Save"})
    #raise prefilters.inspect
    i = 0
    prefilters.each do |filter|
      filterRecord = Prefilter.create(:field => prefilters["filter" + i.to_s], :comparator => pre_comparator["comparator" + i.to_s], :value => prefilters_value["filterValue" + i.to_s])
      #raise filterRecord.inspect
      @query.prefilters << filterRecord
      i = i + 1
    end
    
    # i = 0
    # attributes.each do |attribute|
    #   headerRecord = Header.create(:field => attributes["attribute" + i.to_s])
    #   @query.headers << headerRecord
    #   i = i + 1
    # end
    #raise @query.prefilters.inspect
    return @query
  end
  
   def formF_4
      year=params[:year]
      next_year=year.to_i+1 
      next_year=next_year.to_s
      h1="Summer #{year} - College Station"
      h2="Fall #{year} - College Station"
      h3="Spring #{next_year} - College Station"
      @students=Student.all
      @students=@students.where("prim_deg='PHD'").where("year=?",year)
      c_attribute=[" ","CS","CE"]
      r_attribute=["Number of newly-admitted PHD students from outside the North America?"]
      c_filter=["prim_deg_maj_1 = 'CPSL' OR prim_deg_maj_1 = 'CPSC'","prim_deg_maj_1 = 'CECN' OR prim_deg_maj_1 = 'CECL'"]
      r_filter="country_of_origin!= ' ' AND country_of_origin!= 'United States'"
      array=[]
      array<<c_attribute
      temp=[]
      temp<<r_attribute[0]
      temp<<@students.where(c_filter[0]).where("prim_deg_cat=? OR prim_deg_cat=? OR prim_deg_cat=?",h1,h2,h3).where(r_filter).count.to_s
      temp<<@students.where(c_filter[1]).where("prim_deg_cat=? OR prim_deg_cat=? OR prim_deg_cat=?",h1,h2,h3).where(r_filter).count.to_s
      array<<temp
      #raise array.inspect
      
      respond_to do |format|
        format.csv { send_data Student.altercsv(array) }
      end
  end
  
  def formI_1
      year=params[:year]
      @students=Student.all
      #raise @students.inspect
      @students=@students.where("prim_deg_maj_1='CPSL' OR prim_deg_maj_1='CPSC'").where("prim_deg='MS' OR prim_deg='MCS' OR prim_deg='MEN'").where("year=?",year)
      c_attribute=[" ","Male","Female","Not Avaliable","Total"]
      r_attribute=["Residents (a.-h.)","a. American Indian or Alaska Native, not Hispanic", "b. Asain, not Hispanic","c. Black or African-American, not Hispanic","d. Native Hawallian or Other Pacific Islander, not Hispanic","e. White, not Hispanic"]
      r_attribute=r_attribute+["f. More than one race, not Hispanic","g. Hispanic or Latino, any race", "h. Race/Ethnicity Unknown","i. Nonresident Alien","j. Not available","k. Total"]
      c_filter=["sex='M'","sex='F'","sex=' '","sex='M' OR sex='F' OR sex=' '"]
      r_filter=["residency='R' AND ethnicity='I'","residency='R' AND ethnicity='T'","residency='R' AND ethnicity='B'","residency='R' AND ethnicity='N'"] 
      r_filter=r_filter+["residency='R' AND ethnicity='W'","residency='R' AND ethnicity='M'","residency='R' AND ethnicity='H'","residency='R' AND ethnicity='O'"]
      r_filter=r_filter+["residency!='R' AND residency!='U'","residency='U'"]
      array=[]
      array<<c_attribute
      temp=[r_attribute[0]," "," "," "," "]
      array<<temp
      i=1
      r_filter.each do |r|
        temp=[]
        temp<<r_attribute[i]
        i=i+1
        c_filter.each do |c|
        temp<< @students.where(c).where(r).count
        end
        array<<temp
      end
      temp=["k. Total"]
      c_filter.each do |c|
      temp<< @students.where(c).count
      end
      array<<temp
      array<<[]
      array<<c_attribute
      array<<array[1]
      #raise array[12][1].inspect
      for i in 2..12
      temp=[]
      temp<<array[i][0]
        for j in 1..4
          #val=(100*temp[i][j].to_i/temp[12][j].to_i).to_f
          val1=array[i][j]
          val2=array[12][j]
          val ='0'
          if val2!=0
            val=(100*val1.to_f/val2.to_f).to_s+"%"
          end
          temp<<val
        end
      array<<temp  
      end
     # raise array.inspect
      
      respond_to do |format|
         format.csv { send_data Student.altercsv(array) }
      end
  end
  
  def formI_2
      year=params[:year]
      @students=Student.all
      #raise @students.inspect
      @students=@students.where("prim_deg_maj_1='CECN' OR prim_deg_maj_1='CECL'").where("prim_deg='MS' OR prim_deg='MCS' OR prim_deg='MEN'").where("year=?",year)
      c_attribute=[" ","Male","Female","Not Avaliable","Total"]
      r_attribute=["Residents (a.-h.)","a. American Indian or Alaska Native, not Hispanic", "b. Asain, not Hispanic","c. Black or African-American, not Hispanic","d. Native Hawallian or Other Pacific Islander, not Hispanic","e. White, not Hispanic"]
      r_attribute=r_attribute+["f. More than one race, not Hispanic","g. Hispanic or Latino, any race", "h. Race/Ethnicity Unknown","i. Nonresident Alien","j. Not available","k. Total"]
      c_filter=["sex='M'","sex='F'","sex=' '","sex='M' OR sex='F' OR sex=' '"]
      r_filter=["residency='R' AND ethnicity='I'","residency='R' AND ethnicity='T'","residency='R' AND ethnicity='B'","residency='R' AND ethnicity='N'"] 
      r_filter=r_filter+["residency='R' AND ethnicity='W'","residency='R' AND ethnicity='M'","residency='R' AND ethnicity='H'","residency='R' AND ethnicity='O'"]
      r_filter=r_filter+["residency!='R' AND residency!='U'","residency='U'"]
      array=[]
      array<<c_attribute
      temp=[r_attribute[0]," "," "," "," "]
      array<<temp
      i=1
      r_filter.each do |r|
        temp=[]
        temp<<r_attribute[i]
        i=i+1
        c_filter.each do |c|
        temp<< @students.where(c).where(r).count
        end
        array<<temp
      end
      temp=["k. Total"]
      c_filter.each do |c|
      temp<< @students.where(c).count
      end
      array<<temp
      array<<[]
      array<<c_attribute
      array<<array[1]
      #raise array[12][1].inspect
      for i in 2..12
      temp=[]
      temp<<array[i][0]
        for j in 1..4
          #val=(100*temp[i][j].to_i/temp[12][j].to_i).to_f
          val1=array[i][j]
          val2=array[12][j]
          val ='0'
          if val2!=0
            val=(100*val1.to_f/val2.to_f).to_s+"%"
          end
          temp<<val
        end
      array<<temp  
      end
     # raise array.inspect
      
      respond_to do |format|
       format.csv { send_data Student.altercsv(array) }
      end
      
  end
  
  def formJ_1
      respond_to do |format|
          format.csv { send_data Student.to_j1_csv(params[ :year ].to_i) }
      end
  end
  
  def formF_3
      respond_to do |format|
          format.csv { send_data Student.to_f3_csv(params[ :year ].to_i) }
      end
  end
  
  def formJ_2
      year=params[:year]
      next_year=year.to_i+1 
      next_year=next_year.to_s
      h1="Summer #{year} - College Station"
      h2="Fall #{year} - College Station"
      h3="Spring #{next_year} - College Station"
      @students=Student.all
      @students=@students.where("prim_deg='MS' OR prim_deg='MCS' OR prim_deg='MEN'").where("year=?",year)
      c_attribute=[" ","CS","CE"]
      r_attribute=["Number of newly-admitted master students from outside the North America?"]
      c_filter=["prim_deg_maj_1 = 'CPSL' OR prim_deg_maj_1 = 'CPSC'","prim_deg_maj_1 = 'CECN' OR prim_deg_maj_1 = 'CECL'"]
      r_filter="country_of_origin!= ' ' AND country_of_origin!= 'United States'"
      array=[]
      array<<c_attribute
      temp=[]
      temp<<r_attribute[0]
      temp<<@students.where(c_filter[0]).where("prim_deg_cat=? OR prim_deg_cat=? OR prim_deg_cat=?",h1,h2,h3).where(r_filter).count.to_s
      temp<<@students.where(c_filter[1]).where("prim_deg_cat=? OR prim_deg_cat=? OR prim_deg_cat=?",h1,h2,h3).where(r_filter).count.to_s
      array<<temp
      respond_to do |format|
        format.csv { send_data Student.altercsv(array) }
      end
  end
  
 
  def formM_1
      year=params[:year]
      @students=Student.all
      #raise @students.inspect
      @students=@students.where("prim_deg_maj_1='CPSC' OR prim_deg_maj_1='CPSL'").where("prim_deg='BS'").where("year=?",year)
      c_attribute=[" ","Male","Female","Not Avaliable","Total"]
      r_attribute=["Residents (a.-h.)","a. American Indian or Alaska Native, not Hispanic", "b. Asain, not Hispanic","c. Black or African-American, not Hispanic","d. Native Hawallian or Other Pacific Islander, not Hispanic","e. White, not Hispanic"]
      r_attribute=r_attribute+["f. More than one race, not Hispanic","g. Hispanic or Latino, any race", "h. Race/Ethnicity Unknown","i. Nonresident Alien","j. Not available","k. Total"]
      c_filter=["sex='M'","sex='F'","sex=' '","sex='M' OR sex='F' OR sex=' '"]
      r_filter=["residency='R' AND ethnicity='I'","residency='R' AND ethnicity='T'","residency='R' AND ethnicity='B'","residency='R' AND ethnicity='N'"] 
      r_filter=r_filter+["residency='R' AND ethnicity='W'","residency='R' AND ethnicity='M'","residency='R' AND ethnicity='H'","residency='R' AND ethnicity='O'"]
      r_filter=r_filter+["residency!='R' AND residency!='U'","residency='U'"]
      array=[]
      array<<c_attribute
      temp=[r_attribute[0]," "," "," "," "]
      array<<temp
      i=1
      r_filter.each do |r|
        temp=[]
        temp<<r_attribute[i]
        i=i+1
        c_filter.each do |c|
        temp<< @students.where(c).where(r).count
        end
        array<<temp
      end
      temp=["k. Total"]
      c_filter.each do |c|
      temp<< @students.where(c).count
      end
      array<<temp
      array<<[]
      array<<c_attribute
      array<<array[1]
      #raise array[12][1].inspect
      for i in 2..12
      temp=[]
      temp<<array[i][0]
        for j in 1..4
          #val=(100*temp[i][j].to_i/temp[12][j].to_i).to_f
          val1=array[i][j]
          val2=array[12][j]
          val ='0'
          if val2!=0
            val=(100*val1.to_f/val2.to_f).to_s+"%"
          end
          temp<<val
        end
      array<<temp  
      end
      
      respond_to do |format|
       format.csv { send_data Student.altercsv(array) }
      end
      
  end
  
   def formM_2
      year=params[:year]
      @students=Student.all
      #raise @students.inspect
      @students=@students.where("prim_deg_maj_1='CECL' OR prim_deg_maj_1='CECN'").where("prim_deg='BS'").where("year=?",year)
      c_attribute=[" ","Male","Female","Not Avaliable","Total"]
      r_attribute=["Residents (a.-h.)","a. American Indian or Alaska Native, not Hispanic", "b. Asain, not Hispanic","c. Black or African-American, not Hispanic","d. Native Hawallian or Other Pacific Islander, not Hispanic","e. White, not Hispanic"]
      r_attribute=r_attribute+["f. More than one race, not Hispanic","g. Hispanic or Latino, any race", "h. Race/Ethnicity Unknown","i. Nonresident Alien","j. Not available","k. Total"]
      c_filter=["sex='M'","sex='F'","sex=' '","sex='M' OR sex='F' OR sex=' '"]
      r_filter=["residency='R' AND ethnicity='I'","residency='R' AND ethnicity='T'","residency='R' AND ethnicity='B'","residency='R' AND ethnicity='N'"] 
      r_filter=r_filter+["residency='R' AND ethnicity='W'","residency='R' AND ethnicity='M'","residency='R' AND ethnicity='H'","residency='R' AND ethnicity='O'"]
      r_filter=r_filter+["residency!='R' AND residency!='U'","residency='U'"]
      array=[]
      array<<c_attribute
      temp=[r_attribute[0]," "," "," "," "]
      array<<temp
      i=1
      r_filter.each do |r|
        temp=[]
        temp<<r_attribute[i]
        i=i+1
        c_filter.each do |c|
        temp<< @students.where(c).where(r).count
        end
        array<<temp
      end
      temp=["k. Total"]
      c_filter.each do |c|
      temp<< @students.where(c).count
      end
      array<<temp
      array<<[]
      array<<c_attribute
      array<<array[1]
      #raise array[12][1].inspect
      for i in 2..12
      temp=[]
      temp<<array[i][0]
        for j in 1..4
          #val=(100*temp[i][j].to_i/temp[12][j].to_i).to_f
          val1=array[i][j]
          val2=array[12][j]
          val ='0'
          if val2!=0
            val=(100*val1.to_f/val2.to_f).to_s+"%"
          end
          temp<<val
        end
      array<<temp  
      end
      
      respond_to do |format|
       format.csv { send_data Student.altercsv(array) }
      end
      
  end
  
def formE_1
      year=params[:year]
      @students=Student.all
      #raise @students.inspect
      @students=@students.where("prim_deg_maj_1='CPSC' OR prim_deg_maj_1='CPSL'").where("prim_deg='PHD'").where("year=?",year)
      c_attribute=[" ","Male","Female","Not Avaliable","Total"]
      r_attribute=["Residents (a.-h.)","a. American Indian or Alaska Native, not Hispanic", "b. Asain, not Hispanic","c. Black or African-American, not Hispanic","d. Native Hawallian or Other Pacific Islander, not Hispanic","e. White, not Hispanic"]
      r_attribute=r_attribute+["f. More than one race, not Hispanic","g. Hispanic or Latino, any race", "h. Race/Ethnicity Unknown","i. Nonresident Alien","j. Not available","k. Total"]
      c_filter=["sex='M'","sex='F'","sex=' '","sex='M' OR sex='F' OR sex=' '"]
      r_filter=["residency='R' AND ethnicity='I'","residency='R' AND ethnicity='T'","residency='R' AND ethnicity='B'","residency='R' AND ethnicity='N'"] 
      r_filter=r_filter+["residency='R' AND ethnicity='W'","residency='R' AND ethnicity='M'","residency='R' AND ethnicity='H'","residency='R' AND ethnicity='O'"]
      r_filter=r_filter+["residency!='R' AND residency!='U'","residency='U'"]
      array=[]
      array<<c_attribute
      temp=[r_attribute[0]," "," "," "," "]
      array<<temp
      i=1
      r_filter.each do |r|
        temp=[]
        temp<<r_attribute[i]
        i=i+1
        c_filter.each do |c|
        temp<< @students.where(c).where(r).count
        end
        array<<temp
      end
      temp=["k. Total"]
      c_filter.each do |c|
      temp<< @students.where(c).count
      end
      array<<temp
      array<<[]
      array<<c_attribute
      array<<array[1]
      #raise array[12][1].inspect
      for i in 2..12
      temp=[]
      temp<<array[i][0]
        for j in 1..4
          #val=(100*temp[i][j].to_i/temp[12][j].to_i).to_f
          val1=array[i][j]
          val2=array[12][j]
          val ='0'
          if val2!=0
            val=(100*val1.to_f/val2.to_f).to_s+"%"
          end
          temp<<val
        end
      array<<temp  
      end
     # raise array.inspect
      
      
      respond_to do |format|
         format.csv { send_data Student.altercsv(array) }
      end
  end
  
  def formE_2
      year=params[:year]
      @students=Student.all
      #raise @students.inspect
      @students=@students.where("prim_deg_maj_1='CECL' OR prim_deg_maj_1='CECN'").where("prim_deg='PHD'").where("year=?",year)
      c_attribute=[" ","Male","Female","Not Avaliable","Total"]
      r_attribute=["Residents (a.-h.)","a. American Indian or Alaska Native, not Hispanic", "b. Asain, not Hispanic","c. Black or African-American, not Hispanic","d. Native Hawallian or Other Pacific Islander, not Hispanic","e. White, not Hispanic"]
      r_attribute=r_attribute+["f. More than one race, not Hispanic","g. Hispanic or Latino, any race", "h. Race/Ethnicity Unknown","i. Nonresident Alien","j. Not available","k. Total"]
      c_filter=["sex='M'","sex='F'","sex=' '","sex='M' OR sex='F' OR sex=' '"]
      r_filter=["residency='R' AND ethnicity='I'","residency='R' AND ethnicity='T'","residency='R' AND ethnicity='B'","residency='R' AND ethnicity='N'"] 
      r_filter=r_filter+["residency='R' AND ethnicity='W'","residency='R' AND ethnicity='M'","residency='R' AND ethnicity='H'","residency='R' AND ethnicity='O'"]
      r_filter=r_filter+["residency!='R' AND residency!='U'","residency='U'"]
      array=[]
      array<<c_attribute
      temp=[r_attribute[0]," "," "," "," "]
      array<<temp
      i=1
      r_filter.each do |r|
        temp=[]
        temp<<r_attribute[i]
        i=i+1
        c_filter.each do |c|
        temp<< @students.where(c).where(r).count
        end
        array<<temp
      end
      temp=["k. Total"]
      c_filter.each do |c|
      temp<< @students.where(c).count
      end
      array<<temp
      array<<[]
      array<<c_attribute
      array<<array[1]
      #raise array[12][1].inspect
      for i in 2..12
      temp=[]
      temp<<array[i][0]
        for j in 1..4
          #val=(100*temp[i][j].to_i/temp[12][j].to_i).to_f
          val1=array[i][j]
          val2=array[12][j]
          val ='0'
          if val2!=0
            val=(100*val1.to_f/val2.to_f).to_s+"%"
          end
          temp<<val
        end
      array<<temp  
      end
      respond_to do |format|
         format.csv { send_data Student.altercsv(array) }
      end
  end
  
  def studentManual  
  # raise params.inspect
    @params=params
    if params["commit"] == "Save"
      saveQuery(params)
    else
      #if the query is not being saved
      #select all the filters and filter values chosen
     # raise params.inspect
      prefilters = params.select { |key, value| key.to_s.match(/^filter\d+/) }
      prefilters_value= params.select { |key, value| key.to_s.match(/^filterValue\d+/) }
      pre_comparator=params.select{|key,value| key.to_s.match(/^comparator\d+/)}
      collumfilters = params.select {|key, value| key.to_s.match(/^collumfilter\d+/)}
      collumfilters_value= params.select {|key, value| key.to_s.match(/^collumfilterValue\d+/)}
      collum_comparator= params.select {|key,value| key.to_s.match(/^collumcomparator\d+/)}
      rowfilters = params.select {|key, value| key.to_s.match(/^rowfilter\d+/)}
      rowfilters_value = params.select {|key, value| key.to_s.match(/^rowfilterValue\d+/)}
      row_comparators = params.select { |key, value| key.to_s.match(/rowcomparator\d+/) }
      filterValues = params.select { |key, value| key.to_s.match(/filterValue\d+/) } 
      @attributes = params.select { |key, value| key.to_s.match(/attribute\d+/) }
     # raise prefilters["filter0"].inspect
      
      @student=Student.all
     # @student=@student.where("year=?",@year)
       if session["yearSelected"]!=nil
       @year=session["yearSelected"]
       @student=@student.where("year=?",@year)
      end
      for i in 0..(prefilters.length-1) 
      @student=@student.where(prefilters["filter"+i.to_s]+pre_comparator["comparator"+i.to_s]+'?',prefilters_value["filterValue"+i.to_s])
      end
     # raise @student.count.inspect
     
      c_attribute=[]
      r_attribute=[" "]
      for j in 0..(rowfilters.length-1)
         condition=rowfilters["rowfilter"+j.to_s]+row_comparators["rowcomparator"+j.to_s]+rowfilters_value["rowfilterValue"+j.to_s]
         r_attribute<<condition
       end
      
       for i in 0..(collumfilters.length-1)
         condition=collumfilters["collumfilter"+i.to_s]+collum_comparator["collumcomparator"+i.to_s]+collumfilters_value["collumfilterValue"+i.to_s]
         c_attribute<<condition
       end
      array=[]
      array<<r_attribute
      k=0
      for i in 0..(collumfilters.length-1) 
        temp=[]
        temp<<c_attribute[k]
        k=k+1
        for j in 0..(rowfilters.length-1)
        temp<<@student.where(rowfilters["rowfilter"+j.to_s]+row_comparators["rowcomparator"+j.to_s]+'?',rowfilters_value["rowfilterValue"+j.to_s]).where(collumfilters["collumfilter"+i.to_s]+collum_comparator["collumcomparator"+i.to_s]+'?',collumfilters_value["collumfilterValue"+i.to_s]).count      
          
        end
        array<<temp
      end
       #raise array.inspect
       respond_to do |format|
        format.html
        format.csv { send_data Student.altercsv(array) }
      end
      
      
       flash[:existingQuery] = 1
       flash[:prefilters] = prefilters
       flash[:pre_comparator] = pre_comparator
       flash[:prefilters_value] = prefilters_value
       
       flash[:collumfilters] = collumfilters
       flash[:collum_comparator] = collum_comparator
       flash[:collumfilters_value] = collumfilters_value
       
       flash[:rowfilters] = rowfilters
       flash[:row_comparators] = row_comparators
       flash[:rowfilters_value] = rowfilters_value
       
       
      #flash[:headers] = @attributes
      
      #determine if the user wants the count
      #@count = @attributes.any? { |hash| hash[1].include?("count") }
      #raise filters.inspect
  
      #if no filters selected, display all data for that year
      # if filters.length == 0
      #   if session["yearSelected"] != nil
      #     queryString = "year = \'" + session["yearSelected"] + "\'"
      #   end
      # else
        #create query string from selected values
        
        # queryString = ""
        # i = 0
        #       filters.each do |filter|
        #         filterValue = filterValues["filterValue" + i.to_s]
        #         if filterValue != nil
        #           if i > 0
        #             queryString = queryString + " AND "
        #           end
        #           queryString = queryString + filters["filter" + i.to_s] + comparators["comparator" + i.to_s] + "\'" + filterValue + "\'"
        #         end
        #         i = i + 1
        #       end
        
        #     if session["yearSelected"] != nil
        #       queryString = queryString + " AND year = \'" + session["yearSelected"] + "\'"
        #     end
        #end
             # @students = Student.where(queryString)
              # respond_to do |format|
              #   format.html
              #   format.csv { send_data Student.to_csv(@students, @attributes.values) }
              # end
  end    
  end
  
  
  
  #page that shows the results
  def studentOutput
  #skip_before_filter :verify_authenticity_token 
    
  if params["commit"] == "generate"
      @year=params[:cur_year]

  else  
    redirect_to studentManual_path(params)
  end  
   
  
  
  #unused
#   private
#     def populate_db(csvFile)
#       # csv_data = CSV.read csvFile
#       # headers = csv_data.shift
#       # tableNameStartIndex = csvFile.rindex('/') + 1
#       # tableName = csvFile[tableNameStartIndex..csvFile.length-5]
#       # tableName = tableName.underscore.camelize
#       # tableName = "Data" + tableName
#       # table = tableName.constantize
#       # string_data = csv_data.map do |row| 
#       #     row.map do |cell|
#       #         cell.to_s
#       #     end
#       # end
#       # array_of_hashes = []
#       # string_data.map do |row| 
#       #     array_of_hashes << Hash[*headers.zip(row).flatten]
#       # end
#       # puts array_of_hashes
#       # array_of_hashes.each do |value|
#       #     table.create!(value)
#       # end
#     end
    
# end
end
end
