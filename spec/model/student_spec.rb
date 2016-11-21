require 'rails_helper'
describe Student do
  describe 'searching similar directors' do
    it 'same_directors can be called' do
      Student.should_receive(:to_j1_csv).with('1995')
      Student.to_j1_csv('1995')
    end
  end
end