Feature: Upload a non_csv file and return home
  
  As a User
  So that I can upload a non-csv file and get an error message. 

@javascript
Scenario: I should be able to upload a non.cvs file and get an error message
  Given I am on the home page
  And I select "features/wrong_input_file.non_csv_type" to be uploaded to "spreadsheet_attachment"
  When I press "Save"
  Then I should be on the spreadsheet page
  Then I should see "Wrong file"
  When I wait "2" seconds to press "returnButton"
  Then I should be on the home page