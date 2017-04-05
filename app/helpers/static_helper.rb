module StaticHelper
   def get_repo_name 
      t('sufia.product_name')
   end 

   def get_page_title
      t('sufia.statics.' + action_name)
   end

   def default_page_title
      if controller_name == 'static'
	 get_page_title + ' // ' + get_repo_name
      else
         super
      end
   end

   def static_page_h1 
      get_page_title
   end

   def contact_link(linktext)
       link_to linktext, main_app.about_path(:anchor => 'about_contact')
   end
end 

