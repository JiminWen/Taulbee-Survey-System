Feature: Upload a csv file and return home
  
  As a User
  So that I can upload a csv file and see the progress once it is finished. 

@javascript
Scenario: I should be able to upload a .cvs file
  Given I am on the home page
  And I select "features/cucumber_data.csv" to be uploaded to "spreadsheet_attachment"
  When I press "Save"
  Then I should be on the spreadsheet page
  Then I should see "Finished!"
  When I wait "2" seconds to press "returnButton"
  Then I should be on the home page