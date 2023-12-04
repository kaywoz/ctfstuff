#!/bin/bash

# Function to generate a random date from the last year
generate_random_past_date() {
    past_year=$(date -d "last year" +%Y)
    random_month=$(shuf -i 1-12 -n 1)
    random_day=$(shuf -i 1-28 -n 1) # Keeping it 28 to avoid issues with February
    echo "${past_year}${random_month}${random_day}0000"
}

# Function to generate a random date
generate_random_date() {
    echo "$(date -d "$((RANDOM%25+1)) days ago" +"%Y%m%d%H%M")"
}

# Function to generate a random SSH public key base
generate_random_ssh_key_base() {
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 32)"
}

# Predefined list of 50 first names
firstnames=(
    "John" "Jane" "Alice" "Bob" "Charlie" "Diana"
    "Ethan" "Fiona" "George" "Hannah" "Ian" "Julia"
    "Kyle" "Laura" "Mike" "Nancy" "Oscar" "Paula"
    "Quincy" "Rachel" "Steve" "Tina" "Ursula" "Victor"
    "Wendy" "Xavier" "Yvonne" "Zach" "Aaron" "Beth"
    "Caleb" "Debbie" "Edward" "Flora" "Gary" "Heather"
    "Ivan" "Joan" "Kevin" "Linda" "Mason" "Nina"
    "Oliver" "Patty" "Quinn" "Robert" "Sarah" "Tom"
    "Uma" "Vincent"
)

# Predefined list of 50 surnames
surnames=(
    "Adams" "Brown" "Clark" "Davis" "Evans" "Frank"
    "Ghosh" "Hill" "Irwin" "Jones" "King" "Lee"
    "Miller" "Nash" "Owen" "Patel" "Quinn" "Ross"
    "Smith" "Taylor" "Upton" "Vaughn" "Wang" "Xu"
    "Young" "Zhang" "Anderson" "Bell" "Carter" "Dunn"
    "Edwards" "Fisher" "Green" "Howard" "Jackson" "Knight"
    "Lopez" "Mitchell" "Norton" "O'Neil" "Parker" "Quincy"
    "Richardson" "Scott" "Turner" "Underwood" "Vance" "White"
    "Yates" "Zimmerman"
)

# Default password for all users
default_password="4655isstd"

# List of possible domains
domains=("kingcorpo.com" "kingstudio.com" "kinglabs.com" "king-enterprises.com" "kingnet.com")

# List of sample filenames
sample_filenames=("notes" "project_draft" "meeting_schedule" "budget" "presentation" "report" "summary" "plan" "proposal" "outline" "sample" "meeting_notes" "my_darn_notes" "what i think about bob" "things im too chicken to say to my boss")

# Randomly determine the number of user accounts to create (up to 17)
num_users=$((RANDOM % 10 + 1))

# Loop through and create the random number of user accounts
for (( i = 0; i < num_users; i++ )); do
    # Randomly select a first name and a surname
    firstname=${firstnames[$RANDOM % ${#firstnames[@]}]}
    surname=${surnames[$RANDOM % ${#surnames[@]}]}

    # Create username
    username="$(echo ${firstname:0:1} | tr '[:upper:]' '[:lower:]')$(echo $surname | tr '[:upper:]' '[:lower:]')"

    echo "Creating user: $username"
    sudo useradd -m -s /bin/bash "$username"

    # Set the default password
    echo -e "$default_password\n$default_password" | sudo passwd "$username"

    # Generate and add SSH key with a user-specific email
    ssh_public_key_base=$(generate_random_ssh_key_base)
    random_domain=${domains[$RANDOM % ${#domains[@]}]}
    user_email="${username}@${random_domain}"
    user_ssh_key="${ssh_public_key_base} ${user_email}"

    sudo mkdir -p /home/$username/.ssh
    echo "$user_ssh_key" | sudo tee -a /home/$username/.ssh/authorized_keys
    sudo chmod 700 /home/$username/.ssh
    sudo chmod 600 /home/$username/.ssh/authorized_keys
    sudo chown -R $username:$username /home/$username

    # Create random files with plausible filenames and modify times in user's home directory
    num_files=$((RANDOM % 5 + 1))
    for (( j = 0; j < num_files; j++ )); do
        random_datetime=$(generate_random_date) # Random date and time
        random_number=$((RANDOM % 100))
        filename="${sample_filenames[j]}_${random_datetime}_${random_number}.txt"
        random_size=$(( RANDOM % 1024 + 1 )) # Size between 1KB and 1MB
        sudo dd if=/dev/urandom of="/home/$username/$filename" bs=1K count=$random_size
        sudo chown $username:$username "/home/$username/$filename"

        # Extract components for touch command
        year=${random_datetime:0:4}
        month=${random_datetime:4:2}
        day=${random_datetime:6:2}
        hour=${random_datetime:8:2}
        minute=${random_datetime:10:2}

        # Set the random date and time as the modify time
        sudo touch -t "${year}${month}${day}${hour}${minute}" "/home/$username/$filename"
        sudo touch -t "${year}${month}${day}${hour}${minute}" "/home/$username/.ssh/authorized_keys"
    done

    # Change the modify time of the user's home directory
    user_home_modify_date=$(generate_random_past_date)
    sudo touch -t "$user_home_modify_date" "/home/$username"
    sudo touch -t "$user_home_modify_date" "/home/$username/.ssh/authorized_keys"
    sudo chown $username:$username "/home/$username"
done

echo "User creation complete."
