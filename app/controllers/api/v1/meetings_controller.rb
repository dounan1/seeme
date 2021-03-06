class Api::V1::MeetingsController < Api::V1::BaseController
  acts_as_token_authentication_handler_for User
  before_action :authenticate_user!
  before_action :set_meeting, only: [:show, :update, :destroy, :accept, :decline, :cancel]

  def index
    @meetings = policy_scope(Meeting)
    @meetings = @meetings.within_a_day
    # authorize @meetings
  end

  def show
  end

  def update
    if @meeting.update(meeting_params)
      render :show
    else
      render_error
    end
  end

  def new
  end

  def create

    meetings = Meeting.between_user_ids(current_user.id, meeting_params[:recipient_id])
    # byebug
    if meetings.empty? || meetings.last.created_at < Time.now - 1.day
      @meeting = Meeting.new
      @meeting.sender = current_user
      @meeting.recipient = User.find(meeting_params[:recipient_id])
      authorize @meeting
      if @meeting.save
        render json: @meeting
      else
        render_error
      end
    else
      render json: meetings.last
    end
  end

  def destroy
    @meeting.destroy
    render :index
  end

  def accept
    @meeting.accept
    @meeting.save(:validate => false)
    render :show
  end

  def decline
    @meeting.decline
    @meeting.save(:validate => false)
    render :show
  end

  def cancel
    @meeting.cancel
    @meeting.save(:validate => false)
    render :show
  end

  private

  def set_meeting
    @meeting = Meeting.find(params[:id])
    authorize @meeting
  end

  def meeting_params
    params.require(:meeting).permit(:recipient_id)
  end

  def render_error
    render json: { errors: @meeting.errors.full_messages },
      status: :unprocessable_entity
  end
end
