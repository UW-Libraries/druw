module StaticHelper

  def get_static_page_title
    t('hyrax.statics.' + action_name)
  end


  def default_page_title
    if controller_name == 'static'
      get_static_page_title + ' // ' +  t('hyrax.product_name')
    else
      super
    end
  end

   def contact_link(linktext)
      link_to linktext, main_app.about_path(:anchor => 'about_contact')
   end
end

