Feature: Automatically generate a survey for Bachelors Enrollment

  
  As: User
  So that I can: select Bachelors Enrollment for Computer Engineering based on specific filter and attributes


@javascript
@rack_test
Scenario: I should be able to download .cvs files that are generated based on my uplodaded student record document
  Given I am on the home page
  And I select "2015" from "queryList"
  When I press "Select"
  Then I should see "Get a standard output"
  Then I press "generate"
  Then I should see "Results to Download"
  When I follow "Computer Engineering only.csv" number "3"
  Then A download should commence
