class Student < ActiveRecord::Base
    require 'csv'
    def self.to_csv(all_products, selected_columns)
        
        puts "========================"
        puts selected_columns.inspect
        puts "========================"
        
        hasCount = selected_columns.find { |item| item =~ /count/i }
        selected_columns.reject!{|item| item =~ /count/i }
        
        CSV.generate do |csv|
            if hasCount
               csv << ["Count = " + all_products.length.to_s]
            end
            csv << selected_columns
            all_products.each do |product|
                csv << product.attributes.values_at(*selected_columns)
            end
        end
    end
    
    def self.to_j1_csv(year)
        puts "hello"
        puts year
        puts year.class
        
        new_students = {}
        new_students[ "CP" ] = where([ "(prim_deg_cat like ? or prim_deg_cat like ? or prim_deg_cat like ?) and prim_deg_maj_1 like ? and prim_deg like ?", "Summer "+year.to_s+"%", "Fall "+year.to_s+"%", "Spring "+(year+1).to_s+"%", "CP%", "M%" ]).count
        new_students[ "CE" ] = where([ "(prim_deg_cat like ? or prim_deg_cat like ? or prim_deg_cat like ?) and prim_deg_maj_1 like ? and prim_deg like ?", "Summer "+year.to_s+"%", "Fall "+year.to_s+"%", "Spring "+(year+1).to_s+"%", "CE%", "M%" ]).count
    
        prior_students = {}
        prior_students[ "CP" ] = where([ "(prim_deg_cat like ? or prim_deg_cat like ? or prim_deg_cat like ?) and prim_deg_maj_1 like ? and prim_deg like ?", "Summer "+(year-1).to_s+"%", "Fall "+(year-1).to_s+"%", "Spring "+year.to_s+"%", "CP%", "M%" ]).count
        prior_students[ "CE" ] = where([ "(prim_deg_cat like ? or prim_deg_cat like ? or prim_deg_cat like ?) and prim_deg_maj_1 like ? and prim_deg like ?", "Summer "+(year-1).to_s+"%", "Fall "+(year-1).to_s+"%", "Spring "+year.to_s+"%", "CE%", "M%" ]).count
        
        CSV.generate do |csv|
            csv << ["", "CS", "CE"]
            csv << ["Number of newly-admitted masters students", new_students[ "CP" ].to_s, new_students[ "CE" ].to_s]
            csv << ["Prior Year", prior_students[ "CP" ].to_s, prior_students[ "CE" ].to_s]
        end
    end
    
    def self.to_f3_csv(year)
        puts "hello"
        puts year
        puts year.class
        
        new_students = {}
        new_students[ "CP" ] = where([ "(prim_deg_cat like ? or prim_deg_cat like ? or prim_deg_cat like ?) and prim_deg_maj_1 like ? and prim_deg = ?", "Summer "+year.to_s+"%", "Fall "+year.to_s+"%", "Spring "+(year+1).to_s+"%", "CP%", "PHD" ]).count
        new_students[ "CE" ] = where([ "(prim_deg_cat like ? or prim_deg_cat like ? or prim_deg_cat like ?) and prim_deg_maj_1 like ? and prim_deg = ?", "Summer "+year.to_s+"%", "Fall "+year.to_s+"%", "Spring "+(year+1).to_s+"%", "CE%", "PHD" ]).count
        
        prior_students = {}
        prior_students[ "CP" ] = where([ "(prim_deg_cat like ? or prim_deg_cat like ? or prim_deg_cat like ?) and prim_deg_maj_1 like ? and prim_deg = ?", "Summer "+(year-1).to_s+"%", "Fall "+(year-1).to_s+"%", "Spring "+year.to_s+"%", "CP%", "PHD" ]).count
        prior_students[ "CE" ] = where([ "(prim_deg_cat like ? or prim_deg_cat like ? or prim_deg_cat like ?) and prim_deg_maj_1 like ? and prim_deg = ?", "Summer "+(year-1).to_s+"%", "Fall "+(year-1).to_s+"%", "Spring "+year.to_s+"%", "CE%", "PHD" ]).count
        
        CSV.generate do |csv|
            csv << ["", "CS", "CE"]
            csv << ["Number of newly admitted PhD Students", new_students[ "CP" ].to_s, new_students[ "CE" ].to_s]
            csv << ["Number of PhD Students Prior Year", prior_students[ "CP" ].to_s, prior_students[ "CE" ].to_s]
        end
    end
    
    def self.csv_table(product,c_filter,r_filter,c_attri,r_attri)
        CSV.generate do |csv|
         #   raise params.inspect
            csv<<c_attri
            i=0
            r_filter.each do |r|
                temp=[]
                temp<<r_attri[i]
              
                i=i+1
                c_filter.each do |c|    
            
                    temp<<product.where(c).where(r).count.to_s
                    
                    
                end
                csv<<temp
            end
        end    
        
    end
    
    def self.altercsv (array)
    CSV.generate do |csv|
    array.each do |t|
        csv<<t
    
    end
    end
    end
    
end
