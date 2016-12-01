class Query < ActiveRecord::Base
    has_many :prefilters
    has_many :rowfilters
    has_many :collumfilters
 #   has_many :headers
end
