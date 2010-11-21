require './lib/ssh'

class Petals
  HOME = "/home/ec2-user/petals-platform-3.1.1"

  STOPPED = /Petals STOPPED/
  STOP_CMD = "export JAVA_HOME=/usr/lib/jvm/jre\\;#{HOME}/bin/stop.sh"

  RUNNING = /Petals RUNNING/
  START_CMD = "export JAVA_HOME=/usr/lib/jvm/jre\\;#{HOME}/bin/startup.sh -D"

  PING_CMD = "export JAVA_HOME=/usr/lib/jvm/jre\\;#{HOME}/bin/ping.sh"



  def initialize key_path
    @ssh = Ssh.new key_path
  end



  def ping node
    @ssh.execute_command_on(node, PING_CMD)
  end

  def startup node
    @ssh.execute_command_on node, START_CMD
    sleep 3 while ping(node) !~ RUNNING
  end

  def stop node
    @ssh.execute_command_on(node, STOP_CMD)
    sleep 3 while ping(node) !~ STOPPED
  end

  def sa_ready node
    /Service Assembly 'sa-BPEL-#{node}Node#{node.id}-provide' started/
  end

  def log_from node, date
    @ssh.execute_command_on node, "cat #{HOME}/logs/petals#{date}.log"
  end
  
  def send_topology node
    @ssh.scp_to node.info[:public_dns], "resources/topology.xml", "#{HOME}/conf/topology.xml"
  end
  
  def send_server_properties node
    @ssh.scp_to node.info[:public_dns], "resources/server.properties#{node.id}", "#{HOME}/conf/server.properties"
  end
  
  def wait_bpel_to_start node, date
    sleep 3 while log_from(node, date) !~  /\[Petals.Container.Components.petals-se-bpel\]\s*Component started/
  end
  
  def install node, path
    @ssh.scp_to node.info[:public_dns], path, "#{HOME}/install"
  end

  def create_topology_from graph
    top = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <tns:topology xmlns:tns=\"http://petals.ow2.org/topology\"
    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
    xsi:schemaLocation=\"http://petals.ow2.org/topology petalsTopology.xsd\">
    <tns:domain mode=\"static\" name=\"PEtALS\">
    <tns:description>The static domain configuration</tns:description>
    <tns:sub-domain name=\"subdomain1\" mode=\"flooding\">
    <tns:description>description of the subdomain</tns:description>
    "

    index = 0
    graph.each_node do |node|
      top << "
      <tns:container name=\"#{index}\" type=\"peer\">
      <tns:description>description of the container #{index}</tns:description>
      <tns:host>#{node.info[:private_dns]}</tns:host>
      <tns:user>petals</tns:user>
      <tns:password>petals</tns:password>
      <tns:webservice-service>
      <tns:port>7600</tns:port>
      <tns:prefix>petals/ws</tns:prefix>
      </tns:webservice-service>
      <tns:jmx-service>
      <tns:rmi-port>7700</tns:rmi-port>
      </tns:jmx-service>
      <tns:transport-service>
      <tns:tcp-port>7800</tns:tcp-port>
      </tns:transport-service>
      <tns:registry-service>
      <tns:port>7900</tns:port>
      </tns:registry-service>
      </tns:container>

      "
      index += 1
    end

    top << "		</tns:sub-domain>
    </tns:domain>
    </tns:topology>"

    top
  end

  def server_properties index
    "# -----------------------------------------------------------------------
    # PEtALS properties
    # -----------------------------------------------------------------------

    #This property specifies the name of the container. In distributed mode, this property is mandatory
    # and must match a container name in the topology.xml file
    petals.container.name=#{index}

    #This property set the maximum duration of the processing of a life-cycle operation on a JBI
    # components and SAs (start, stop, ...). It prevents from hanging threads.
    petals.task.timeout=120000

    #This property specifies the URL path to the PEtALS repository. PEtALS holds its JBI configuration
    # in this repository and can recover this configuration from it.
    #If not specified, the default repository is in $PETALS_HOME/repository.
    #petals.repository.path=file:///home/test/repository

    #This property is used to activate the control of exchange acceptance by target component when
    # the NMR routes messages (see isExchangeWithConsumerOkay and isExchangeWithProviderOkay methods
    # in JBI Component interface)
    # If not specified, the false value is selected by default.
    #petals.exchange.validation=true

    # This property is used to isolate the ClassLoaders created for Shared Libraries and Components
    # from the PEtALS container one.
    # It can be useful to avoid concurrent libraries loading issues.
    # If not specified, the false value is selected by default
    petals.classloaders.isolated=true

    # This property is used to unactivate the autoloader service.
    #It can be useful in production environment to unactivate this service.
    #petals.autoloader=false

    # Alternate topology configuration file URL. This value must be a valid URL like :
    #  - http://localhost:8080/petals/topology.xml
    #  - file:///home/petals/config/topology.xml
    #  - or any valid URL (java.net.URL validation)
    # If not specified, the local topology.xml file is used
    #petals.topology.url=

    # This property defines the strategy of the router
    # Two kind of strategy can be defines: 'highest' or 'random'.
    # The following parameters, separated by commas, represent respectively the weighting for a local
    # endpoint, the weighting for a remote active endpoint and the weighting for a remote inactive endpoint.
    # The 'random' strategy chooses an endpoint randomly in function of the defined weightings.
    # Every endpoint has a chance to be elected, but the more the weight is strong, the more the endpoint
    # can be elected.
    # The 'highest' strategy chooses an endpoint amongst the endpoints with the strongest weight.
    # If not specified, the strategy 'highest,3,2,1' is selected by default
    #petals.router.strategy=highest,3,2,1

    # This property defines the number of attempt to send a message to an endpoint.
    # Several attempts can be done when there is transport failure during the convey of a message
    # If not specified, 2 attempts is selected by default
    petals.router.send.attempt=5

    # This property defines the delay between the send attempts, in milliseconds.
    # If not specified, 1 second is selected by default
    petals.router.send.delay=500


    #Set the following properties in order to establish SSL connections.

    # This property defines the key password to retrieve the private key.
    #petals.ssl.key.password=yourKeyPassword

    # This property defines the keystore file where the keys are stored.
    #petals.ssl.keystore.file=/yourPath/yourKeystoreFile

    # This property defines the keystore password.
    #petals.ssl.keystore.password=yourKeystorePassword

    # This property defines the truststore file where the signatures are verified.
    #petals.ssl.truststore.file=/yourPath/yourTruststoreFile

    # This property defines the truststore password.
    #petals.ssl.truststore.password=yourTruststorePassword


    #Transporter configuration
    #This property defines the number of message that can be received via TCP at the same time.
    # If not specified, '10' receivers is selected by default
    petals.transport.tcp.receivers=100000

    #This property defines the number of message that can be send via TCP at the same time, per component.
    petals.transport.tcp.senders=100000
    # If not specified, '10' senders is selected by default

    #This property defines the timeout to establish a connection, for a sender, in millisecond.
    # If not specified, 5000 milliseconds is selected by default
    petals.transport.tcp.connection.timeout=30000

    #This property defines the timeout to send a TCP packet, for a sender, in millisecond.
    # If not specified, 5000 milliseconds is selected by default
    petals.transport.tcp.send.timeout=30000

    #This property defines the delay before running the 'sender' eviction thread, in millisecond.
    # If not specified, 1 minute is selected by default
    #petals.transport.tcp.send.evictor.delay=60000

    #This property defines the delay before an idle 'sender' is set evictable, in millisecond.
    # If not specified, 1 minute is selected by default
    #petals.transport.tcp.send.evictable.delay=60000

    #This property defines the duration of temporary persisted data, such as Message Exchange, in millisecond.
    # If not specified, 1 hour is selected by default
    petals.persistence.duration=60000

    #Topology update period (in s)
    topology.update.period=60

    # Registry configuration

    #Registry transporter timeout (in ms)
    registry.transport.timeout=30000

    #Synchro period (in s)
    registry.synchro.period=113
    "
  end
end
