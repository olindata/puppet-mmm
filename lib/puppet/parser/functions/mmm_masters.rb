module Puppet::Parser::Functions
  newfunction(:mmm_masters, :type => :rvalue) do |args|
    raise Puppet::ParseError, "Expected 1 argument, got #{args.size}" if args.size != 1
    raise Puppet::ParseError, "Must pass either a hostname or an array of hostnames" if args[0].empty?

    hostnames = args[0]
    ips       = []

    hostnames = [ hostnames ] if not hostnames.is_a? Array

    raise Puppet::ParseError, "No more than 2 masters to a single cluster" if hostnames.size > 2

    hostnames.each do |hostname|
      ip = `cat /etc/hosts | grep #{hostname} | head -1 | awk '{print $1}' | xargs echo -n`

      ips << {
        "host" => hostname,
        "ip"   => ip,
        "peer" => hostnames[0] == hostname ? hostnames[1] : hostnames[0]
      }
    end

    return ips
  end
end
