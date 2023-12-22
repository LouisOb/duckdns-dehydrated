cd $WORK_PATH

# Register account
dehydrated --register --accept-terms --config $WORK_PATH/config

# Request the certificate

dehydrated --cron --config $WORK_PATH/config --hook $WORK_PATH/hook.sh \
--challenge dns-01 --domains-txt $WORK_PATH/domains.txt
