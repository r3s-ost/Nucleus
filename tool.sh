#!/bin/bash

echo -e " 
███╗   ██╗██╗   ██╗ ██████╗██╗     ███████╗██╗   ██╗███████╗
████╗  ██║██║   ██║██╔════╝██║     ██╔════╝██║   ██║██╔════╝
██╔██╗ ██║██║   ██║██║     ██║     █████╗  ██║   ██║███████╗
██║╚██╗██║██║   ██║██║     ██║     ██╔══╝  ██║   ██║╚════██║
██║ ╚████║╚██████╔╝╚██████╗███████╗███████╗╚██████╔╝███████║
╚═╝  ╚═══╝ ╚═════╝  ╚═════╝╚══════╝╚══════╝ ╚═════╝ ╚══════╝
                 created by: AG @ risk3sixty                                           
                    "

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please try again with 'sudo' or log in as root." >&2
    exit 1
fi

# Initialize variables
domain=""
domain_list=""
ip=""
ip_list=""

# Display usage
usage() {
    echo "Usage: $0 [-d domain] [-D domain_list] [-i ip/CIDR] [-I ip_list] [-h]"
    echo "  -d  Specify a single domain."
    echo "  -D  Specify a list of domains from a file."
    echo "  -i  Specify a single IP address or CIDR range."
    echo "  -I  Specify a list of IP addresses and/or CIDR ranges from a file."
    echo "  -h  Display this help message."
    exit 1
}

# Parse command line options
while getopts "d:D:i:I:h" opt; do
    case "${opt}" in
        d)
            domain=${OPTARG}
            ;;
        D)
            domain_list=${OPTARG}
            ;;
        i)
            ip=${OPTARG}
            ;;
        I)
            ip_list=${OPTARG}
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

# Check for at least one option
if [ -z "$domain" ] && [ -z "$domain_list" ] && [ -z "$ip" ] && [ -z "$ip_list" ]; then
    echo "Error: You must specify at least one option."
    usage
fi

# Function to handle domain-based operations
handle_domain() {
    local domain=$1
    mkdir -p "$domain"
    
    echo -e "\n[+] Discovering subdomains for $domain...\n"
    ~/go/bin/subfinder -d $domain -silent -o "$domain/subdomains_$domain.txt"

    echo -e "\n[+] Enumerating live web hosts..."
    cat "$domain/subdomains_$domain.txt" | ~/go/bin/httpx -p 66,80,81,443,445,457,1080,1100,1241,1352,1433,1434,1521,1944,2301,3000,3128,3306,4000,4001,4002,4100,4433,5000,5060,5061,5432,5800,5801,5802,6346,6347,7001,7002,8000,8001,8009,8008,8080,8443,8089,9000,9001,30821,10443,10943,13110,1720,38443 -silent -o "$domain/live_hosts_$domain.txt"

    echo -e "\n[+] Taking screenshots of live web hosts...\n"
    ~/go/bin/gowitness file -f "$domain/live_hosts_$domain.txt" --delay 10 -P "$domain/screenshots"

    echo -e "\n[+] Checking for open ports...\n"
    cat "$domain/subdomains_$domain.txt" | xargs -n1 -P100 dig +short +retry=3 | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' |sort -u > $domain/subs_to_ips.txt
    masscan -iL "$domain/subs_to_ips.txt" --rate=1000 -p 1-65535 -oL $domain/masscan_results.txt

    echo -e "\n[+] Checking for XSS...\n"
    cat live_hosts_$domain.txt | gau | dalfox pipe -o xss_$domain.txt --silence #| notify -silent bulk

    echo -e "\n[+] Checking for vulnerabilities...\n"
    ~/go/bin/nuclei -silent -l "$domain/live_hosts_$domain.txt" -o "$domain/vulnerabilities_$domain.txt" #| notify -silent -bulk

    echo -e "\n[+] Operations completed!"
}

# Function to handle IP-based operations
handle_ip() {
    local ip=$1
    echo -e "\n[+] Enumerating live hosts for $ip...\n"
    echo $ip | ~/go/bin/httpx -p 66,80,81,443,445,457,1080,1100,1241,1352,1433,1434,1521,1944,2301,3000,3128,3306,4000,4001,4002,4100,4433,5000,5060,5061,5432,5800,5801,5802,6346,6347,7001,7002,8000,8001,8009,8008,8080,8443,8089,9000,9001,30821,10443,10943,13110,1720,38443 -silent -o live_hosts_$ip.txt

    echo -e "\n[+] Taking screenshots of live web hosts...\n"
    ~/go/bin/gowitness file -f "live_hosts_$ip.txt" --delay 10 -P screenshots_$ip

    echo -e "\n[+] Checking for open ports...\n"
    masscan $ip --rate=1000 -p 1-65535 -oL masscan_results_$ip.txt

    echo -e "\n[+] Checking for XSS...\n"
    cat live_hosts_$ip.txt | gau | dalfox pipe -o xss_$ip.txt --silence #| notify -silent bulk

    echo -e "\n[+] Checking for vulnerabilities...\n"
    ~/go/bin/nuclei -silent -l live_hosts_$ip.txt -o vulnerabilities_$ip.txt #| notify -silent 

    echo -e "\n[+] Operations completed!"
}


domain_regex='^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$'
ip_regex='^([0-9]{1,3}\.){3}[0-9]{1,3}(\/[0-9]{1,2})?$'

# Handle single domain
if [ ! -z "$domain" ]; then
    if [[ $domain =~ $domain_regex ]]; then
        handle_domain "$domain"
    else
        echo -e "Invalid domain format: $domain\n"
    fi
fi

# Handle domain list
if [ ! -z "$domain_list" ]; then
    while IFS= read -r line; do
        if [[ $line =~ $domain_regex ]]; then
            handle_domain "$line"
        else
            echo -e "Invalid domain format in list: $line\n"
        fi
    done < "$domain_list"
fi

# Function to validate IPv4 or CIDR
validate_ip_or_cidr() {
    local ip_cidr=$1
    if [[ $ip_cidr =~ $ip_regex ]]; then
        # Extract the prefix if present
        local prefix="${BASH_REMATCH[2]}"
        if [[ -n $prefix && ( $prefix -lt 0 || $prefix -gt 32 ) ]]; then
            echo -e "Invalid CIDR range\n"
            return 1
        fi
        return 0
    else
        echo -e "Invalid format: Not a valid IPv4 address or CIDR range\n"
        return 1
    fi
}

# Handle single IP/CIDR
if [ ! -z "$ip" ]; then
    if validate_ip_or_cidr "$ip"; then
        handle_ip "$ip"
    else
        echo -e "Validation failed for IP/CIDR: $ip\n"
    fi
fi

# Handle IP list
if [ ! -z "$ip_list" ]; then
    while IFS= read -r line; do
        if validate_ip_or_cidr "$line"; then
            handle_ip "$line"
        else
            echo -e "Validation failed in IP list for: $line\n"
        fi
    done < "$ip_list"
fi