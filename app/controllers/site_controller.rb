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
      values.merge!(flash[:filters])
      values.merge!(flash[:comparators])
      values.merge!(flash[:filterValues])
      values.merge!(flash[:headers])
      @query = unsavedQuery(values)
      @filterCount = flash[:filters].count
      @headerCount = flash[:headers].count
    end
    
    #grab the existing filter values
    @filterValues = []
    if @query
      @query.filters.each do |filter|
        @filterValues << filter.value
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
    filters = params.select { |key, value| key.to_s.match(/filter\d+/) }
    comparators = params.select { |key, value| key.to_s.match(/comparator\d+/) }
    filterValues = params.select { |key, value| key.to_s.match(/filterValue\d+/) }
    attributes = params.select { |key, value| key.to_s.match(/attribute\d+/) }
    
    @query = Query.new({:name => "No Save"})
    
    i = 0
    filters.each do |filter|
      filterRecord = Filter.create(:field => filters["filter" + i.to_s], :comparator => comparators["comparator" + i.to_s], :value => filterValues["filterValue" + i.to_s])
      puts filterRecord.inspect
      @query.filters << filterRecord
      i = i + 1
    end
    
    i = 0
    attributes.each do |attribute|
      headerRecord = Header.create(:field => attributes["attribute" + i.to_s])
      @query.headers << headerRecord
      i = i + 1
    end
    
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
      @students=@students.where("prim_deg='PHD'").where("year=#{year}")
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
        temp<< @students.where(c).where(r).count.to_s
        end
        array<<temp
      end
      temp=["k. Total"]
      c_filter.each do |c|
      temp<< @students.where(c).count.to_s
      end
      array<<temp
      
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
        temp<< @students.where(c).where(r).count.to_s
        end
        array<<temp
      end
      temp=["k. Total"]
      c_filter.each do |c|
      temp<< @students.where(c).count.to_s
      end
      array<<temp
      respond_to do |format|
       format.csv { send_data Student.altercsv(array) }
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
      @students=@students.where("prim_deg='MS' OR prim_deg='MCS' OR prim_deg='MEN'").where("year=#{year}")
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
        temp<< @students.where(c).where(r).count.to_s
        end
        array<<temp
      end
      temp=["k. Total"]
      c_filter.each do |c|
      temp<< @students.where(c).count.to_s
      end
      array<<temp
      
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
        temp<< @students.where(c).where(r).count.to_s
        end
        array<<temp
      end
      temp=["k. Total"]
      c_filter.each do |c|
      temp<< @students.where(c).count.to_s
      end
      array<<temp
      
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
        temp<< @students.where(c).where(r).count.to_s
        end
        array<<temp
      end
      temp=["k. Total"]
      c_filter.each do |c|
      temp<< @students.where(c).count.to_s
      end
      array<<temp
      
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
        temp<< @students.where(c).where(r).count.to_s
        end
        array<<temp
      end
      temp=["k. Total"]
      c_filter.each do |c|
      temp<< @students.where(c).count.to_s
      end
      array<<temp
      
      respond_to do |format|
         format.csv { send_data Student.altercsv(array) }
      end
  end
  
  
  #page that shows the results
  def studentOutput
  #skip_before_filter :verify_authenticity_token 
    
  if params["commit"] == "generate"
      @year=params[:cur_year]
      #raise params.inspect  
     # form2_4(year)
      
      
  else  
    if params["commit"] == "Save"
      saveQuery(params)
    else
      #if the query is not being saved
      #select all the filters and filter values chosen
      filters = params.select { |key, value| key.to_s.match(/filter\d+/) }
      comparators = params.select { |key, value| key.to_s.match(/comparator\d+/) }
      filterValues = params.select { |key, value| key.to_s.match(/filterValue\d+/) }
      @attributes = params.select { |key, value| key.to_s.match(/attribute\d+/) }
      
      #store all these values if the user chooses to repeat the query
      flash[:existingQuery] = 1
      flash[:filters] = filters
      flash[:comparators] = comparators
      flash[:filterValues] = filterValues
      flash[:headers] = @attributes
      
      #determine if the user wants the count
      @count = @attributes.any? { |hash| hash[1].include?("count") }
      #raise filters.inspect
  
      #if no filters selected, display all data for that year
      if filters.length == 0
        if session["yearSelected"] != nil
          queryString = "year = \'" + session["yearSelected"] + "\'"
        end
      else
        #create query string from selected values
        
        queryString = ""
        i = 0
        filters.each do |filter|
          filterValue = filterValues["filterValue" + i.to_s]
          if filterValue != nil
            if i > 0
              queryString = queryString + " AND "
            end
            queryString = queryString + filters["filter" + i.to_s] + comparators["comparator" + i.to_s] + "\'" + filterValue + "\'"
          end
          i = i + 1
        end
        
        if session["yearSelected"] != nil
          queryString = queryString + " AND year = \'" + session["yearSelected"] + "\'"
        end
      end
     # raise queryString.inspect
     # raise @attributes.values.inspect
      
      @students = Student.where(queryString)
      respond_to do |format|
        format.html
        format.csv { send_data Student.to_csv(@students, @attributes.values) }
      end
    end
  end  
  end
  
  #unused
  private
    def populate_db(csvFile)
      csv_data = CSV.read csvFile
      headers = csv_data.shift
      tableNameStartIndex = csvFile.rindex('/') + 1
      tableName = csvFile[tableNameStartIndex..csvFile.length-5]
      tableName = tableName.underscore.camelize
      tableName = "Data" + tableName
      table = tableName.constantize
      string_data = csv_data.map do |row| 
          row.map do |cell|
              cell.to_s
          end
      end
      array_of_hashes = []
      string_data.map do |row| 
          array_of_hashes << Hash[*headers.zip(row).flatten]
      end
      puts array_of_hashes
      array_of_hashes.each do |value|
          table.create!(value)
      end
    end
    
end
