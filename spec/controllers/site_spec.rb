require 'rails_helper'

RSpec.describe SiteController, type: :controller do
	describe "GET #index" do
		it "render index template" do
			get :index
			expect(response).to have_http_status(200)
	    	expect(response).to render_template :index
	  end
	end

	describe "GET #studentFilterSelection" do
		it "render studentFilterSelection template" do
			get :studentFilterSelection
			expect(response).to have_http_status(200)
			expect(response).to render_template :studentFilterSelection
		end
	end

	describe "GET #studentManual" do
		it "render studentManual template" do
			get :studentManual
			expect(response).to have_http_status(200)
			expect(response).to render_template :studentManual
		end
	end
#Additional test cases added in iteration 1	
	describe "test download links" do
	it "should have proper routes" do
    {:get =>'formE_1.csv' }.should be_routable
    {:get =>'formE_2.csv' }.should be_routable
    {:get =>'formM_1.csv' }.should be_routable
    {:get =>'formM_2.csv' }.should be_routable
    {:get =>'formI_1.csv' }.should be_routable
    {:get =>'formI_2.csv' }.should be_routable
    {:get =>'formJ_1.csv' }.should be_routable
    {:get =>'formJ_2.csv' }.should be_routable
    {:get =>'formF_3.csv' }.should be_routable
    {:get =>'formF_4.csv' }.should be_routable
    end
    end
    
    
#     describe "formF_4" do 
#     	before :each do
#     		@student1 = Student.create(:prim_deg =>'PHD', :year => '2014')
#     	end
#     	# it 'should call the all method' do 
#     	# 	expect(Student).to receive(:all).and_return(@student1)
#     	# 	get :formF_4, :year => '2014'
#     	# end
#     	# it 'should call the where filter' do
#     	# 	allow(Student).to receive(:all).and_return(@student)
#     	# 	expect(@student).to receive(:where).with("prim_deg='PHD'").with("year=?",'2014').and_return(@student)
#     	# 	get :formF_4, :year => '2014'
#     	# end
#     end
 end
