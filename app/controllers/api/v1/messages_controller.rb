class Api::V1::MessagesController < Api::V1::BaseController
   acts_as_token_authentication_handler_for User
   # before_action :set_recipient, only: [:new, :create]

   def index
      # @messages = current_user.messages
      # @messages = Message.find(params[:meeting_id])
      meeting = Meeting.find(params[:meeting_id])
      authorize(meeting)
      skip_policy_scope
      @messages = meeting.messages
   end

   def new
      @message = current_user.sent_messages.new
   end

   def create
      @message = Message.new(message_params)
      @message.save!
      # @message.recipient_id = @recipient.id
      skip_authorization
   end

   private

   def message_params
      params.require(:meeting).permit(:content, :recipient_id)
   end

   # def set_recipient
   #     @recipient = User.find(params[:user_id])
   # end
end
