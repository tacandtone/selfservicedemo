#!/bin/bash
function pause(){
   read -r -p "$*"
}
urlencode() {
    # urlencode <string>
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
}
echo off
pause "Please locate you CPQ admin environment and create an API user. Click any key to continue..."
echo "Type the url to the CPQ admin environment (remove https:// write only this part senordicsadm.admin.cpqdemo.tacton.com)"
read -r urlOfCPQAdmin
echo "Type in the username for the API user for the CPQ admin environment"
read -r nameOfCPQAdminUser
echo "Type in the password for a the API user for the CPQ admin environment"
read -r nameOfCPQAdminPassword
echo "Type in the ticket number to update in CPQ admin environment (example: T-00000087)"
read -r ticket
echo "Enter the API key to be used to communicate between customer self service and Tacton CPQ (example: MinhattDenHarTreKanter)"
read -r cssAPIkey
echo "Enter the API user name to be used to communicate between customer self service and Tacton CPQ (example: salesserviceusername)"
read -r cssAPIUser
echo "Do you want to update a ticket in CPQ (y/n)"
read -r updateTicketInCPQ

cpqurl="https://tactoncpqdeltaupdate.herokuapp.com/set/deltaconfigopensource/$urlOfCPQAdmin/$ticket/$nameOfCPQAdminUser/$nameOfCPQAdminPassword/$cssAPIkey/$cssAPIUser"
if [[ "$updateTicketInCPQ" == "y" ]]
then
open "${cpqurl// /%20}"
fi

heroku login
echo "Type name of the application"
read -r application

heroku plugins:install java
heroku apps:create "$application"
heroku addons:create heroku-postgresql:hobby-dev -a "$application"
db=$(heroku config:get DATABASE_URL -a "$application")

while read -r line; do
  url="$line"
  username=$(echo "$url" | cut -d':' -f 2)
  dbuser="${username//\/}"
  dbpassword=$(echo "$url" | cut -d':' -f 3 | cut -d'@' -f 1)
  dburl=$(echo "$url" | cut -d'@' -f 2)
  dburl="jdbc:postgresql://$dburl"
done <<< "$db"

heroku git:remote -a "$application"

git push heroku

heroku config:set -a "$application" \
 cpq_instance_url="https://$urlOfCPQAdmin/!tickets~$ticket" \
 cpq_pass="Change this Password 123!" \
 cpq_user="$cssAPIUser" \
 css_default_account="meec9e0cc446449fbdd3123be0a86df2" \
 css_default_country="m29bf8c6ec21499cb3bfdc809b96e754" \
 css_default_currency="m0f5edaa82434566a2b0dc22702eb5aa" \
 customer_self_service_api_key="$cssAPIkey" \
 demo_site_banner_image="https://www.tacton.com/wp-content/uploads/2019/11/smart-commerce-header-3.jpg" \
 demo_site_col1_image="https://www.tacton.com/wp-content/uploads/2019/09/Improve-Operational-Efficiency@2x.png" \
 demo_site_col1_text="Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat." \
 demo_site_col1_title="Improve Operational Efficiency" \
 demo_site_col2_image="https://www.tacton.com/wp-content/uploads/2019/09/Enhance-Your-Customer-Experience@2x.png" \
 demo_site_col2_text="Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Rutrum tellus pellentesque eu tincidunt tortor aliquam nulla facilisi. Ullamcorper a lacus vestibulum sed." \
 demo_site_col2_title="Enhance Your Customer Experience" \
 demo_site_col3_image="https://www.tacton.com/wp-content/uploads/2019/09/Accellerate-Sales-Velocity@2x.png" \
 demo_site_col3_text="Sed libero enim sed faucibus. Mi eget mauris pharetra et ultrices neque. Est sit amet facilisis magna etiam. Tristique senectus et netus et malesuada. " \
 demo_site_col3_title="Accelerate Sales Velocity" \
 demo_site_info_text="Customers are smarter, and demands have shifted-custom configuration is required. Embracing Smart Commerce is necessary for manufacturers to meet customer expectations and compete on value." \
 demo_site_info_title="Sell what your customers need" \
 demo_site_logo="https://www.tacton.com/wp-content/uploads/2019/01/TACTON-LOGO-WHITE-1.svg" \
 demo_site_name="Tacton CPQ Self Service" \
 demo_site_favicon_url="https://www.tacton.com/wp-content/uploads/2017/08/tacton_new_logo.png?v=2" \
 demo_site_new_to="New to Tacton CPQ?" \
 demo_site_theme="dark-theme" \
 demo_site_info_background="#6c757d50" \
 product_name="Tacton CPQ" \
 no_visualization_image="https://www.tacton.com/wp-content/uploads/2019/01/TACTON-LOGO-WHITE-1.svg" \
  visualization_button_color="black" \
 spring.datasource.url="$dburl" \
 spring.datasource.password="$dbpassword" \
 spring.datasource.username="$dbuser" \
 auto_approve_users="false" \
 css_price_summary_attribute="ListPrice" \
 css_bom_columns="[{\"articleNumber\": \"itemNumberColumn\",\"description\": \"Description\", \"price\": \"ListPrice\"}]" \
 css_bom_extra_info="[{\"name\":\"Article no\", \"key\": \"itemNumberColumn\"}]"


 echo Ensure that the config.properties file has these values:
echo ------------------------------------------------------------
echo The CPQ url and credentials:
echo cpq_instance_url="https://$urlOfCPQAdmin/!tickets~$ticket"
echo cpq_user="$cssAPIUser"
echo cpq_pass=Change this Password 123!
echo customer_self_service_api_key="$cssAPIkey"
echo leadgen_api_key="$cssAPIkey"
echo ------------------------------------------------------------
echo cpq_user="$nameOfCPQAdminUser"
echo The database connection strings:
echo spring.datasource.url="$dburl"
echo spring.datasource.password="$dbpassword"
echo spring.datasource.username="$dbuser"
echo ------------------------------------------------------------
open "https://$application.herokuapp.com"
pause