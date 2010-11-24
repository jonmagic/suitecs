class Sentry < ActiveRecord::Base
  has_many :events, :as => :recordable, :dependent => :destroy
  belongs_to :device
  belongs_to :schedule
  belongs_to :goggle

  def survey!
    StatusLang.run(self.id, self.goggle.script) ? true : false
  end

  def notify!(subject, message=nil)
    start_time = Time.today + 7.hours
    end_time = Time.today + 22.hours
    if Time.now > start_time && Time.now < end_time
      Navvy::Job.enqueue(NotificationMailer, :deliver_notification, subject, message, self.schedule.id)
    end
  end

  def to_json(options={})
    super(options.merge(:include => :goggle))
  end

end
