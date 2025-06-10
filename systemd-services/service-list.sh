service_list()
{
    # set service list file name
    SERVICE_LIST_FILE_NAME=$1

    # create service list
    SERVICE_LIST=''

    # read every line from file
    while read -r line
    do
        # when line is not empty
        if [ "$line" ]
        then
            # get first character of the line
            FIRST_CHAR=$(printf %c "$line")

            # when line is not a comment
            if [ $FIRST_CHAR != '#' ]
            then
                # add service to service list
                SERVICE_LIST=$SERVICE_LIST' '$line
            fi
        fi
    done < "$SERVICE_LIST_FILE_NAME"

    # print service list
    echo $SERVICE_LIST
}
