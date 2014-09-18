#You will need your own Steam API key to enter into each URL
#You will need your own account_id for steam for each URL
#You will need your player_id for within dota to extract each datapoint

library(XML)

#store the URL into a variable
dotaURL = 'http://api.steampowered.com/IDOTA2Match_570/GetMatchHistory/V001/?key=<key>&format=xml&account_id=<id>'

#load xml in a way that gives you access to each part
dota = xmlTreeParse(dotaURL, useInternalNodes=TRUE)
matchHistory = xmlRoot(dota)
#print details about the data loaded
xmlName(matchHistory)
names(matchHistory)

#pull out match id from xml
match_ids = xpathSApply(matchHistory,"//match_id", xmlValue)

#Create a matric to store all of the data
output = matrix(ncol=7, nrow=100)
#initialize row counter
j = 0
#pull data from each match
for (i in match_ids){
  #create unique url for each match id
  j = j + 1
  url = 'http://api.steampowered.com/IDOTA2Match_570/GetMatchDetails/V001/?match_id='
  id = i
  url2 = '&key=<key>&format=xml'
  #pull match details for each match
  matchurl = paste(url, id, url2, sep="")
  dotamatch = xmlTreeParse(matchurl, useInternalNodes=TRUE)
  match = xmlRoot(dotamatch)
  output[j,1] = xpathSApply(match, "//player[account_id = '<id>']/kills", xmlValue)
  output[j,2] = xpathSApply(match, "//player[account_id = '<id>']/deaths", xmlValue)
  output[j,3] = xpathSApply(match, "//player[account_id = '<id>']/assists", xmlValue)
  output[j,4] = xpathSApply(match, "//player[account_id = '<id>']/gold", xmlValue)
  output[j,5] = xpathSApply(match, "//player[account_id = '<id>']/hero_damage", xmlValue)
  output[j,6] = xpathSApply(match, "//player[account_id = '<id>']/tower_damage", xmlValue)
  output[j,7] = xpathSApply(match, "//player[account_id = '<id>']/hero_healing", xmlValue)
}

stats = data.frame(output)
col_headers = c('kills', 'deaths', 'assists', 'gold', 'hero_damage', 'tower_damage', 'hero_healing')
names(stats) = col_headers
write.csv(stats, file = 'MyDotaStats.csv')
