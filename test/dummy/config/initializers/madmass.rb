  Madmass.setup do |config|
    # Configure Madmass in order to use the Active Record transaction adapter,
    # default is :"Madmass::Transaction::NoneAdapter".
    # You can also create your own adapter and pass it to the configuration
    

     #Configure Madmass to use
    config.perception_sender = "Madmass::Comm::SockySender"
    Madmass::Utils::InstallConfig.init
 end
