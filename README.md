    ███╗   ██╗██╗   ██╗ ██████╗██╗     ███████╗██╗   ██╗███████╗
    ████╗  ██║██║   ██║██╔════╝██║     ██╔════╝██║   ██║██╔════╝
    ██╔██╗ ██║██║   ██║██║     ██║     █████╗  ██║   ██║███████╗
    ██║╚██╗██║██║   ██║██║     ██║     ██╔══╝  ██║   ██║╚════██║
    ██║ ╚████║╚██████╔╝╚██████╗███████╗███████╗╚██████╔╝███████║
    ╚═╝  ╚═══╝ ╚═════╝  ╚═════╝╚══════╝╚══════╝ ╚═════╝ ╚══════╝
Nucleus is a supplemental offensive security tool that leverages open source tools to automate some of the remedial tasks that take place during penetration testing and bug bounty hunting. Created by [AG](https://risk3sixty.com/offensive-security-team) from risk3sixty.

# Installation
_For best results, it is advised that you run this tool from a disposable VPC (i.e., DigitalOcean, AWS, Linode, etc.) to avoid having your public IP address blocked._
_This tool and the installation should be run as root to ensure proper permissions are met when installing dependencies._
```
git clone https://github.com/r3s-ost/Nucleus
cd Nucleus
./installation.sh
```
# Usage
```
./tool.sh -h
Usage: ./tool.sh [-d domain] [-D domain_list] [-i ip/CIDR] [-I ip_list] [-h]
  -d  Specify a single domain.
  -D  Specify a list of domains from a file.
  -i  Specify a single IP address or CIDR range.
  -I  Specify a list of IP addresses and/or CIDR ranges from a file.
  -h  Display this help message.
```

# Example
![image](https://github.com/r3s-ost/Nucleus/assets/78289580/ccab1a86-1334-4acd-bad2-2f5b2c6e2dac)

# Additional Configuration
To better equip Nucleus, it is recommended to add additional provider API keys to the subfinder configuration. This will help collect more subdomains for your targets (if searching a domain/domains). To do so, create or modify the providers file typically found at ```$HOME/.config/subfinder/provider-config.yaml```

The script also contains actions to provide a notification via notify for certain outputs. This function is commented out by default, but can be enabled by simply removing the comment (lines 85, 88, 106, 109). Just remember to setup your preferred notification method in the configuration file ```$HOME/.config/notify/provider-config.yaml```
# Author
Created by [Andrew Gahan](https://www.linkedin.com/in/andrew-gahan/) - Senior Security Consultant @ [risk3sixty](https://risk3sixty.com/offensive-security-team)
### Final Thoughts
This tool is meant to be used for authorized testing only. Do not use this tool to attack targets in which you to have written, authorized consent. R3S is not liable for any unauthorized usage of this tool, or any other public tools.

