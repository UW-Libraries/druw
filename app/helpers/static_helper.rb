module StaticHelper
   def static_page_title
       default_page_title.gsub('Static','')
   end

   def static_page_h1 
       action_name.titleize
   end
end 

