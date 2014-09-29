#You will need your own steam API key for this script to work

library(XML)

#Create a matric to store all of the data
output = matrix(ncol=13, nrow=1000)
#initialize row counter
j = 1

#This loop will pull team composition data for 100 games per hour ten times
for (k in 1:10){
    url = 'http://api.steampowered.com/IDOTA2Match_570/GetMatchHistory/V001/?key=<key>&format=xml&skill=3&min_players=10'
    dota = xmlTreeParse(url, useInternalNodes=TRUE)
    matchHistory = xmlRoot(dota)
    #print details about the data loaded
    xmlName(matchHistory)
    names(matchHistory)
    #pull out match id from xml
    match_ids = xpathSApply(matchHistory,"//match_id", xmlValue)
    
    for (l in match_ids){
        #create unique url for each match id
        url = 'http://api.steampowered.com/IDOTA2Match_570/GetMatchDetails/V001/?match_id='
        id = l
        url2 = '&key=<key>&format=xml'
        #pull match details for each match
        matchurl = paste(url, id, url2, sep="")
        dotamatch = xmlTreeParse(matchurl, useInternalNodes=TRUE)
        match = xmlRoot(dotamatch)
        if (xpathSApply(match, "//hero_id", xmlValue) > 0 ){   
            output[j,1] = xpathSApply(match, "//player[player_slot = '0']/hero_id", xmlValue)
            output[j,2] = xpathSApply(match, "//player[player_slot = '1']/hero_id", xmlValue)
            output[j,3] = xpathSApply(match, "//player[player_slot = '2']/hero_id", xmlValue)
            output[j,4] = xpathSApply(match, "//player[player_slot = '3']/hero_id", xmlValue)
            output[j,5] = xpathSApply(match, "//player[player_slot = '4']/hero_id", xmlValue)
            output[j,6] = xpathSApply(match, "//radiant_win", xmlValue)
            output[j,7] = xpathSApply(match, "//player[player_slot = '128']/hero_id", xmlValue)
            output[j,8] = xpathSApply(match, "//player[player_slot = '129']/hero_id", xmlValue)
            output[j,9] = xpathSApply(match, "//player[player_slot = '130']/hero_id", xmlValue)
            output[j,10] = xpathSApply(match, "//player[player_slot = '131']/hero_id", xmlValue)
            output[j,11] = xpathSApply(match, "//player[player_slot = '132']/hero_id", xmlValue)
            output[j,12] = xpathSApply(match, "//radiant_win", xmlValue)
            output[j,13] = xpathSApply(match, "//match_id", xmlValue)
            j = j + 1
        }
    }
    Sys.sleep(3600)
    rm(dota)
    rm(matchHistory)
    rm(match_ids)
    rm(url)
    rm(matchurl)
    rm(dotamatch)
    rm(match)
}


stats = data.frame(output)
col_headers = c('RHero1', 'RHero2', 'RHero3', 'RHero4', 'RHero5', 'RadiantWin', 'DHero1', 'DHero2', 'DHero3', 'DHero4', 'DHero5', 'RadiantWin')
names(stats) = col_headers
write.csv(stats, file = 'DotaHeroComp.csv')
