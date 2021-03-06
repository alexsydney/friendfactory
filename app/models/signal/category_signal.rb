class Signal::CategorySignal < ActiveRecord::Base
  self.table_name = "signal_categories_signals"

  belongs_to :category,
      :class_name  => 'Signal::Category',
      :foreign_key => 'category_id'

  belongs_to :signal,
      :class_name  => 'Signal::Base',
      :foreign_key => 'signal_id'

  def clone
    super.tap { |category_signal| category_signal.category_id = nil }
  end
end
