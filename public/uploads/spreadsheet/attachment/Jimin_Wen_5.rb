class CartesianProduct
 include Enumerable
 # your code here
 def initialize(s1,s2)
 	@res=[]
 	s1.each do |w|
 		
 		s2.each do |m|
 			temp=[]				#The temp array to record each pair of the product 
 			temp<<w 
 			temp<<m  
		 	@res<<temp			#The pair is added into the result array 
 		end 
 		
 	end
	return @res 
 end

	def each 
		@res.each { |index| yield(index) }			#Use yield to implement the each method 
	end 

end

#Examples of use
#c = CartesianProduct.new([:a,:b], [4,5])
 
#c.each { |elt| puts elt.inspect }
# [:a, 4]
# [:a, 5]
# [:b, 4]
# [:b, 5]

#c = CartesianProduct.new([:a,:b], [])
#c.each { |elt| puts elt.inspect }
# (nothing printed since Cartesian product
# of anything with an empty collection is empty)