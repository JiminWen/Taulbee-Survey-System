require 'rails_helper'
describe Student do
    describe 'to_j1_csv' do 
        it'should call Model method' do
            expect(Student).to receive(:to_j1_csv).with("2014")
            Student.to_j1_csv("2014")
        end
    end

    describe 'to_f3_csv' do 
        it'should call Model method' do
            expect(Student).to receive(:to_j1_csv).with("2014")
            Student.to_j1_csv("2014")
        end
    end
end