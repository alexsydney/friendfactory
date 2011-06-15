# =============
# Template Site

if ENV['FORCE'] == "true"
  puts "Forced deletion of signals"
  Signal::Base.delete_all
  Signal::Category.delete_all
  Signal::CategorySignal.delete_all  
end

puts "   * #{Site::TemplateSiteName}"

site = Site.template rescue nil
unless site.present?
  puts "   * creating template site"
  site = Site.create(
    :name => Site::TemplateSiteName,
    :display_name => 'FriskyFactory',
    :analytics_account_number => '',
    :analytics_domain_name => '')  
end

## CSS
file = File.join(Rails.root, 'db', 'seeds', "#{Site::TemplateSiteName}.css")
if File.exists?(file)  
  puts "   * #{site.name}/css"
  site.update_attribute(:css, IO.read(file))    
end


# =======
# Signals

def create_signal(*names)
  names.inject([]) do |memo, name|
    name, display_name = name.is_a?(Array) ? [ name.first, name.last ] : [ name, name.titleize ]
    unless signal = Signal::Base.find_by_name(name)
      puts "   * #{name}"
      signal = Signal::Nominal.create(:name => name, :display_name => display_name)
    end
    memo << signal
  end
end

def category_ordinal
  @ordinal ||= 0; @ordinal += 1
end

def create_signal_category(site, name, display_name, signals)
  unless site.signal_categories.where(:name => name).first.present?
    puts "   * #{site.name}/#{name}"
    category = site.signal_categories.create(:name => name, :display_name => display_name, :ordinal => category_ordinal)
    signals.each_with_index do |signal, idx|
      category.categories_signals.create(:signal_id => signal.id, :ordinal => idx)
    end
  end
end

## Gender
signals = create_signal(
    [ 'gender_male', 'Male' ],
    [ 'gender_female', 'Female' ],
    [ 'gender_transexual', 'Trans' ])

create_signal_category(site, 'gender', 'Gender', signals)

## Orientation
signals = create_signal(
    [ 'orientation_gay', 'Gay' ],
    [ 'orientation_lesbian', 'Lesbian' ],
    [ 'orientation_straight', 'Straight' ],
    [ 'orientation_bisexual', 'Bisexual' ],
    [ 'orientation_transexual', 'Trans' ])

create_signal_category(site, 'orientation', 'Orientation', signals)

## Relationship
signals = create_signal(
    [ 'relationship_single', 'Single' ],
    [ 'relationship_in_relationship', 'In a Relationship' ],
    [ 'relationship_married', 'Married' ],
    [ 'relationship_looking_for_relationship' , 'Looking for a Relationship' ],
    [ 'relationship_friends_only', 'Friends Only' ])

create_signal_category(site, 'relationship', 'Relationship', signals)

## Deafness
signals = create_signal(
    [ 'deafness_deaf', 'Deaf' ],
    [ 'deafness_hard_of_hearing', 'Hard of Hearing'],
    [ 'deafness_hearing', 'Hearing' ],
    [ 'deafness_coda', 'CODA' ])

create_signal_category(site, 'deafness', 'Deafness', signals)

## HIV Status
signals = create_signal(
    [ 'hiv_status_positive', 'Positive' ],
    [ 'hiv_status_negative', 'Negative' ],
    [ 'hiv_status_dont_know', "Don't know" ])

create_signal_category(site, 'hiv_status', 'HIV Status', signals)

## Board Type
signals = create_signal(
    [ 'board_type_surf', 'Surf' ],
    [ 'board_type_snow', 'Snow' ],
    [ 'board_type_skate', 'Skate' ])

create_signal_category(site, 'board_type', 'Board', signals)

## Military Service
signals = create_signal(
    [ 'military_service_navy', 'Seaman' ],
    [ 'military_service_airforce', 'Flyier' ],
    [ 'military_service_army', 'Soldier' ],
    [ 'military_service_marine', 'Marine' ],
    [ 'military_service_guard', 'Guard' ],
    [ 'military_service_reserve', 'Reserve' ])

create_signal_category(site, 'military_service', 'Service', signals)
