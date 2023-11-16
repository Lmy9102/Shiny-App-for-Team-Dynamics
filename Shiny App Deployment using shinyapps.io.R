
#install.packages("rsconnect")
library(rsconnect)

## Use shinyapps.io to share the URL of the app with others. You need to register with shinyapps.io first to get the following information. 
rsconnect::setAccountInfo(name='Name', token='TOKEN', secret='SECRET')

rsconnect::deployApp('Path to Directory')


