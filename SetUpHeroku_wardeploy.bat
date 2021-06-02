echo off
echo Please locate you CPQ admin environment and create an API user
pause
set /p urlOfCPQAdmin=Type the url to the CPQ admin environment (remove https:// write only this part senordicsadm.admin.cpqdemo.tacton.com) ?
set /p nameOfCPQAdminUser=Type in the username for the API user for the CPQ admin environment ?
set /p nameOfCPQAdminPassword=Type in the password for a the API user for the CPQ admin environment ?
set /p ticket=Type in the ticket number to update in CPQ admin environment (example: T-00000087) ?
set /p cssAPIKey=Enter the API key to be used to communicate between customer self service and Tacton CPQ (example: MinhattDenHarTreKanter) ?
set /p cssAPIUser=Enter the API user name to be used to communicate between customer self service and Tacton CPQ (example: salesserviceusername) ?
set /p updateTicketInCPQ=Do you want to update a ticket in CPQ (y/n)?

IF %updateTicketInCPQ%==y (
	call explorer.exe https://tactoncpqdeltaupdate.herokuapp.com/set/deltaconfigopensource/%urlOfCPQAdmin%/%ticket%/%nameOfCPQAdminUser%/%nameOfCPQAdminPassword%/%cssAPIkey%/%cssAPIUser%
	pause
)

call  heroku login
set /p application=Type name of the application? 

call  heroku plugins:install java
call  heroku apps:create %application%
call heroku addons:create heroku-postgresql:hobby-dev -a %application%
call heroku config:get DATABASE_URL -a %application% > db.txt
set /p dbstring=<db.txt
call del db.txt
set dburl=%dbstring:*@=%
set dburl=jdbc:postgresql://%dburl%
set dbuser=%dbstring:~11,14%
set dbpassword=%dbstring:~26,64%

call replace_variables.bat "leadgen_api_key = API_KEY_PLACEHOLDER" "leadgen_api_key = %cssAPIKey%_LEADGEN"
call replace_variables.bat "customer_self_service_api_key = API_KEY_PLACEHOLDER" "customer_self_service_api_key = %cssAPIKey%"
call replace_variables.bat "cpq_user = API_USER_PLACEHOLDER" "cpq_user = %cssAPIUser%"
call replace_variables.bat "cpq_instance_url = API_CPQ_URL_PLACEHOLDER" "cpq_instance_url = https://%urlOfCPQAdmin%/!tickets~%ticket%"
call replace_variables.bat "spring.datasource.url = DATABASE_URL_PLACEHOLDER" "spring.datasource.url = %dburl%"
call replace_variables.bat "spring.datasource.password = DATABASE_PASSWORD_PLACEHOLDER" "spring.datasource.password = %dbpassword%"
call replace_variables.bat "spring.datasource.username = DATABASE_USER_PLACEHOLDER" "spring.datasource.username = %dbuser%"
call mvn package
for /f "delims=" %%a in ('dir /s /b *.war') do set "war_name=%%~na"

call heroku deploy:war target/%war_name%.war -a %application%

call  heroku config:set -a %application% ^
 cpq_instance_url=https://%urlOfCPQAdmin%/!tickets~%ticket% ^
 cpq_pass="Change this Password 123!" ^
 cpq_user=%cssAPIUser% ^
 css_default_account="meec9e0cc446449fbdd3123be0a86df2" ^
 css_default_country="m29bf8c6ec21499cb3bfdc809b96e754" ^
 css_default_currency="m0f5edaa82434566a2b0dc22702eb5aa" ^
 customer_self_service_api_key=%cssAPIKey% ^
 demo_site_banner_image="https://www.tacton.com/wp-content/uploads/2019/11/smart-commerce-header-3.jpg" ^
 demo_site_col1_image="https://www.tacton.com/wp-content/uploads/2019/09/Improve-Operational-Efficiency@2x.png" ^
 demo_site_col1_text="Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat." ^
 demo_site_col1_title="Improve Operational Efficiency" ^
 demo_site_col2_image="https://www.tacton.com/wp-content/uploads/2019/09/Enhance-Your-Customer-Experience@2x.png" ^
 demo_site_col2_text="Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Rutrum tellus pellentesque eu tincidunt tortor aliquam nulla facilisi. Ullamcorper a lacus vestibulum sed." ^
 demo_site_col2_title="Enhance Your Customer Experience" ^
 demo_site_col3_image="https://www.tacton.com/wp-content/uploads/2019/09/Accellerate-Sales-Velocity@2x.png" ^
 demo_site_col3_text="Sed libero enim sed faucibus. Mi eget mauris pharetra et ultrices neque. Est sit amet facilisis magna etiam. Tristique senectus et netus et malesuada. " ^
 demo_site_col3_title="Accelerate Sales Velocity" ^
 demo_site_info_text="Customers are smarter, and demands have shifted-custom configuration is required. Embracing Smart Commerce is necessary for manufacturers to meet customer expectations and compete on value." ^
 demo_site_info_title="Sell what your customers need" ^
 demo_site_logo="https://www.tacton.com/wp-content/uploads/2019/01/TACTON-LOGO-WHITE-1.svg" ^
 demo_site_name="Tacton CPQ Self Service" ^
 demo_site_favicon_url="https://www.tacton.com/wp-content/uploads/2017/08/tacton_new_logo.png?v=2" ^
 demo_site_new_to="New to Tacton CPQ?" ^
 demo_site_theme="dark-theme" ^
 demo_site_info_background="#6c757d50" ^
 product_name="Tacton CPQ" ^
 no_visualization_image="https://www.tacton.com/wp-content/uploads/2019/01/TACTON-LOGO-WHITE-1.svg" ^
  visualization_button_color="black" ^
 spring.datasource.url=%dburl% ^
 spring.datasource.password=%dbpassword% ^
 spring.datasource.username=%dbuser% ^
 auto_approve_users="false" ^
 css_price_summary_attribute="ListPrice" ^
 css_bom_columns="[{\"articleNumber\": \"Variant\",\"description\": \"Description\", \"price\": \"ListPrice\"},\"qty\": \"Qty\"}]" ^
 css_bom_extra_info="[{\"name\":\"Article no\", \"key\": \"itemNumberColumn\"}]"

echo Ensure that the config.properties file has these values:
echo ------------------------------------------------------------
echo The CPQ url and credentials:
echo cpq_instance_url=https://%urlOfCPQAdmin%/!tickets~%ticket%
echo cpq_user=%cssAPIUser%
echo cpq_pass=Change this Password 123!
echo customer_self_service_api_key=%cssAPIKey%
echo leadgen_api_key=%cssAPIKey%
echo ------------------------------------------------------------
echo cpq_user=%nameOfCPQAdminUser% 
echo The database connection strings:
echo spring.datasource.url=%dburl% 
echo spring.datasource.password=%dbpassword% 
echo spring.datasource.username=%dbuser% 
echo ------------------------------------------------------------
call explorer.exe https://%application%.herokuapp.com
pause