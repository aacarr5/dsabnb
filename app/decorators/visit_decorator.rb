class VisitDecorator < Draper::Decorator
  decorates :visit
  delegate_all

  def date
    date = "#{start_and_end_dates}"
  end

  def location
    location = city? && state? ? "#{city}, #{state.to_s}" : zipcode
  end

  def short_details
    details = city? && state? ? "#{city}, #{state.to_s}" : zipcode
    details << " (#{start_and_end_dates})"
  end

  def formatted_zip
    zipcode[0...5]
  end
end
