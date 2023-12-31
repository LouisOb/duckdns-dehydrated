#!/bin/bash
set -e


# Check if the cron environmental variable is set
if [ -n "$CRON_SCHEDULE" ]; then
    echo "Using custom cron schedule: $CRON_SCHEDULE"
    
    # Copy the custom cron schedule into the crontab file
    echo "$CRON_SCHEDULE /request_cert.sh" | crontab -
else
    echo "Using default cron schedule"
    # Set the default cron schedule
    echo "0 0 */7 * * /request_cert.sh" | crontab -
fi

if [ -n "$DEHYDRATED_CA" ]; then
    echo "Using custom CA: $DEHYDRATED_CA"
    # Copy the custom CA into the config file
    echo "CA=$DEHYDRATED_CA" >> $WORK_PATH/config
else
    echo "Using default CA: letsencrypt"
fi

if [ -n "$DEHYDRATED_DEHYDRATED_USER" ] && ! id $DEHYDRATED_DEHYDRATED_USER; then
    #create user
    echo "Creating user $DEHYDRATED_DEHYDRATED_USER"
    adduser -D -H -s /bin/sh $DEHYDRATED_DEHYDRATED_USER
    chown -R $DEHYDRATED_DEHYDRATED_USER:$DEHYDRATED_DEHYDRATED_USER $DATA_PATH
    chown -R $DEHYDRATED_DEHYDRATED_USER:$DEHYDRATED_DEHYDRATED_USER $WORK_PATH
    echo "Using user $DEHYDRATED_DEHYDRATED_USER"
fi

if [ -n "$DUCKDNS_TOKEN" ]; then
    echo "Using DuckDNS token $DUCKDNS_TOKEN"
    # Replace the token in the hook.sh file
    sed -i "s/your-token/$DUCKDNS_TOKEN/g" $WORK_PATH/hook.sh
else
    echo "DUCKDNS_TOKEN is not defined. Please set the token."
    exit 1
fi

if [ -n "$MAIN_DOMAIN" ]; then
    echo "Using domains $MAIN_DOMAIN"
    # Copy the custom domains into the domains.txt file
    echo "$MAIN_DOMAIN > domain_cert" >> $WORK_PATH/domains.txt
else
    echo "DOMAINS is not defined. Please set the domains."
    exit 1
fi

if [ -n "$SUBDOMAINS" ]; then
    arr=( $SUBDOMAINS )
    echo "Using subdomains $SUBDOMAINS"
    # Copy the custom subdomains into the domains.txt file
    for subdomain in "${arr[@]}";
        do echo "$MAIN_DOMAIN $subdomain" >> $WORK_PATH/domains.txt;
    done
fi

echo "ACCOUNTDIR=$DATA_PATH/accounts" >> $WORK_PATH/config
echo "CERTDIR=$DATA_PATH/certs" >> $WORK_PATH/config
for var_name in $(set | grep '^DEHYDRATED' | awk -F= '{print $1}'); do
  var_value=$(eval echo \$$var_name)
  echo "$(echo "$var_name" | cut -d_ -f2-)=$var_value" >> $WORK_PATH/config
done
echo "Set variables in config file"

if $FORCE_RUN ; then
    echo "Forcing a run of the cron job"
    /request_cert.sh
fi

# Start the cron service
crond -f
