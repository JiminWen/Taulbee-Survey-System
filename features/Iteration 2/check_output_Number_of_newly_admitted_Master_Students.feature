Feature: Upload a non-csv file and return home
  
  As a User
  So that I can download csv files from the server once I uplodaded student record document

@javascript
@rack_test
Scenario: I should be able to download .cvs files that are generated based on my uplodaded student record document
  Given I am on the home page
  And I select "1995" from "queryList"
  When I press "Select"
  Then I should see "Get a standard output"
  Then I press "generate"
  Then I should see "Results to Download"
  When I follow "Number of Masters Students newly admitted.csv" number "1"
  Then A download should commence
