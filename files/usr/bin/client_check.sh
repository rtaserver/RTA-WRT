#!/bin/bash

# Database credentials
DB_USER="radius"
DB_PASS="radius"
DB_NAME="radius"

# Radclient parameters
RADCLIENT_IP="127.0.0.1:3799"
RADCLIENT_SECRET="testing123"
FRAMED_IP="10.10.10.1"

# Function to check and disconnect users
check_users() {
  # Query to get usernames and session IDs for active sessions
  active_users=$(mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
    SELECT DISTINCT username FROM radacct
    WHERE acctstoptime IS NULL;
  " -B -N)

  echo "Active users:"
  echo "$active_users"

  # Iterate over each active user
  while IFS=$'\n' read -r username; do
    echo "Processing active user: $username"

    # Query to get total input and output octets for all sessions of the user
    total_octets_data=$(mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
      SELECT SUM(acctinputoctets) AS total_input_octets, SUM(acctoutputoctets) AS total_output_octets
      FROM radacct
      WHERE username='$username';
    " -B -N)

    # Parse the result
    total_input_octets=$(echo "$total_octets_data" | awk '{print $1}')
    total_output_octets=$(echo "$total_octets_data" | awk '{print $2}')

    echo "Input Octets: $total_input_octets, Output Octets: $total_output_octets"

    # Query to get the planName from userbillinfo
    plan_name=$(mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
      SELECT planName FROM userbillinfo WHERE username='$username';
    " -B -N)

    echo "Plan name: $plan_name"

    if [ -n "$plan_name" ]; then
      # Query to get the ChilliSpot-Max-Total-Octets from radgroupreply
      max_total_octets=$(mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
        SELECT value FROM radgroupreply
        WHERE groupname='$plan_name' AND attribute='ChilliSpot-Max-Total-Octets';
      " -B -N)

      echo "Max total octets: $max_total_octets"

      if [ -n "$max_total_octets" ]; then
        # Calculate the total octets
        total_octets=$((total_input_octets + total_output_octets))

        echo "Total octets: $total_octets"

        # Check if the user has exceeded the max total octets
        if [ "$total_octets" -ge "$max_total_octets" ]; then
          # Query to get all session IDs for the user
          session_ids=$(mysql -u$DB_USER -p$DB_PASS $DB_NAME -e "
            SELECT acctsessionid FROM radacct
            WHERE username='$username';
          " -B -N)

          echo "Session IDs to disconnect:"
          echo "$session_ids"

          # Disconnect the user using radclient for each session
          while IFS=$'\n' read -r session_id; do
            echo "Disconnecting user $username (Session ID: $session_id) due to exceeded octets limit."
            echo "User-Name=\"$username\",Acct-Session-Id=\"$session_id\",Framed-IP-Address=$FRAMED_IP" \
              | radclient -c '1' -n '3' -r '3' -t '3' -x $RADCLIENT_IP 'disconnect' $RADCLIENT_SECRET
          done <<< "$session_ids"
        fi
      fi
    fi
  done <<< "$active_users"
}

# Call the function to check users
check_users
