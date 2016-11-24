Feature: Automatically generate a survey for Masters Enrollment
As: User
So that I can: select Masters Enrollment for Computer Science or Computer Engineering based on specific filter and attributes


@javascript
@rack_test
Scenario: I should be able to download .cvs files that are generated based on my uplodaded student record document
  Given I am on the home page
  And I select "2015" from "queryList"
  When I press "Select"
  Then I should see "Get a standard output"
  Then I press "generate"
  Then I should see "Results to Download"
  When I follow "Number of Masters Students newly admitted.csv" number "1"
  Then A download should commence
