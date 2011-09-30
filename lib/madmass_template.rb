gem("madmass", :git => "git://github.com/algorithmica/madmass.git", :branch => "master" )

initializer("madmass.rb", %Q[
  Madmass.setup do |config|
    # Configure Madmass in order to use the Active Record transaction adapter,
    # default is :"Madmass::Atomic::NoneAdapter".
    # You can also create your own adapter and pass it to the configuration
    config.tx_adapter = :'Madmass::Atomic::ActiveRecordAdapter'

    # Configure Madmass to use
    config.perception_sender = :'Madmass::Comm::SockySender'
  end
  ])