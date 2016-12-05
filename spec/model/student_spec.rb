require 'rails_helper'
describe Student do
  describe 'create form' do
    it 'create j_1' do
      Student.should_receive(:to_j1_csv).with('1995')
      #CSV.should_receive(:generate)
      Student.to_j1_csv('1995')
    end
    it 'create F_3' do
      Student.should_receive(:to_f3_csv).with('1995')
      Student.to_f3_csv('1995')
    end
    
  end
end