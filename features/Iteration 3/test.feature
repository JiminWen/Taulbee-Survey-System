Feature: Automatically generate a survey for PhD Enrollment
As: User
So that I can: select PhD Enrollment for Computer Science or Computer Engineering based on specific filter and attributes


@javascript
@rack_test
Scenario: I should see an error message when I upload a wrong format
  Given I am on the home page
  And I select "2014" from "queryList"
  When I press "Select"
  Then I should see "Get a standard output"
  Then I press "generate"
  Then I should see "Results to Download"
  When I follow "Computer Science only.csv" number "1"
  Then A download should commence
