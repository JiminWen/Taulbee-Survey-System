require 'csv'
#require 'mimemagic'
#require_relative  './libmagic-dev'
class SpreadsheetsController < ApplicationController
  @@val = false
  
  #unused
  def index
   # redirect_to site_studentOutput_path
  end

  #unused
  def new
    #redirect_to site_studentOutput_path
  end
  
  #returns whether or not the upload has finished
  #ajax call
  def receiveAjaxSpreadsheet
    #@@val is the value of whether or not the upload has finished
    data = {:value => @@val}
    
    respond_to do |format|
      format.json { render :json => data }
    end
  end


  
  #used to upload a csv file
  def create
    Rails.logger.debug params.inspect
    #raise params.inspect
    @@val = false #set false for file not finished parsing 
    params_to_pass = spreadsheet_params
    params_to_pass["name"] = params["year"]
  #  raise params["spreadsheet"]["attachment"].original_filename.inspect
    @spreadsheet = Spreadsheet.new(params_to_pass)
    f=params["spreadsheet"]["attachment"].original_filename
    
    @message=valid_extension?(f)
    if @message==false
        
    end
    #do the database population in separate thread
    Thread.new do
    
      saved = @spreadsheet.saveAndMove
        
      location = "public/uploads/spreadsheet/attachment/" + params["spreadsheet"]["attachment"].original_filename 
      command = "cat " + location 
      system(command) 
        
      csv_data = CSV.read location 
      headerFields = csv_data[0] 
      headerFields = headerFields.map { |header| 
        CreateHeaderString(header).to_sym 
      } 
      #raise headerFields.inspect  
      iteration = 0 
      csv_data.each do |data| 
       if iteration > 0   
        # raise data.inspect
         createStudent(headerFields, data, params["year"]) 
       end 
       iteration = iteration + 1 
      end
      ActiveRecord::Base.connection.close
      
          
      @@val = true

    end
  
    data = {:value => "Howdy"} #likely was just used for testing

    respond_to do |format|
      format.html
      format.js
    end

  end
  
  def valid_extension?(filename)
    ext = File.extname(filename)
   # raise ext.inspect
    return ext==".csv"
  end
  
  #called to create the entry per student
  def createStudent(headerFields, student, year)
    studentData = Hash[headerFields.zip student]
    #raise studentData.inspect
    studentData[:year] = year
    Student.create(studentData)
   # raise Student.where("id=1S")
  end
  
  #unused
<<-DOC 
  def printData(data)
  
    i = 0
    modelString = "rails g model student"
    data.each do |header|
      
      lowercase = CreateHeaderString(header)
      tableString = "t.string :" + lowercase
      i = i + 1
    end
  end
DOC
 
  
  #translates given headers from file into database friendly headers
  def CreateHeaderString(header)
    if header.gsub(' ', '_')
        header.gsub!(' ', '_')
      end
      if header.gsub('(', '')
        header.gsub!('(', '')
      end
      if header.gsub(')', '')
        header.gsub!(')', '')
      end
      if header.gsub('/', '')
        header.gsub!('/', '')
      end
      if header.gsub('-', '_')
        header.gsub!('-', '_')
      end
      headerString = header.to_s.downcase
      if headerString == "class"
        headerString = "classification"
      end
     # raise headerString.inspect
      return headerString
  end

  #unused
  def destroy
 #   redirect_to site_studentOutput_path
  end
  
  #likely all of this is unused
  private
      def spreadsheet_params
        params.require(:spreadsheet).permit(:name, :attachment)
      end
      
      def create_db_schema(tableName, attrs, datatypes)    #attrs -> array of attributes as strings
        # tableName = tableName.underscore.camelize
        # tableName = "Data" + tableName
        # attributes = ""
        # ind = 0
        # attrs.each do |attr|
        #   attributes << attr
        #   attributes << ":"
        #   attributes << datatypes[ind]
        #   attributes << " "
        #   ind = ind + 1
        # end
        # `rails generate model #{tableName} #{attributes}`
        # `rake db:migrate`
      end
      
  
      # Unknown
      def determine_db_datatypes(csv_data, headers)
        # datatypes = []
        # headers.each do |header|
        #   datatypes << "integer"
        # end
        # csv_data.map do |row| 
        #     ind = 0
        #     row.map do |cell|
        #         if datatypes[ind] == "integer"
        #           if !isInt(cell.to_s)
        #             datatypes[ind] = "string"
        #           end
        #           ind = ind+1
        #         end
        #     end
        # end
        # return datatypes
      end
      
      def parse_csv(csvFile)
        
        # csv_data = CSV.read csvFile
        # headers = csv_data.shift
        # tableNameStartIndex = csvFile.rindex('/') + 1
        # tableName = csvFile[tableNameStartIndex..csvFile.length-5]
        # datatypes = determine_db_datatypes(csv_data, headers)
        # create_db_schema(tableName, headers, datatypes)
    
      end
        
end
