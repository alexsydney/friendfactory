class PositivelyfriskySite < ApplicationSite
  def id
    2
  end
 
  def name
    "positivelyfrisky"
  end
    
  def layout
    name
  end  

  def launch?
    false
  end
  
  def analytics_account_number
    'UA-19948002-2'
  end
  
  def analytics_domain_name
    '.positivelyfrisky.com'
  end
end