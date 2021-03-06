class ContactsController < ApplicationController
  skip_before_action :require_complete_profile, only: :create_by_email

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      if (@contact.visit.start_date - Date.today).to_i <= 2
        email_host
        flash[:notice] = "We have sent #{hosting.host.first_name} your contact info!"
      else
        flash[:notice] = "We will send #{hosting.host.first_name} your contact info later tonight!"
      end

      update_and_redirect
    else
      flash.now[:errors] = @contact.errors.full_messages
      render visit_url(visit), status: :unprocessable_entity
    end
  end

  private

  attr_reader :hosting, :visit

  def contact_params
    params.permit(:hosting_id, :visit_id)
  end

  def update_and_redirect
    hosting.increment(:contact_count).save
    redirect_to visit_url(visit)
  end

  def hosting
    @hosting ||= Hosting.find(params[:hosting_id])
  end

  def visit
    @visit ||= Visit.find(params[:visit_id])
  end

  def new_contact_data
    {
      visitor: @contact.visit.user,
      visit: @contact.visit,
      contact: @contact
    }
  end

  def email_host
    UserMailer.new_contact_immediate(
      @contact.hosting,
      @contact.hosting.host,
      new_contact_data
    ).deliver_now
  end
end
